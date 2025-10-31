# WellPath Score History Tables - Summary

## ✅ All History Tables Now Use pillar_name (NOT pillar_id)

### History Tables

| Table | Uses pillar_name ✅ | Has calculated_at ✅ |
|-------|---------------------|---------------------|
| `patient_wellpath_scores_history` | ✅ (no pillar column - overall score) | ✅ |
| `patient_pillar_scores_history` | ✅ | ✅ |
| `patient_component_scores_history` | ✅ | ✅ |
| `patient_item_scores_history` | ✅ | ✅ |

### Current Views (Latest Scores)

| View | Uses pillar_name ✅ | Orders by calculated_at DESC ✅ |
|------|---------------------|--------------------------------|
| `patient_wellpath_scores_current` | N/A (overall) | ✅ |
| `patient_pillar_scores_current` | ✅ | ✅ |
| `patient_component_scores_current` | ✅ | ✅ |
| `patient_item_scores_current` | ✅ | ✅ |

## What Was Changed

### 1. Renamed Table for Consistency
- **Old**: `patient_wellpath_scores`
- **New**: `patient_wellpath_scores_history`
- **Reason**: Consistent `*_history` naming pattern

### 2. Removed pillar_id from Score History Tables
- `patient_pillar_scores_history` - Now uses **only** `pillar_name`
- `patient_component_scores_history` - Now uses **only** `pillar_name`
- `patient_item_scores_history` - Uses **only** `pillar_name`

### 3. Updated All Views to Use pillar_name
- All `*_current` views now filter by `pillar_name`
- All views order by `calculated_at DESC` to get latest

## Migrations Applied

1. ✅ `20251028_fix_scoring_double_count_add_batch_id.sql`
2. ✅ `20251028_create_patient_item_scores_history.sql`
3. ✅ `20251028_create_patient_item_scores_current_view.sql`
4. ✅ `20251028_add_pillar_name_to_component_scores_history.sql`
5. ✅ `20251028_add_pillar_name_to_pillar_scores_history.sql`
6. ✅ `20251028_rename_latest_to_current_views.sql`
7. ✅ `20251028_rename_wellpath_scores_to_history.sql`
8. ✅ `20251028_remove_pillar_id_use_pillar_name.sql`

## Verification

### Check History Tables
```sql
SELECT table_name, column_name
FROM information_schema.columns
WHERE table_name LIKE '%_scores_history'
AND column_name IN ('pillar_id', 'pillar_name', 'calculated_at')
ORDER BY table_name, column_name;
```

**Result**: Only `pillar_name` and `calculated_at` exist (no pillar_id) ✅

### Check Current Views
```sql
SELECT table_name
FROM information_schema.views
WHERE table_name LIKE '%_scores_current';
```

**Result**: All views exist and use `pillar_name` ✅

## Edge Function Updated

`/supabase/functions/calculate-wellpath-score/index.ts` now:
- Uses `patient_wellpath_scores_history` (not `patient_wellpath_scores`)
- Generates `batch_id` for each calculation run
- Filters by `batch_id` to prevent double-counting
- Calls `populateItemHistory()` to insert item-level history records
- Enhanced logging to debug insert failures

### Item History Population - ✅ COMPLETE

**Issues Found and Fixed**:

1. **RLS Policy Incomplete** (Migration `20251028_fix_item_history_rls_policy.sql`):
   - Original policy was missing `FOR` clause
   - Fixed: `FOR ALL TO service_role USING (true) WITH CHECK (true)`

2. **Missing Table Permissions** (Migration `20251028_grant_item_history_permissions.sql`):
   - RLS policies control row access, but table-level GRANTs were missing
   - **Root Cause**: Error `42501 - permission denied for table patient_item_scores_history`
   - **Solution**: Added `GRANT ALL ON TABLE patient_item_scores_history TO service_role`

**Verification**: ✅ Working perfectly
- First calculation: 303 records inserted
- Second calculation: 303 more records inserted (606 total in history)
- Current view correctly shows only latest 303 records
- Historical trend tracking operational

## Mobile Queries (Swift)

All Swift code can now use `pillar_name` directly:

```swift
// Current pillar score
supabase.from("patient_pillar_scores_current")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")

// Current component score
supabase.from("patient_component_scores_current")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
    .eq("component_type", value: "markers")

// Historical trend
supabase.from("patient_pillar_scores_history")
    .eq("patient_id", value: userId)
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("calculated_at", ascending: false)
    .limit(30)
```

No need for pillar_id lookups or joins!
