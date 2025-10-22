-- =====================================================
-- Restructure Event Types Dependencies
-- =====================================================
-- Renames event_types_data_entry_fields → event_types_dependencies
-- Adds support for both field dependencies AND calculation dependencies
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Rename Table and Add New Columns
-- =====================================================

ALTER TABLE event_types_data_entry_fields
RENAME TO event_types_dependencies;

-- Add new columns
ALTER TABLE event_types_dependencies
ADD COLUMN dependency_type TEXT NOT NULL DEFAULT 'field',
ADD COLUMN instance_calculation_id TEXT;

-- Add check constraint for dependency_type
ALTER TABLE event_types_dependencies
ADD CONSTRAINT event_types_dependencies_type_check
CHECK (dependency_type IN ('field', 'calculation'));

-- Add check constraint to ensure exactly one of field_id or calc_id is set
ALTER TABLE event_types_dependencies
ADD CONSTRAINT event_types_dependencies_one_dependency_check
CHECK (
  (dependency_type = 'field' AND data_entry_field_id IS NOT NULL AND instance_calculation_id IS NULL)
  OR
  (dependency_type = 'calculation' AND instance_calculation_id IS NOT NULL AND data_entry_field_id IS NULL)
);


-- =====================================================
-- PART 2: Update Constraints and Foreign Keys
-- =====================================================

-- Make data_entry_field_id nullable (since calculation dependencies won't have it)
ALTER TABLE event_types_dependencies
ALTER COLUMN data_entry_field_id DROP NOT NULL;

-- Add foreign key for instance_calculation_id
ALTER TABLE event_types_dependencies
ADD CONSTRAINT event_types_dependencies_instance_calculation_id_fkey
FOREIGN KEY (instance_calculation_id)
REFERENCES instance_calculations(calc_id)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Drop old unique constraint
ALTER TABLE event_types_dependencies
DROP CONSTRAINT unique_event_def_junction;

-- Add new unique indexes (partial indexes with WHERE clause)
CREATE UNIQUE INDEX unique_event_field_dependency
ON event_types_dependencies (event_type_id, data_entry_field_id)
WHERE dependency_type = 'field';

CREATE UNIQUE INDEX unique_event_calc_dependency
ON event_types_dependencies (event_type_id, instance_calculation_id)
WHERE dependency_type = 'calculation';


-- =====================================================
-- PART 3: Update Trigger Name
-- =====================================================

DROP TRIGGER IF EXISTS update_event_types_data_entry_fields_updated_at ON event_types_dependencies;

CREATE TRIGGER update_event_types_dependencies_updated_at
BEFORE UPDATE ON event_types_dependencies
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();


-- =====================================================
-- PART 4: Add Comments
-- =====================================================

COMMENT ON TABLE event_types_dependencies IS
'Defines dependencies for event types. Each event type has:
1. Field dependencies - which data_entry_fields belong to this event
2. Calculation dependencies - which instance_calculations should run when this event is created

dependency_type determines which type of dependency this row represents.';

COMMENT ON COLUMN event_types_dependencies.dependency_type IS
'Type of dependency: "field" for data_entry_field or "calculation" for instance_calculation';

COMMENT ON COLUMN event_types_dependencies.data_entry_field_id IS
'Reference to data_entry_field (required when dependency_type = "field")';

COMMENT ON COLUMN event_types_dependencies.instance_calculation_id IS
'Reference to instance_calculation (required when dependency_type = "calculation")';

COMMENT ON COLUMN event_types_dependencies.is_required IS
'For field dependencies: whether this field is required for the event.
For calculation dependencies: whether this calculation must run successfully.';

COMMENT ON COLUMN event_types_dependencies.display_order IS
'For field dependencies: order to display fields in UI.
For calculation dependencies: order to execute calculations.';


COMMIT;
