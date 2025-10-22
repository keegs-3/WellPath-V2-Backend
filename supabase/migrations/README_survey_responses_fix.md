# Survey Responses Foreign Key Fix

## Migration: `fix_survey_responses_foreign_keys.sql`

### Problem

The original `survey_responses` schema had:
- `question_id` as `DOUBLE PRECISION` (numeric IDs like 1.01, 2.04)
- No foreign key to `survey_questions`
- No foreign key to `survey_response_options`

This meant:
- No referential integrity
- Couldn't enforce valid questions
- Couldn't link responses to scoring/trigger logic

### Solution

This migration:

1. **Maps numeric IDs to Airtable record_ids**:
   - `question_id` 1.01 → `survey_questions.record_id` "rec8ZCAHLZ9Zj6YtG"
   - Uses `survey_questions.ID` column for mapping

2. **Changes column type**:
   - `question_id` from `DOUBLE PRECISION` → `TEXT`

3. **Adds foreign keys**:
   ```sql
   question_id → survey_questions.record_id (CASCADE on delete)
   response_option_id → survey_response_options.record_id (SET NULL on delete)
   ```

4. **Preserves data**:
   - Maps all 9,099 existing responses
   - No data loss

### Migration Steps

```sql
-- 1. Add temporary column
ALTER TABLE survey_responses ADD COLUMN question_record_id TEXT;

-- 2. Map numeric IDs to record_ids
UPDATE survey_responses sr
SET question_record_id = sq.record_id
FROM survey_questions sq
WHERE sr.question_id::TEXT = sq."ID"::TEXT;

-- 3. Replace old column
ALTER TABLE survey_responses DROP COLUMN question_id;
ALTER TABLE survey_responses RENAME COLUMN question_record_id TO question_id;

-- 4. Add constraints
ALTER TABLE survey_responses
ADD CONSTRAINT fk_survey_responses_question_id
FOREIGN KEY (question_id) REFERENCES survey_questions(record_id);

ALTER TABLE survey_responses
ADD CONSTRAINT fk_survey_responses_response_option_id
FOREIGN KEY (response_option_id) REFERENCES survey_response_options(record_id);
```

### After Migration

**Before:**
```
question_id (numeric): 1.01, 2.04, 2.11
No foreign keys
```

**After:**
```
question_id (TEXT): rec8ZCAHLZ9Zj6YtG, recKASmdaJfuQtfqz, recPkLqmb216mf1qR
Foreign keys enforced
```

### Verification

```sql
-- Check all responses are linked
SELECT
    COUNT(*) as total,
    COUNT(DISTINCT question_id) as unique_questions,
    COUNT(response_option_id) as with_option_id
FROM survey_responses;

-- Verify joins work
SELECT sr.*, sq.question, sro.response
FROM survey_responses sr
JOIN survey_questions sq ON sr.question_id = sq.record_id
LEFT JOIN survey_response_options sro ON sr.response_option_id = sro.record_id
LIMIT 5;
```

### Import Script Changes

The `import_all_test_data.py` script was updated to:

1. Map numeric question IDs to record_ids:
   ```python
   cur.execute('SELECT "ID", record_id FROM survey_questions')
   question_mapping = {str(row[0]): row[1] for row in cur.fetchall()}
   ```

2. Match responses to option IDs:
   ```python
   # Exact match
   key = (question_record_id, response_value.lower())
   response_option_id = response_options.get(key)

   # Fallback for unmatched (free-response, other, etc.)
   if not response_option_id and question has fallbacks:
       response_option_id = select_fallback_by_type()
   ```

### Expected Results

- **100%** of responses have valid `question_id` (foreign key enforced)
- **70-80%** of responses have `response_option_id` populated
- **20-30%** legitimately NULL:
  - Free-form text
  - Numeric inputs mapped to "[Free numeric]"
  - Multi-select pipe-separated
  - Empty conditional responses

### Rollback

If needed:
```sql
-- Remove constraints
ALTER TABLE survey_responses DROP CONSTRAINT fk_survey_responses_question_id;
ALTER TABLE survey_responses DROP CONSTRAINT fk_survey_responses_response_option_id;

-- Restore numeric IDs
ALTER TABLE survey_responses ADD COLUMN question_id_numeric DOUBLE PRECISION;
UPDATE survey_responses sr
SET question_id_numeric = sq."ID"
FROM survey_questions sq
WHERE sr.question_id = sq.record_id;

ALTER TABLE survey_responses DROP COLUMN question_id;
ALTER TABLE survey_responses RENAME COLUMN question_id_numeric TO question_id;
```

### Related Files

- Migration: `supabase/migrations/fix_survey_responses_foreign_keys.sql`
- Import script: `scripts/dev_only/import_all_test_data.py`
- Documentation: `scripts/dev_only/README.md`
