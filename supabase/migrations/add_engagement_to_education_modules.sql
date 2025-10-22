-- Add engagement tracking to existing education_modules table
-- This preserves all existing relationships and adds new functionality

-- Step 1: Drop the temporary education_articles table
DROP TABLE IF EXISTS education_articles CASCADE;

-- Step 2: Add engagement tracking columns to education_modules
ALTER TABLE education_modules
    ADD COLUMN IF NOT EXISTS min_engagement_seconds INTEGER DEFAULT 30;

COMMENT ON COLUMN education_modules.min_engagement_seconds IS 'Minimum time (seconds) to count as "viewed" for education score';

-- Step 3: Update education_engagement to reference education_modules properly
-- Change article_id to module_id for consistency
ALTER TABLE education_engagement
    RENAME COLUMN article_id TO module_id;

-- Update foreign key
ALTER TABLE education_engagement
    DROP CONSTRAINT IF EXISTS education_engagement_article_id_fkey,
    ADD CONSTRAINT education_engagement_module_id_fkey
        FOREIGN KEY (module_id) REFERENCES education_modules(record_id) ON DELETE CASCADE;

-- Step 4: Create a view called education_articles for API compatibility
CREATE OR REPLACE VIEW education_articles AS
SELECT
    record_id as id,
    title,
    description,
    pillars as pillar,  -- Note: this is a comma-separated list in Airtable
    delivery_method,
    media_format,
    intake_markers,
    intake_metrics,
    tags,
    trigger_condition,
    min_engagement_seconds,
    created,
    last_modified
FROM education_modules;

COMMENT ON VIEW education_articles IS 'API-friendly view of education_modules for engagement tracking';

-- Step 5: Update indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_education_modules_pillars ON education_modules(pillars);
CREATE INDEX IF NOT EXISTS idx_education_engagement_module_pillar ON education_engagement(module_id, pillar);

-- Comments
COMMENT ON TABLE education_modules IS 'Education content catalog from Airtable. Each module can contribute to education score (2.5% per module, max 10% per pillar)';
COMMENT ON TABLE education_engagement IS 'Tracks patient engagement with education modules for scoring';
