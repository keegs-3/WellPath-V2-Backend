# Foreign Key Best Practice: Readable Keys vs UUIDs

## The Problem

Many tables have both:
- A **UUID `id`** column (technical primary key)
- A **readable identifier** column (e.g., `period_id`, `metric_id`, `screen_key`)

When creating foreign keys, it's often better to reference the **readable identifier** instead of the UUID for:
- **Debugging ease** - See "7d" instead of "82130d4a-4d7f-4fce-bdec-5cc68edc2ffa"
- **Query readability** - JOINs are more intuitive
- **Data migration** - Easier to understand and verify

## Example: aggregation_periods

**Before** (UUID FK):
```sql
aggregation_periods:
  - id: uuid (PK)
  - period_id: text (unique, readable like "7d", "30d")

aggregation_metrics_periods:
  - period_id: uuid → references aggregation_periods.id
```

**After** (Readable FK):
```sql
aggregation_periods:
  - id: uuid (PK)
  - period_id: text (unique, readable like "7d", "30d")

aggregation_metrics_periods:
  - period_id: text → references aggregation_periods.period_id
```

## Migration Pattern

### Step-by-Step Process

```sql
BEGIN;

-- 1. Add temporary column for readable value
ALTER TABLE child_table
ADD COLUMN readable_id_temp TEXT;

-- 2. Populate with readable values
UPDATE child_table c
SET readable_id_temp = p.readable_id
FROM parent_table p
WHERE c.old_uuid_fk = p.id;

-- 3. Verify all rows updated
DO $$
DECLARE
    total_count INTEGER;
    updated_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count FROM child_table;
    SELECT COUNT(*) INTO updated_count FROM child_table WHERE readable_id_temp IS NOT NULL;

    IF total_count != updated_count THEN
        RAISE EXCEPTION 'Migration failed: % total but only % updated', total_count, updated_count;
    END IF;
END $$;

-- 4. Drop old FK constraint
ALTER TABLE child_table
DROP CONSTRAINT old_fk_constraint_name;

-- 5. Drop old UUID column
ALTER TABLE child_table
DROP COLUMN old_uuid_fk;

-- 6. Rename temp column
ALTER TABLE child_table
RENAME COLUMN readable_id_temp TO readable_id;

-- 7. Make it NOT NULL (if appropriate)
ALTER TABLE child_table
ALTER COLUMN readable_id SET NOT NULL;

-- 8. Create new FK to readable column
ALTER TABLE child_table
ADD CONSTRAINT new_fk_constraint_name
FOREIGN KEY (readable_id) REFERENCES parent_table(readable_id)
ON DELETE CASCADE;

-- 9. Create index for performance
CREATE INDEX idx_child_table_readable_id
ON child_table(readable_id);

COMMIT;
```

## When to Use Readable Keys

### ✅ Use Readable Keys When:
1. **Debugging frequently** - You regularly query these tables
2. **Human-readable values** - The key is short and meaningful ("7d", "core_care")
3. **Stable identifiers** - The readable key won't change
4. **Natural key exists** - The readable value is a natural business key
5. **Small cardinality** - Relatively few distinct values

### ❌ Stick with UUIDs When:
1. **Generated identifiers** - No natural readable key exists
2. **Large cardinality** - Millions of records (UUIDs are more efficient)
3. **Frequent changes** - The readable value might change
4. **External systems** - Integration with systems that use UUIDs
5. **Distributed systems** - Need UUID generation without coordination

## Examples in WellPath

### Good Candidates for Readable Keys

```sql
-- Aggregation periods: "7d", "30d", "90d", "6month", "yearly"
aggregation_periods.period_id (text) vs .id (uuid)
✅ Use period_id - Very readable, stable, frequently debugged

-- Display screens: "dashboard", "sleep_detail", "metrics_overview"
display_screens.screen_key (text) vs .id (uuid)
✅ Use screen_key - Human-readable, natural key, frequently referenced

-- Display metrics: "sleep_duration", "steps", "heart_rate"
display_metrics.metric_id (text) vs .id (uuid)
✅ Use metric_id - Natural key, stable, frequently queried

-- WellPath Score sections: "behaviors_substances_alcohol"
wellpath_score_display_sections.section_key (text) vs .id (uuid)
✅ Use section_key - Hierarchical, descriptive, stable

-- Pillars: "Core Care", "Healthful Nutrition"
wellpath_scoring_pillars.pillar_name (text) vs .id (uuid)
✅ Use pillar_name - Fixed set (7 pillars), frequently referenced
```

### Keep UUIDs

```sql
-- Patient records
patient_details.user_id (uuid)
✅ Keep UUID - Generated per patient, millions of records

-- Biomarker readings
patient_biomarker_readings.id (uuid)
✅ Keep UUID - Millions of readings, no natural key

-- Event instances
patient_events.id (uuid)
✅ Keep UUID - Time-series data, large volume
```

## Benefits of Readable Keys

### Before (UUID FK):
```sql
SELECT
    amp.agg_metric_id,
    amp.period_id,  -- Shows: 82130d4a-4d7f-4fce-bdec-5cc68edc2ffa
    ap.period_name
FROM aggregation_metrics_periods amp
JOIN aggregation_periods ap ON amp.period_id = ap.id;
```

**Query results**:
```
agg_metric_id | period_id                          | period_name
--------------|------------------------------------|--------------
sleep_score   | 82130d4a-4d7f-4fce-bdec-5cc68edc2ffa | 7 Day
steps         | 82130d4a-4d7f-4fce-bdec-5cc68edc2ffa | 7 Day
```

❌ Hard to debug, can't tell what period without JOIN

### After (Readable FK):
```sql
SELECT
    amp.agg_metric_id,
    amp.period_id,  -- Shows: "7d"
    ap.period_name
FROM aggregation_metrics_periods amp
JOIN aggregation_periods ap ON amp.period_id = ap.period_id;
```

**Query results**:
```
agg_metric_id | period_id | period_name
--------------|-----------|-------------
sleep_score   | 7d        | 7 Day
steps         | 7d        | 7 Day
```

✅ Immediately clear, no JOIN needed to understand data

## Implementation Checklist

When changing UUID FK to readable FK:

- [ ] Verify parent table has unique constraint on readable column
- [ ] Create migration with transaction (BEGIN/COMMIT)
- [ ] Add temporary column
- [ ] Populate with readable values
- [ ] Verify 100% of rows updated (fail fast if not)
- [ ] Drop old FK constraint
- [ ] Drop old UUID column
- [ ] Rename temp column
- [ ] Set NOT NULL constraint
- [ ] Create new FK to readable column
- [ ] Create index on FK column
- [ ] Add comment documenting the change
- [ ] Test queries work correctly
- [ ] Update application code if needed

## Finding Candidates

Query to find tables with both UUID id and readable identifier:

```sql
SELECT
    t.table_name,
    string_agg(c.column_name, ', ') as columns
FROM information_schema.tables t
JOIN information_schema.columns c ON t.table_name = c.table_name
WHERE t.table_schema = 'public'
    AND t.table_type = 'BASE TABLE'
    AND c.column_name IN ('id', 'period_id', 'metric_id', 'screen_key', 'section_key', 'pillar_name')
GROUP BY t.table_name
HAVING COUNT(*) > 1
ORDER BY t.table_name;
```

Look for tables that have both:
- An `id` column (UUID)
- A `*_id`, `*_key`, or `*_name` column (text)

Then check if child tables reference the UUID instead of the readable key.

---

**Best Practice**: Always prefer readable natural keys for configuration tables with small cardinality. Reserve UUIDs for large transaction tables.
