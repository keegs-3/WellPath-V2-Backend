-- Add pillar_name to patient_component_scores_history and make it required
-- Swift code uses pillar_name not pillar_id, so we need both for compatibility

-- Backfill pillar_name from pillar_id for existing rows
UPDATE patient_component_scores_history h
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE h.pillar_id = p.pillar_id
AND h.pillar_name IS NULL;

-- Make pillar_name NOT NULL
ALTER TABLE patient_component_scores_history
ALTER COLUMN pillar_name SET NOT NULL;

-- Add foreign key to pillars_base on pillar_name
ALTER TABLE patient_component_scores_history
ADD CONSTRAINT patient_component_scores_history_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

-- Add index for pillar_name queries
CREATE INDEX IF NOT EXISTS idx_component_scores_history_pillar_name
ON patient_component_scores_history(pillar_name);

-- Add index for patient + pillar_name + component (common mobile query pattern)
CREATE INDEX IF NOT EXISTS idx_component_scores_history_patient_pillar_name_component
ON patient_component_scores_history(patient_id, pillar_name, component_type, calculated_at DESC);

-- Add comment
COMMENT ON COLUMN patient_component_scores_history.pillar_name IS
'Pillar name (e.g., "Healthful Nutrition"). Used by Swift mobile code. Replaces pillar_id for modern queries.';
