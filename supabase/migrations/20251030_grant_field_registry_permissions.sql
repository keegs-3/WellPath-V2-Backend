-- =====================================================
-- Grant Field Registry Permissions
-- =====================================================
-- Fixes permission denied error when inserting into patient_data_entries
--
-- Problem:
-- - patient_data_entries.field_id has FK constraint to field_registry(field_id)
-- - FK constraint trigger needs SELECT on field_registry to verify field_id exists
-- - authenticated role didn't have SELECT permission, causing insert failures
--
-- Created: 2025-10-30
-- =====================================================

BEGIN;

-- Grant SELECT permission on field_registry table to authenticated users
-- This is required because patient_data_entries has a foreign key constraint
-- that references field_registry(field_id), and the FK constraint trigger
-- needs to verify the field_id exists during INSERT operations
GRANT SELECT ON field_registry TO authenticated;

-- Grant SELECT permission on field_registry_complete view to authenticated users
-- This view joins field_registry with data_entry_fields and instance_calculations
-- and may be used by applications for field metadata lookup
GRANT SELECT ON field_registry_complete TO authenticated;

COMMENT ON TABLE field_registry IS
'Central registry for ALL field identifiers. Required for FK constraint validation on patient_data_entries.';

COMMENT ON VIEW field_registry_complete IS
'Complete view of field registry with metadata. Grants added to fix permission denied errors during data entry.';

COMMIT;

