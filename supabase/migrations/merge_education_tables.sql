-- Merge education_modules with education_articles
-- This migration unifies the two education tables into one

-- Step 1: Drop the newly created education_articles table (only has placeholder data)
DROP TABLE IF EXISTS education_articles CASCADE;

-- Step 2: Rename education_modules to education_articles
ALTER TABLE education_modules RENAME TO education_articles;

-- Step 3: Add new columns needed for engagement tracking
ALTER TABLE education_articles
    ADD COLUMN IF NOT EXISTS content_url TEXT,
    ADD COLUMN IF NOT EXISTS min_engagement_seconds INTEGER DEFAULT 30;

-- Step 4: Rename record_id to id for consistency (optional, but cleaner)
-- Note: This will update all foreign key references automatically
ALTER TABLE education_articles RENAME COLUMN record_id TO id;

-- Step 5: Update education_engagement table to use proper foreign key
-- The table already exists, just ensure it references the right table
ALTER TABLE education_engagement
    DROP CONSTRAINT IF EXISTS education_engagement_article_id_fkey,
    ADD CONSTRAINT education_engagement_article_id_fkey
        FOREIGN KEY (article_id) REFERENCES education_articles(id) ON DELETE CASCADE;

-- Step 6: Create index on pillar for faster queries (if not exists)
CREATE INDEX IF NOT EXISTS idx_education_articles_pillar ON education_articles(pillars);

-- Comments
COMMENT ON TABLE education_articles IS 'Unified education content table. Tracks articles/modules available to patients. Each viewed article contributes 2.5% to pillar score (max 10% per pillar)';
COMMENT ON COLUMN education_articles.content_url IS 'URL or path to article content (PDF, markdown, external link)';
COMMENT ON COLUMN education_articles.min_engagement_seconds IS 'Minimum time (seconds) to count as "viewed" for education score';
COMMENT ON COLUMN education_articles.delivery_method IS 'How content is delivered (article, video, interactive, etc.)';
COMMENT ON COLUMN education_articles.media_format IS 'Format of media (text, video, audio, etc.)';
