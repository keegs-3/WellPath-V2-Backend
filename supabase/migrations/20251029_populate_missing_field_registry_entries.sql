-- Populate field_registry with all data_entry_fields that are missing
-- This ensures patient_data_entries FK constraint can be satisfied

INSERT INTO field_registry (
    field_id,
    field_name,
    display_name,
    description,
    field_source,
    data_entry_field_id,
    unit,
    is_active
)
SELECT
    def.field_id,
    def.field_name,
    def.display_name,
    COALESCE(def.description, 'User input field for ' || def.display_name),
    'user_input' as field_source,
    def.field_id as data_entry_field_id,
    def.unit,
    def.is_active
FROM data_entry_fields def
LEFT JOIN field_registry fr ON def.field_id = fr.data_entry_field_id
WHERE fr.field_id IS NULL
  AND def.is_active = true
ON CONFLICT (field_id) DO NOTHING;

-- Verify the sync
SELECT
    'After sync' as status,
    COUNT(*) as field_registry_count
FROM field_registry;

SELECT
    'Missing fields' as status,
    COUNT(*) as missing_count
FROM data_entry_fields def
LEFT JOIN field_registry fr ON def.field_id = fr.data_entry_field_id
WHERE fr.field_id IS NULL
  AND def.is_active = true;
