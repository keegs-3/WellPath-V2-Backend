# RLS Quick Reference for Mobile Team

**Status**: ✅ All Fixed (2025-10-23)

---

## What Was The Problem?

Several tables had Row Level Security (RLS) enabled but **no policies**, which blocked all access:
- `data_entry_fields` - Blocked
- `aggregation_metrics_calculation_types` - Blocked

Other tables had no RLS at all, allowing unrestricted access to user data.

---

## What Was Fixed?

✅ **All tables now have proper RLS policies**
✅ **Mobile app can query all data it needs**
✅ **User data is properly secured (users can only see their own data)**
✅ **Metadata tables are publicly readable**

---

## Mobile App: No Changes Needed

Your queries will just work now. The Supabase client automatically:
1. Sends your JWT token with each request
2. Sets `auth.uid()` to the logged-in user's ID
3. RLS policies automatically filter data based on user

---

## Example: What Happens Automatically

### Your Mobile Query (Swift/Kotlin)
```swift
// Mobile app code - no changes needed
let result = await supabase
    .from("aggregation_results_cache")
    .select("value, period_start")
    .eq("agg_metric_id", "AGG_PROTEIN_GRAMS")
    .eq("period_type", "hourly")
    .execute()
```

### What Supabase Does Behind The Scenes
```sql
-- Automatically adds user filter based on JWT token
SELECT value, period_start
FROM aggregation_results_cache
WHERE agg_metric_id = 'AGG_PROTEIN_GRAMS'
  AND period_type = 'hourly'
  AND user_id = auth.uid()  -- ← Added automatically by RLS
```

**Result**: You only get data for the logged-in user. No extra code needed.

---

## Tables You Can Query

### Metadata Tables (Public Read)
No user filtering needed - everyone can read these:
- `parent_display_metrics`
- `child_display_metrics`
- `display_screens_parent_metrics`
- `parent_child_display_metrics_aggregations`
- `aggregation_metrics`
- `aggregation_metrics_periods`
- `aggregation_metrics_dependencies`
- `aggregation_metrics_calculation_types`
- `data_entry_fields`

### User Data Tables (Automatic User Filtering)
RLS automatically filters to logged-in user:
- `patient_data_entries` - Users see only their own entries
- `aggregation_results_cache` - Users see only their own aggregations

---

## Common Errors Fixed

### ❌ Before (Error)
```
ERROR: permission denied for table data_entry_fields
```

### ✅ After (Works)
```swift
let fields = await supabase
    .from("data_entry_fields")
    .select("*")
    .execute()
// Returns field configurations
```

---

### ❌ Before (Security Risk)
```sql
-- Could see ANY user's data!
SELECT * FROM patient_data_entries;
```

### ✅ After (Secure)
```sql
-- Only sees logged-in user's data
SELECT * FROM patient_data_entries;
-- RLS automatically adds: WHERE user_id = auth.uid()
```

---

## Testing

All queries tested and verified:
- ✅ Parent card queries work
- ✅ Child section queries work
- ✅ Aggregation cache queries work
- ✅ User data is properly filtered
- ✅ Metadata tables are readable

---

## Need Help?

If you get permission errors:
1. Verify user is authenticated (JWT token valid)
2. Check table name is correct
3. Contact backend with error message

---

## Summary

**You don't need to do anything different!**

Your existing queries will work now. RLS policies are transparent to your app - they just enforce security automatically.

---

**Applied**: 2025-10-23 23:55 UTC
**Migration**: `20251023_fix_all_rls_policies.sql`
**Status**: ✅ Production Ready
