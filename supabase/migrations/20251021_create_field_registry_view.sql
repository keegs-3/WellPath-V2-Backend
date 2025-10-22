-- =====================================================
-- Create Field Registry View
-- =====================================================
-- Helpful view for working with field registry
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

CREATE OR REPLACE VIEW field_registry_complete AS
SELECT
  fr.field_id,
  fr.field_name,
  fr.display_name,
  fr.description,
  fr.field_source,
  fr.unit,
  fr.is_active,

  -- Data entry field info
  def.field_type,
  def.data_type,
  def.validation_config,
  def.supports_healthkit_sync,
  def.healthkit_identifier,

  -- Instance calculation info
  ic.calculation_method,
  ic.calculation_config,

  -- Metadata
  fr.created_at,
  fr.updated_at

FROM field_registry fr
LEFT JOIN data_entry_fields def ON fr.data_entry_field_id = def.field_id
LEFT JOIN instance_calculations ic ON fr.instance_calculation_id = ic.calc_id
ORDER BY fr.field_source, fr.field_name;

COMMENT ON VIEW field_registry_complete IS
'Complete view of field registry with metadata from both data_entry_fields and instance_calculations';

COMMIT;
