# App User Fresh Data Setup - Summary

## What Was Done ✅

### 1. Added Cache Invalidation Triggers ✅
**Problem**: When you deleted `patient_data_entries`, the aggregation cache became stale.

**Solution**: Created triggers that **automatically invalidate the cache** when source data is deleted or updated.

**Migration**: `20251025_add_cache_invalidation_triggers.sql`

**Triggers Added**:
- `patient_data_entries`: DELETE and UPDATE triggers
- `patient_biomarker_readings`: DELETE and UPDATE triggers
- `patient_biometric_readings`: DELETE and UPDATE triggers

**Result**: Cache will now auto-clean when data changes! 🎉

### 2. Fixed Instance Calculations Trigger ✅
**Problem**: Trigger used `user_id` (old column name)

**Solution**: Updated to use `patient_id`

**Migration**: `20251025_fix_instance_calculations_trigger.sql`

### 3. Cleaned App User Data ✅
**Migration**: `20251025_clean_app_user_for_fresh_data.sql`

**Deleted**:
- 1,200 data entries
- 177 biomarker readings
- 52 biometric readings
- 130 survey responses

### 4. Generated Fresh Test Data ✅
**Script**: `scripts/generate_comprehensive_test_data.py` (fixed to use `patient_id`)

**Generated**:
- **1,745 data entries**
- 30 days of data (Sept 24 - Oct 23, 2025)
- 23 unique field types
- Realistic protein, sleep, exercise, nutrition data

**User**: test.patient.21@wellpath.com (`8b79ce33-02b8-4f49-8268-3204130efa82`)

## What Still Needs Fixing ⚠️

### Aggregation Stored Procedures
The PostgreSQL stored procedures for aggregations still reference `user_id` instead of `patient_id`:

- `process_field_aggregations()`
- `process_single_aggregation()`
- `calculate_field_aggregation()`

**These need to be updated** before aggregations can run.

## Current Status

```
App User: test.patient.21@wellpath.com
UUID: 8b79ce33-02b8-4f49-8268-3204130efa82

✅ Data entries: 1,745 (30 days)
❌ Aggregation cache: 0 (needs aggregations to run)
```

## Next Steps

### Option 1: Fix Aggregation Procedures (Recommended)

1. **Find and update all stored procedures**:
```sql
-- Find procedures with user_id
SELECT
  p.proname,
  pg_get_functiondef(p.oid)
FROM pg_proc p
WHERE pg_get_functiondef(p.oid) LIKE '%user_id%'
  AND p.proname LIKE '%aggregat%';
```

2. **Update each procedure** to use `patient_id` instead of `user_id`

3. **Run aggregations**:
```bash
python3 scripts/process_all_aggregations_for_user.py
```

### Option 2: Use Edge Function (Alternative)

The edge function `/run-instance-calculations` might already be fixed. You could:

1. **Call the edge function directly** for each data entry
2. **Or trigger it manually** for the test user

### Option 3: Wait for Organic Aggregations

Since you added the trigger that calls the edge function on INSERT, **new data entries will automatically trigger aggregations**. The existing 1,745 entries won't have aggregations until you either:

- Delete and re-insert them (triggers will fire)
- Manually run aggregations (after fixing stored procedures)

## Files Created/Modified

### Migrations:
- ✅ `20251025_add_cache_invalidation_triggers.sql` - Auto-invalidate cache on data changes
- ✅ `20251025_fix_instance_calculations_trigger.sql` - Fixed trigger to use patient_id
- ✅ `20251025_clean_app_user_for_fresh_data.sql` - Cleaned test user data

### Scripts Fixed:
- ✅ `scripts/generate_comprehensive_test_data.py` - Updated to use patient_id
- ⚠️  `scripts/process_all_aggregations_for_user.py` - Updated but depends on broken stored procedures

## Summary

**Good News**:
- ✅ Cache invalidation now works automatically
- ✅ Fresh comprehensive test data generated (1,745 entries, 30 days)
- ✅ Triggers fixed to use `patient_id`
- ✅ Future data inserts will trigger aggregations automatically

**Remaining Work**:
- ⚠️  Stored procedures need `user_id` → `patient_id` updates
- ⚠️  Once fixed, run aggregations to populate cache for existing data

**Quick Fix**: If you just delete and re-insert the test data (using the same script), the INSERT triggers will automatically calculate aggregations! That might be the easiest solution.

```bash
# Quick solution: Delete and regenerate (triggers will fire)
python3 scripts/generate_comprehensive_test_data.py
# This will generate new data AND automatically trigger aggregations via the INSERT trigger
```
