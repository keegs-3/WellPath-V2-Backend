-- Create a queue table for WellPath score recalculations
-- This is a more reliable approach than calling edge functions from triggers

CREATE TABLE IF NOT EXISTS public.wellpath_score_recalculation_queue (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id uuid NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    triggered_by text NOT NULL, -- 'biomarker', 'biometric', 'survey'
    triggered_at timestamp with time zone NOT NULL DEFAULT now(),
    processed_at timestamp with time zone,
    status text NOT NULL DEFAULT 'pending', -- 'pending', 'processing', 'completed', 'failed'
    error_message text,
    created_at timestamp with time zone NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_score_queue_patient_status ON public.wellpath_score_recalculation_queue(patient_id, status);
CREATE INDEX idx_score_queue_status_triggered ON public.wellpath_score_recalculation_queue(status, triggered_at);

-- RLS
ALTER TABLE public.wellpath_score_recalculation_queue ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role can manage queue"
ON public.wellpath_score_recalculation_queue
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT, INSERT, UPDATE, DELETE ON public.wellpath_score_recalculation_queue TO service_role;

-- Create trigger function to add to queue
CREATE OR REPLACE FUNCTION public.queue_wellpath_score_recalculation()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE
  v_patient_id uuid;
  v_triggered_by text;
BEGIN
  -- Get the patient_id from the affected row
  IF TG_OP = 'DELETE' THEN
    v_patient_id := OLD.patient_id;
  ELSE
    v_patient_id := NEW.patient_id;
  END IF;

  -- Determine trigger source
  v_triggered_by := TG_TABLE_NAME;

  -- Only queue if there isn't already a pending request for this patient
  -- This prevents overwhelming the queue with duplicate requests
  INSERT INTO public.wellpath_score_recalculation_queue (patient_id, triggered_by)
  SELECT v_patient_id, v_triggered_by
  WHERE NOT EXISTS (
    SELECT 1 FROM public.wellpath_score_recalculation_queue
    WHERE patient_id = v_patient_id
    AND status IN ('pending', 'processing')
    AND triggered_at > now() - interval '5 minutes'
  );

  RETURN COALESCE(NEW, OLD);
END;
$$;

-- Create triggers on source tables
DROP TRIGGER IF EXISTS trigger_queue_score_on_biomarker_change ON public.patient_biomarker_readings;
CREATE TRIGGER trigger_queue_score_on_biomarker_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_biomarker_readings
FOR EACH ROW
EXECUTE FUNCTION public.queue_wellpath_score_recalculation();

DROP TRIGGER IF EXISTS trigger_queue_score_on_biometric_change ON public.patient_biometric_readings;
CREATE TRIGGER trigger_queue_score_on_biometric_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_biometric_readings
FOR EACH ROW
EXECUTE FUNCTION public.queue_wellpath_score_recalculation();

DROP TRIGGER IF EXISTS trigger_queue_score_on_survey_change ON public.patient_survey_responses;
CREATE TRIGGER trigger_queue_score_on_survey_change
AFTER INSERT OR UPDATE OR DELETE ON public.patient_survey_responses
FOR EACH ROW
EXECUTE FUNCTION public.queue_wellpath_score_recalculation();

-- Create a function to process the queue
-- This can be called by a cron job or edge function
CREATE OR REPLACE FUNCTION public.process_wellpath_score_queue(p_batch_size integer DEFAULT 10)
RETURNS TABLE(
    patient_id uuid,
    status text,
    error text
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_queue_item RECORD;
  v_result RECORD;
BEGIN
  -- Get pending items
  FOR v_queue_item IN
    SELECT id, wellpath_score_recalculation_queue.patient_id
    FROM public.wellpath_score_recalculation_queue
    WHERE status = 'pending'
    ORDER BY triggered_at ASC
    LIMIT p_batch_size
    FOR UPDATE SKIP LOCKED
  LOOP
    -- Mark as processing
    UPDATE public.wellpath_score_recalculation_queue
    SET status = 'processing'
    WHERE id = v_queue_item.id;

    -- Note: The actual scoring calculation should be called via edge function
    -- For now, we just return the patient_id that needs processing
    patient_id := v_queue_item.patient_id;
    status := 'queued_for_processing';
    error := NULL;

    RETURN NEXT;
  END LOOP;
END;
$$;

SELECT '✅ Created score recalculation queue and triggers' as status;
SELECT 'ℹ️  Call process_wellpath_score_queue() or use a cron job to process the queue' as info;
