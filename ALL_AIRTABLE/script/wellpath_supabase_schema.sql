-- WellPath Supabase Schema
-- Generated from cleaned Airtable field names
-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =

-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =
-- INDEXES
-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =-- =

-- Primary lookups
CREATE INDEX idx_recommendations_v2_id ON recommendations_v2(id);
CREATE INDEX idx_metric_types_identifier ON metric_types_vfinal(identifier);
CREATE INDEX idx_trigger_conditions_id ON trigger_conditions(id);

-- Array searches for linked records
CREATE INDEX idx_recommendations_markers ON recommendations_v2 USING GIN(primary_markers);
CREATE INDEX idx_trigger_nudges ON trigger_conditions USING GIN(nudges);