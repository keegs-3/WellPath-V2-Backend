-- =====================================================
-- Add event_instance_id to patient_data_entries
-- =====================================================
-- Groups related fields that belong to the same event instance
-- Enables explicit relationships instead of relying on timestamp matching
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- Add event_instance_id column
ALTER TABLE patient_data_entries
ADD COLUMN event_instance_id UUID;

-- Create index for fast lookups by event instance
CREATE INDEX idx_patient_data_entries_event_instance
ON patient_data_entries(event_instance_id);

-- Create composite index for common query pattern (user + event instance)
CREATE INDEX idx_patient_data_entries_user_event_instance
ON patient_data_entries(user_id, event_instance_id);

COMMIT;

-- =====================================================
-- Usage Notes
-- =====================================================
--
-- When creating a new event:
-- 1. Client generates event_instance_id (UUID)
-- 2. All manual fields for that event use the same event_instance_id
-- 3. Edge function reads event_instance_id from manual entries
-- 4. Auto-calculated entries inherit the same event_instance_id
--
-- Querying a specific event:
--   SELECT * FROM patient_data_entries
--   WHERE event_instance_id = 'xxx'
--
-- Deleting an entire event atomically:
--   DELETE FROM patient_data_entries
--   WHERE event_instance_id = 'xxx'
--
-- =====================================================
