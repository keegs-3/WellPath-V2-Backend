-- =====================================================
-- Screening Consolidation
-- =====================================================
-- Consolidates 10 individual screening date fields into
-- 2 fields: screening_name + screening_date
--
-- Replaces:
-- - dental_screening_date (DEF_055)
-- - physical_exam_date (DEF_056)
-- - skin_check_date (DEF_057)
-- - vision_check_date (DEF_058)
-- - colonoscopy_date (DEF_059)
-- - mammogram_date (DEF_060)
-- - breast_mri_date (DEF_061)
-- - hpv_date (DEF_062)
-- - pap_date (DEF_063)
-- - psa_date (DEF_064)
--
-- Created: 2025-10-19
-- =====================================================

BEGIN;

-- =====================================================
-- Create Event Type: health_screening
-- =====================================================
INSERT INTO event_types (
  event_type_id,
  name,
  category,
  description,
  is_active
) VALUES (
  'health_screening',
  'Health Screening',
  'health_tracking',
  'Event for tracking preventive health screenings and exams',
  true
)
ON CONFLICT (event_type_id) DO UPDATE
SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  updated_at = now();


-- =====================================================
-- Create Data Entry Fields (2 fields)
-- =====================================================

-- Field 1: screening_name (text input)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active
) VALUES (
  'DEF_SCREENING_NAME',
  'screening_name',
  'Screening Name',
  'Name of the health screening or exam (e.g., Dental Exam, Mammogram, Colonoscopy)',
  'text',
  'text',
  true
)
ON CONFLICT (field_id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();

-- Field 2: screening_date (date input)
INSERT INTO data_entry_fields (
  field_id,
  field_name,
  display_name,
  description,
  field_type,
  data_type,
  is_active
) VALUES (
  'DEF_SCREENING_DATE',
  'screening_date',
  'Screening Date',
  'Date when the screening was completed',
  'timestamp',
  'datetime',
  true
)
ON CONFLICT (field_id) DO UPDATE
SET
  display_name = EXCLUDED.display_name,
  description = EXCLUDED.description,
  updated_at = now();


-- =====================================================
-- Link Fields to Event Type
-- =====================================================
INSERT INTO event_types_data_entry_fields (
  event_type_id,
  data_entry_field_id,
  display_order,
  is_required
) VALUES
  ('health_screening', 'DEF_SCREENING_NAME', 1, true),
  ('health_screening', 'DEF_SCREENING_DATE', 2, true)
ON CONFLICT (event_type_id, data_entry_field_id) DO UPDATE
SET
  display_order = EXCLUDED.display_order,
  is_required = EXCLUDED.is_required,
  updated_at = now();


COMMIT;
