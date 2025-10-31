-- Comprehensive migration: Replace pillar_id with pillar_name everywhere
-- pillar_id was a remnant from Airtable, pillar_name is now the primary key

-- =====================================================
-- STEP 1: Add pillar_name to tables that need it and backfill
-- =====================================================

-- data_entry_hierarchy
ALTER TABLE data_entry_hierarchy ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE data_entry_hierarchy d
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE d.pillar_id = p.pillar_id AND d.pillar_name IS NULL;
ALTER TABLE data_entry_hierarchy ALTER COLUMN pillar_name SET NOT NULL;

-- education_pillars
ALTER TABLE education_pillars ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE education_pillars e
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE e.pillar_id = p.pillar_id AND e.pillar_name IS NULL;
ALTER TABLE education_pillars ALTER COLUMN pillar_name SET NOT NULL;

-- pillar_scores
ALTER TABLE pillar_scores ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE pillar_scores ps
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE ps.pillar_id = p.pillar_id AND ps.pillar_name IS NULL;
ALTER TABLE pillar_scores ALTER COLUMN pillar_name SET NOT NULL;

-- pillars_recommendations
ALTER TABLE pillars_recommendations ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE pillars_recommendations pr
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE pr.pillar_id = p.pillar_id AND pr.pillar_name IS NULL;
ALTER TABLE pillars_recommendations ALTER COLUMN pillar_name SET NOT NULL;

-- survey_questions_pillars
ALTER TABLE survey_questions_pillars ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE survey_questions_pillars sq
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE sq.pillar_id = p.pillar_id AND sq.pillar_name IS NULL;
ALTER TABLE survey_questions_pillars ALTER COLUMN pillar_name SET NOT NULL;

-- wellpath_pillars_about
ALTER TABLE wellpath_pillars_about ADD COLUMN IF NOT EXISTS pillar_name TEXT;
UPDATE wellpath_pillars_about w
SET pillar_name = p.pillar_name
FROM pillars_base p
WHERE w.pillar_id = p.pillar_id AND w.pillar_name IS NULL;
ALTER TABLE wellpath_pillars_about ALTER COLUMN pillar_name SET NOT NULL;

-- =====================================================
-- STEP 2: Drop views that depend on pillar_id
-- =====================================================

DROP VIEW IF EXISTS data_entry_hierarchy CASCADE;

-- =====================================================
-- STEP 3: Drop foreign key constraints
-- =====================================================

ALTER TABLE data_entry_hierarchy DROP CONSTRAINT IF EXISTS data_entry_hierarchy_pillar_id_fkey;
ALTER TABLE education_pillars DROP CONSTRAINT IF EXISTS education_pillars_pillar_id_fkey;
ALTER TABLE pillar_scores DROP CONSTRAINT IF EXISTS pillar_scores_pillar_id_fkey;
ALTER TABLE pillars_recommendations DROP CONSTRAINT IF EXISTS pillars_recommendations_pillar_id_fkey;
ALTER TABLE survey_questions_pillars DROP CONSTRAINT IF EXISTS survey_questions_pillars_pillar_id_fkey;
ALTER TABLE wellpath_pillars_about DROP CONSTRAINT IF EXISTS wellpath_pillars_about_pillar_id_fkey;

-- =====================================================
-- STEP 4: Drop pillar_id columns
-- =====================================================

ALTER TABLE data_entry_hierarchy DROP COLUMN IF EXISTS pillar_id;
ALTER TABLE education_pillars DROP COLUMN IF EXISTS pillar_id;
ALTER TABLE pillar_scores DROP COLUMN IF EXISTS pillar_id;
ALTER TABLE pillars_recommendations DROP COLUMN IF EXISTS pillar_id;
ALTER TABLE survey_questions_pillars DROP COLUMN IF EXISTS pillar_id;
ALTER TABLE wellpath_pillars_about DROP COLUMN IF EXISTS pillar_id;

-- =====================================================
-- STEP 5: Add foreign keys on pillar_name
-- =====================================================

ALTER TABLE data_entry_hierarchy
ADD CONSTRAINT data_entry_hierarchy_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE education_pillars
ADD CONSTRAINT education_pillars_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pillar_scores
ADD CONSTRAINT pillar_scores_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE pillars_recommendations
ADD CONSTRAINT pillars_recommendations_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE survey_questions_pillars
ADD CONSTRAINT survey_questions_pillars_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE wellpath_pillars_about
ADD CONSTRAINT wellpath_pillars_about_pillar_name_fkey
FOREIGN KEY (pillar_name) REFERENCES pillars_base(pillar_name)
ON UPDATE CASCADE ON DELETE CASCADE;

-- =====================================================
-- STEP 6: Update pillars_base to use pillar_name as primary key
-- =====================================================

-- Drop old primary key
ALTER TABLE pillars_base DROP CONSTRAINT IF EXISTS pillars_base_pkey;

-- Drop pillar_id column
ALTER TABLE pillars_base DROP COLUMN IF EXISTS pillar_id;

-- Add new primary key on pillar_name
ALTER TABLE pillars_base ADD PRIMARY KEY (pillar_name);

-- =====================================================
-- COMMENTS
-- =====================================================

COMMENT ON TABLE pillars_base IS
'Base pillar definitions. Uses pillar_name as primary key (e.g., "Healthful Nutrition").';
