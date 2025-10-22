-- =====================================================
-- Phase 2: Add HealthKit Hybrid Columns to data_source_options
-- =====================================================
-- Adds both healthkit_identifier (text) and healthkit_mapping_id (FK)
-- for resilient bi-directional sync
--
-- Created: 2025-10-20
-- =====================================================

BEGIN;

-- Add hybrid columns
ALTER TABLE data_source_options
ADD COLUMN IF NOT EXISTS healthkit_identifier TEXT,
ADD COLUMN IF NOT EXISTS healthkit_mapping_id UUID REFERENCES healthkit_mapping(id) ON DELETE SET NULL;

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_data_source_hk_identifier
  ON data_source_options(healthkit_identifier);

CREATE INDEX IF NOT EXISTS idx_data_source_hk_mapping
  ON data_source_options(healthkit_mapping_id);

-- Add comments
COMMENT ON COLUMN data_source_options.healthkit_identifier IS
'Raw HealthKit identifier (e.g., HKWorkoutActivityTypeRunning). Stored for audit trail and fallback.';

COMMENT ON COLUMN data_source_options.healthkit_mapping_id IS
'FK to healthkit_mapping table. Used for structured queries and categorization. Can be NULL if mapping not found.';

COMMIT;
