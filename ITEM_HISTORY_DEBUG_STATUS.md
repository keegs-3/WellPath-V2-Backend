# Patient Item Scores History - ✅ COMPLETE AND WORKING

## Summary

Item-level history tracking is now **fully operational**. The system successfully:
- Tracks all 303 scored items per calculation run
- Maintains complete history across multiple calculation batches
- Provides current view showing only latest scores for mobile app
- Enables historical trend analysis and charting

## ✅ Completed

### 1. Schema Created
- Table `patient_item_scores_history` created with all necessary columns
- Supports all item types: biomarkers, biometrics, survey questions, functions, education
- Tracks per-pillar contributions (items on multiple pillars get multiple rows)
- Includes `batch_id` for linking to calculation runs
- Includes `calculated_at` timestamp for history tracking

### 2. View Created
- `patient_item_scores_current` view shows latest scores per patient-pillar-component-item
- Uses `DISTINCT ON` to get most recent calculation
- Ready for Swift mobile queries

### 3. RLS Policies Fixed
- **Problem Found**: Original service role policy was incomplete
  ```sql
  -- BAD (missing FOR clause):
  CREATE POLICY "Service role can manage item score history"
      ON patient_item_scores_history
      USING (auth.role() = 'service_role');
  ```

- **Fixed** (`20251028_fix_item_history_rls_policy.sql`):
  ```sql
  -- GOOD:
  CREATE POLICY "Service role can manage item score history"
      ON patient_item_scores_history
      FOR ALL
      TO service_role
      USING (true)
      WITH CHECK (true);
  ```

### 4. Manual Insert Test Passed ✅
- Created `/scripts/test_item_history_insert.py`
- Successfully inserts test records directly via PostgreSQL
- Proves schema is correct and constraints work

### 5. Edge Function Enhanced
- Added `populateItemHistory()` function to insert item history
- Function correctly:
  - Maps item types to component types
  - Extracts item identifiers (biomarker_name, biometric_name, etc.)
  - Calculates scores and contributions
  - Builds history records for insert

- Enhanced logging:
  ```typescript
  console.log(`Attempting to insert ${historyRecords.length} item history records`)
  // ... insert ...
  if (error) {
    console.error('❌ Error inserting item history:', JSON.stringify(error, null, 2))
    console.error('First record that failed:', JSON.stringify(historyRecords[0], null, 2))
  } else {
    console.log(`✅ Successfully inserted ${data?.length || historyRecords.length} item history records`)
  }
  ```

## ✅ Issue Resolved

### Root Cause: Missing Table-Level Permissions

**Problem**: Edge function was getting error `42501 - permission denied for table patient_item_scores_history`

**Why**: RLS policies control **row-level** access, but **table-level** GRANT permissions were missing. The service_role needed explicit GRANT to perform INSERT operations.

**Solution**: Applied migration `20251028_grant_item_history_permissions.sql`:
```sql
GRANT ALL ON TABLE patient_item_scores_history TO service_role;
```

### Verification Steps Taken

1. **Confirmed RLS policy applied**:
   ```sql
   DROP POLICY IF EXISTS "Service role can manage item score history" ON patient_item_scores_history;
   CREATE POLICY "Service role can manage item score history"
       ON patient_item_scores_history FOR ALL TO service_role USING (true) WITH CHECK (true);
   ```
   ✅ Applied successfully

2. **Confirmed edge function deployed**:
   ```bash
   supabase functions deploy calculate-wellpath-score
   ```
   ✅ Deployed successfully

3. **Triggered scoring calculation**:
   ```bash
   curl -X POST 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score' ...
   {"success":true,"patient_id":"...","items_scored":303,...}
   ```
   ✅ Scoring succeeds

4. **Checked database**:
   ```sql
   SELECT COUNT(*) FROM patient_item_scores_history
   WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82';
   -- Result: 0
   ```
   ❌ No records

### Final Verification

After applying the GRANT permissions fix:

**Test 1: First Calculation**
```sql
SELECT COUNT(*), COUNT(DISTINCT batch_id)
FROM patient_item_scores_history
WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82';

-- Result: 303 records, 1 batch ✅
```

**Test 2: Second Calculation (History Test)**
```sql
-- History table: stores ALL calculations
SELECT COUNT(*), COUNT(DISTINCT batch_id)
FROM patient_item_scores_history
WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82';

-- Result: 606 records, 2 batches ✅

-- Current view: shows ONLY latest
SELECT COUNT(*), COUNT(DISTINCT batch_id)
FROM patient_item_scores_current
WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82';

-- Result: 303 records, 1 batch ✅
```

**Sample Data Verification**:
```sql
SELECT pillar_name, component_type, item_type,
       COALESCE(biomarker_name, biometric_name, question_number::text) as item,
       item_percentage
FROM patient_item_scores_current
WHERE patient_id = '8b79ce33-02b8-4f49-8268-3204130efa82'
LIMIT 5;

-- Result: Shows correct pillar names, component types, item identifiers, and percentages ✅
```

## Files Modified

1. `/supabase/migrations/20251028_create_patient_item_scores_history.sql` - Table schema
2. `/supabase/migrations/20251028_create_patient_item_scores_current_view.sql` - Current view
3. `/supabase/migrations/20251028_fix_item_history_rls_policy.sql` - RLS policy fix
4. `/supabase/migrations/20251028_grant_item_history_permissions.sql` - **CRITICAL FIX** - Table permissions
5. `/supabase/functions/calculate-wellpath-score/index.ts` - Edge function with populateItemHistory()
6. `/scripts/test_item_history_insert.py` - Manual insert test script

## Key Lessons Learned

1. **RLS vs Table Permissions**: RLS policies control row-level access, but table-level GRANT statements are still required for roles to perform operations (INSERT, UPDATE, DELETE, SELECT)

2. **Service Role Needs Explicit Grants**: Even though the service_role is powerful, it still needs explicit GRANT permissions on tables created after the fact

3. **Debugging Approach**:
   - Enhanced logging in edge function revealed the exact error
   - Manual insert test proved schema was correct
   - Dashboard logs showed permission denied error with code 42501
   - Fix was straightforward once root cause was identified
