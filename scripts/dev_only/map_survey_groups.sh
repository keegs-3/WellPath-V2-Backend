#!/bin/bash
# Map survey_questions_base to group_id from CSV

PGPASSWORD='qLa4sE9zV1yvxCP4' /opt/homebrew/bin/psql -h aws-1-us-west-1.pooler.supabase.com -p 6543 -U postgres.csotzmardnvrpdhlogjm -d postgres <<'SQL'

-- Create a temporary table to hold CSV data
CREATE TEMP TABLE temp_survey_mapping (
    question_id TEXT,
    question_text TEXT,
    section_id TEXT,
    category_id TEXT,
    group_id TEXT
);

-- Copy CSV data into temp table
\copy temp_survey_mapping FROM '/Users/keegs/Documents/survey_categories_mapped.csv' WITH (FORMAT csv, HEADER true);

-- Show loading stats
SELECT 'CSV rows loaded:', COUNT(*) FROM temp_survey_mapping;

-- Verify group_ids exist in survey_groups
SELECT
    'Invalid group_ids in CSV:' as status,
    COUNT(DISTINCT tsm.group_id) as count
FROM temp_survey_mapping tsm
LEFT JOIN survey_groups sg ON tsm.group_id = sg.group_id
WHERE sg.group_id IS NULL;

-- Show sample of invalid group_ids if any exist
SELECT DISTINCT tsm.group_id as invalid_group_id
FROM temp_survey_mapping tsm
LEFT JOIN survey_groups sg ON tsm.group_id = sg.group_id
WHERE sg.group_id IS NULL
LIMIT 10;

-- Update survey_questions_base with group_id from CSV
WITH update_stats AS (
    UPDATE survey_questions_base sqb
    SET group_id = tsm.group_id
    FROM temp_survey_mapping tsm
    WHERE sqb.question_number = tsm.question_id
        AND tsm.group_id IN (SELECT group_id FROM survey_groups)
    RETURNING 1
)
SELECT 'Questions updated:', COUNT(*) FROM update_stats;

-- Show questions that didn't match
SELECT
    'Unmatched questions:' as status,
    COUNT(*) as count
FROM survey_questions_base sqb
LEFT JOIN temp_survey_mapping tsm ON sqb.question_number = tsm.question_id
WHERE tsm.question_id IS NULL;

-- Show sample of unmatched questions
SELECT sqb.question_number, sqb.question_text
FROM survey_questions_base sqb
LEFT JOIN temp_survey_mapping tsm ON sqb.question_number = tsm.question_id
WHERE tsm.question_id IS NULL
LIMIT 10;

-- Show final stats
SELECT
    'Total questions:' as status,
    COUNT(*) as count
FROM survey_questions_base;

SELECT
    'Questions with group_id:' as status,
    COUNT(*) as count
FROM survey_questions_base
WHERE group_id IS NOT NULL;

SQL
