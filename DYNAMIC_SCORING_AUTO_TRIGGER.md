# Dynamic Scoring - Automatic Trigger Setup

**Date**: 2025-10-22
**Status**: ✅ Trigger Created - Needs Configuration

---

## Automatic Flow

```
Patient adds data
  ↓
patient_data_entries (INSERT)
  ↓
Instance calculations run (if needed)
  ↓
aggregation_results_cache (INSERT/UPDATE) 🔔 TRIGGER HERE!
  ↓
Database trigger fires: trigger_dynamic_scoring_update()
  ↓
┌─────────────────────┴─────────────────────┐
↓                                           ↓
HTTP POST                                   HTTP POST
/functions/v1/update-biometric-scores       /functions/v1/update-survey-scores
  ↓                                           ↓
patient_biometric_readings (UPSERT)         patient_survey_responses (UPDATE)
  ↓                                           ↓
└─────────────────────┬─────────────────────┘
  ↓
Mobile app + Scorer see updated data immediately!
  ↓
WellPath Score updates automatically! ✅
```

---

## Database Trigger Created

**File**: `supabase/migrations/20251022_create_dynamic_scoring_triggers.sql`

**Trigger**: `trigger_dynamic_scoring` on `aggregation_results_cache`

**Function**: `trigger_dynamic_scoring_update()`

**When**: AFTER INSERT OR UPDATE on `aggregation_results_cache`

**What it does**:
1. Gets `user_id` from the updated row
2. Makes async HTTP POST to `update-biometric-scores` edge function
3. Makes async HTTP POST to `update-survey-scores` edge function
4. Returns immediately (doesn't wait for edge functions to complete)

---

## Configuration Required

The trigger needs 2 database configuration variables:

```sql
-- Set in Supabase SQL Editor or via migration:

ALTER DATABASE postgres
SET app.settings.supabase_url = 'https://csotzmardnvrpdhlogjm.supabase.co';

ALTER DATABASE postgres
SET app.settings.service_role_key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

**Or** set in Supabase Dashboard:
- Settings → Database → Custom Postgres Config
- Add: `app.settings.supabase_url`
- Add: `app.settings.service_role_key`

---

## How to Deploy

### 1. Run the Migration

```bash
PGPASSWORD='pd3Wc7ELL20OZYkE' psql -h aws-1-us-west-1.pooler.supabase.com \
  -U postgres.csotzmardnvrpdhlogjm -d postgres -p 5432 \
  -f supabase/migrations/20251022_create_dynamic_scoring_triggers.sql
```

### 2. Configure Database Variables

```sql
ALTER DATABASE postgres
SET app.settings.supabase_url = 'https://csotzmardnvrpdhlogjm.supabase.co';

ALTER DATABASE postgres
SET app.settings.service_role_key = 'YOUR_SERVICE_ROLE_KEY_HERE';
```

### 3. Deploy Edge Functions

```bash
supabase functions deploy update-biometric-scores
supabase functions deploy update-survey-scores
```

### 4. Test the Trigger

```sql
-- Insert test aggregation data
INSERT INTO aggregation_results_cache
  (user_id, agg_metric_id, calculation_type_id, period_type, value, data_point_count, period_start, period_end)
VALUES
  ('1758fa60-a306-440e-8ae6-9e68fd502bc2', 'AGG_BMI', 'AVG', 'monthly', 25.5, 30, '2025-09-22', '2025-10-22');

-- Check if trigger fired (look at edge function logs)
-- Verify patient_biometric_readings was updated:
SELECT * FROM patient_biometric_readings
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
  AND biometric_name = 'BMI';
```

---

## Alternative: Queue-Based Approach

If the HTTP trigger causes too many edge function calls (e.g., batch aggregations), use a queue instead:

### Benefits of Queue:
- Batch processing (call edge function once per user, not once per aggregation)
- Retry logic for failed updates
- Better observability (can see pending/failed updates)
- Less edge function invocations = lower cost

### Implementation:
Uncomment the queue section in the migration file and set up a scheduled job:

```sql
-- Enable queue-based approach (commented out in migration)
CREATE TABLE dynamic_scoring_queue (...);
CREATE TRIGGER trigger_dynamic_scoring_queue ...;

-- Then create a scheduled edge function that processes the queue:
-- Deno.cron("Process dynamic scoring queue", "*/5 * * * *", async () => {
--   // Get pending items from queue
--   // Group by user_id
--   // Call edge functions once per user
--   // Mark as processed
-- })
```

---

## Monitoring

### Check Trigger Status

```sql
-- See if trigger exists
SELECT tgname, tgrelid::regclass, tgenabled
FROM pg_trigger
WHERE tgname = 'trigger_dynamic_scoring';

-- View trigger function
\df+ trigger_dynamic_scoring_update
```

### Check Edge Function Logs

```bash
# View update-biometric-scores logs
supabase functions logs update-biometric-scores

# View update-survey-scores logs
supabase functions logs update-survey-scores
```

### Check if Updates Happened

```sql
-- Check recent biometric updates
SELECT biometric_name, value, source, recorded_at
FROM patient_biometric_readings
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
  AND source = 'auto_calculated'
ORDER BY recorded_at DESC;

-- Check recent survey updates
SELECT question_number, response_option_id, response_source, updated_at
FROM patient_survey_responses
WHERE user_id = '1758fa60-a306-440e-8ae6-9e68fd502bc2'
  AND response_source = 'auto_updated_from_tracking'
ORDER BY updated_at DESC;
```

---

## Troubleshooting

### Trigger Not Firing

1. Check if trigger is enabled:
```sql
SELECT tgenabled FROM pg_trigger WHERE tgname = 'trigger_dynamic_scoring';
-- Should return: 'O' (enabled)
```

2. Check if pg_net extension is enabled:
```sql
SELECT * FROM pg_extension WHERE extname = 'pg_net';
-- If empty, run: CREATE EXTENSION IF NOT EXISTS pg_net;
```

3. Check if config variables are set:
```sql
SELECT current_setting('app.settings.supabase_url', true);
SELECT current_setting('app.settings.service_role_key', true);
```

### Edge Functions Not Called

1. Check edge function logs for errors
2. Verify service role key is correct
3. Check network connectivity (pg_net can make HTTP requests)

### Updates Not Appearing

1. Check edge function response in logs
2. Verify aggregation cache has enough data points
3. Check if biometric/survey mappings exist

---

## Performance Considerations

### Current Approach (Direct HTTP Trigger)
- **Pros**: Immediate updates, simple implementation
- **Cons**: One edge function call per aggregation update (could be many!)

### Recommended for Production: Queue + Batch Processing
- **Pros**: Efficient, handles bursts, retryable
- **Cons**: Slight delay (5-15 min), more complex

**For now**, use direct HTTP trigger. **Switch to queue** if you see:
- Too many edge function invocations
- Edge function rate limits hit
- Performance degradation

---

## Status

- ✅ Trigger migration created
- ✅ Function defined
- ⏳ Needs: Database configuration (URL + service key)
- ⏳ Needs: Edge functions deployed
- ⏳ Needs: Testing with real data

Once configured and deployed, the system will automatically update scores whenever new tracking data is aggregated! 🎉
