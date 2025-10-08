# Migration: Add Survey and Intake Metric Relations

**Date:** 2025-10-07
**Purpose:** Enable live WellPath score updates by linking survey questions and biometric intake metrics to tracked and calculated metrics.

## Overview

This migration adds foreign key relationships to support the real-time scoring feature. These relations allow the system to:

1. **Track which metrics are affected** when a survey question is answered
2. **Link biometrics to daily tracked metrics** (e.g., BMI → weight/height tracking)
3. **Connect compliance screenings** to their relevant questions
4. **Enable calculated metrics** to derive from multiple sources

## Changes Made

### Table: `survey_questions`

Added 2 new foreign key columns:

| Column | Type | References | Purpose |
|--------|------|------------|---------|
| `metric_types_vfinal` | TEXT | `metric_types_vfinal.record_id` | Links to daily tracked metrics that update when this question is answered |
| `screening_compliance_matrix` | TEXT | `screening_compliance_matrix.record_id` | Links to screening compliance rules for preventive care tracking |

**Existing relation preserved:**
- `calculated_metric` → `calculated_metrics_vfinal.record_id` (already existed)

**Example use cases:**
- Question "4.01: How many hours do you sleep?" → links to `metric_types_vfinal` "Sleep Duration"
- Question "10.01: Last dental exam?" → links to `screening_compliance_matrix` "Dental Screening"
- Question "2.11: Daily protein intake?" → links to `calculated_metric` "Daily Protein Consumed"

### Table: `intake_metrics_raw`

Added 2 new foreign key columns:

| Column | Type | References | Purpose |
|--------|------|------------|---------|
| `metric_types_vfinal` | TEXT | `metric_types_vfinal.record_id` | Links to daily tracked metrics derived from this biometric |
| `calculated_metrics_vfinal` | TEXT | `calculated_metrics_vfinal.record_id` | Links to calculated metrics that use this biometric in formulas |

**Example use cases:**
- Biometric "Weight" → links to `metric_types_vfinal` "Weight Tracking"
- Biometric "VO2 Max" → links to `calculated_metric` "Cardiovascular Fitness Score"
- Biometric "HRV" → links to both tracked "HRV Daily" and calculated "Recovery Score"

## Relationship Types

All relationships are:
- **One-to-Many** (not many-to-many, so no junction tables needed)
- **Optional** (`ON DELETE SET NULL` - allows orphaned records)
- **Cascading Updates** (`ON UPDATE CASCADE` - maintains referential integrity)

## Database Diagram

```
survey_questions
    ├── metric_types_vfinal ──→ metric_types_vfinal.record_id
    ├── calculated_metric ────→ calculated_metrics_vfinal.record_id
    └── screening_compliance ──→ screening_compliance_matrix.record_id

intake_metrics_raw
    ├── metric_types_vfinal ───────→ metric_types_vfinal.record_id
    └── calculated_metrics_vfinal ─→ calculated_metrics_vfinal.record_id
```

## Indexes Created

For query performance:
- `idx_survey_questions_metric_types`
- `idx_survey_questions_screening_compliance`
- `idx_intake_metrics_metric_types`
- `idx_intake_metrics_calculated_metrics`

## Live Score Update Flow

### Example: Patient Updates Sleep Duration

1. **Patient logs sleep** → Creates `metric_reading` for "Sleep Duration"
2. **System looks up** → Which calculated metrics depend on this?
3. **Triggers recalculation** → "Sleep Quality Score", "Recovery Score"
4. **Updates pillar scores** → Recalculates "Restorative Sleep" pillar
5. **Notifies mobile app** → Live score update via WebSocket/Push

### Example: Patient Answers Survey Question

1. **Patient answers** → "How many servings of vegetables daily?"
2. **System checks** → Is this linked to a `calculated_metric`?
3. **Finds link** → "Daily Vegetable Servings" calculated metric
4. **Recalculates score** → Updates "Healthful Nutrition" pillar
5. **Updates recommendations** → Adjusts nutrition-related recommendations

### Example: Patient Gets Biometric Reading

1. **Clinician enters** → Patient's VO2 Max = 45 mL/kg/min
2. **System queries** → Which tracked metrics track this?
3. **Finds** → `metric_types_vfinal` "Cardiovascular Fitness"
4. **Also finds** → `calculated_metrics` "Aerobic Capacity Score"
5. **Triggers update** → Both tracked metric and calculated score
6. **Pillar impact** → "Movement + Exercise" score updates

## Migration Verification

Run these queries to verify the migration:

```sql
-- Check survey_questions new columns
SELECT
    record_id,
    question,
    metric_types_vfinal,
    calculated_metric,
    screening_compliance_matrix
FROM survey_questions
WHERE metric_types_vfinal IS NOT NULL
   OR screening_compliance_matrix IS NOT NULL
LIMIT 10;

-- Check intake_metrics_raw new columns
SELECT
    record_id,
    name,
    metric_types_vfinal,
    calculated_metrics_vfinal
FROM intake_metrics_raw
WHERE metric_types_vfinal IS NOT NULL
   OR calculated_metrics_vfinal IS NOT NULL
LIMIT 10;

-- Verify foreign key constraints
SELECT
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_name IN ('survey_questions', 'intake_metrics_raw')
    AND tc.constraint_type = 'FOREIGN KEY'
ORDER BY tc.table_name, kcu.column_name;
```

## Next Steps

### Data Population (Airtable Sync)

After this migration, you need to:

1. **Update Airtable sync scripts** to populate these new columns
2. **Backfill existing records** with appropriate links
3. **Test scoring pipeline** with linked data

### Backend Updates

Update the scoring service to:

1. **Query linked metrics** when calculating scores
2. **Implement change detection** for metric updates
3. **Trigger partial recalculations** when specific metrics change
4. **Cache invalidation** based on metric dependencies

### Mobile App Integration

Enable real-time updates:

1. **WebSocket subscription** for score changes
2. **Optimistic UI updates** when logging data
3. **Push notifications** for milestone achievements
4. **Live progress indicators** during data entry

## Rollback

If needed, run this to rollback:

```sql
-- Remove foreign keys
ALTER TABLE survey_questions
    DROP CONSTRAINT IF EXISTS fk_survey_questions_metric_types,
    DROP CONSTRAINT IF EXISTS fk_survey_questions_screening_compliance;

ALTER TABLE intake_metrics_raw
    DROP CONSTRAINT IF EXISTS fk_intake_metrics_metric_types,
    DROP CONSTRAINT IF EXISTS fk_intake_metrics_calculated_metrics;

-- Remove indexes
DROP INDEX IF EXISTS idx_survey_questions_metric_types;
DROP INDEX IF EXISTS idx_survey_questions_screening_compliance;
DROP INDEX IF EXISTS idx_intake_metrics_metric_types;
DROP INDEX IF EXISTS idx_intake_metrics_calculated_metrics;

-- Remove columns
ALTER TABLE survey_questions
    DROP COLUMN IF EXISTS metric_types_vfinal,
    DROP COLUMN IF EXISTS screening_compliance_matrix;

ALTER TABLE intake_metrics_raw
    DROP COLUMN IF EXISTS metric_types_vfinal,
    DROP COLUMN IF EXISTS calculated_metrics_vfinal;
```

## Impact Analysis

### Performance
- **Minimal impact:** Indexes added for optimal query performance
- **Foreign key checks:** Negligible overhead (< 1ms per insert)
- **Query optimization:** Enables efficient JOIN queries for score calculations

### Data Integrity
- **Maintains referential integrity:** Invalid links prevented
- **Graceful handling:** `SET NULL` on deletion prevents cascade failures
- **Update propagation:** Automatic ID updates if parent records change

### Application Logic
- **Enables new features:** Live score updates, instant feedback
- **Simplifies queries:** Direct relationships instead of complex lookups
- **Improves maintainability:** Clear data lineage and dependencies

## Related Tables

This migration connects to these existing junction tables:
- `calculated_metrics_metric_types` - Links calculated metrics to their source metrics
- `calculated_metrics_survey_questions` - Links calculated metrics to survey questions
- `survey_questions_calculated_metrics` - Links survey questions to calculated metrics

## Documentation

See also:
- `/docs/implementation/data-architecture.md` - Overall data architecture
- `/docs/platform/calculated-metrics.md` - Calculated metrics system
- `/docs/patient-engagement-system/trigger-system.md` - Score update triggers

## Support

For questions or issues:
- Check migration logs in Supabase dashboard
- Review foreign key constraints: `\d survey_questions` and `\d intake_metrics_raw`
- Contact database team if rollback is needed
