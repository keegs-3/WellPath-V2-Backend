# Testing Instance Calculations

## Overview
This guide walks through deploying and testing the instance calculations edge function that powers cross-population (e.g., vegetables → fiber auto-calculation).

Created: 2025-10-21

---

## Prerequisites

1. **Supabase CLI installed**:
   ```bash
   brew install supabase/tap/supabase
   ```

2. **Logged into Supabase**:
   ```bash
   supabase login
   ```

3. **Python environment** (for test script):
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install supabase python-dotenv requests
   ```

4. **Environment variables** (in `.env`):
   ```
   SUPABASE_URL=https://csotzmardnvrpdhlogjm.supabase.co
   SUPABASE_ANON_KEY=<your-anon-key>
   ```

---

## Step 1: Deploy Edge Function

### Link to your Supabase project (first time only):
```bash
supabase link --project-ref csotzmardnvrpdhlogjm
```

### Deploy the function:
```bash
supabase functions deploy run-instance-calculations
```

### Verify deployment:
```bash
supabase functions list
```

You should see `run-instance-calculations` in the list.

---

## Step 2: Test with Python Script

The test script simulates the full flow:
1. Inserts manual vegetable intake data
2. Triggers instance calculations
3. Verifies auto-calculated fiber/protein entries

### Run the test:
```bash
python scripts/test_instance_calculations.py
```

### Expected Output:
```
======================================================================
INSTANCE CALCULATIONS TEST
======================================================================

Using test user: 00000000-0000-0000-0000-000000000001

======================================================================
TEST 1: Vegetables → Fiber Auto-Population
======================================================================

=== Inserting Vegetable Intake ===
User: 00000000-0000-0000-0000-000000000001
Vegetable: broccoli
Quantity: 2.0 servings
Timestamp: 2025-10-21T10:30:00.123456
✅ Inserted 3 manual entries

=== Triggering Instance Calculations ===
Calling: https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations
✅ Calculations Complete!
Calculations run: 2
Entries created: 3
Created fields: ['DEF_FIBER_SOURCE', 'DEF_FIBER_SERVINGS', 'DEF_FIBER_GRAMS']

=== Verifying Auto-Calculated Entries ===

Total entries found: 6

Field ID                            Source          Value
----------------------------------------------------------------------
DEF_FIBER_GRAMS                     auto_calculated 8
DEF_FIBER_SERVINGS                  auto_calculated 2
DEF_FIBER_SOURCE                    auto_calculated vegetables
DEF_VEGETABLE_QUANTITY              manual          2.0
DEF_VEGETABLE_TIME                  manual          2025-10-21T10:30:00.123456
DEF_VEGETABLE_TYPE                  manual          broccoli

✅ Auto-calculated entries: 3
  ✅ DEF_FIBER_SOURCE: vegetables
  ✅ DEF_FIBER_SERVINGS: 2
  ✅ DEF_FIBER_GRAMS: 8

======================================================================
✅ TEST PASSED!
======================================================================
```

---

## Step 3: Test Manually via Supabase Dashboard

### Insert test data in SQL Editor:
```sql
-- Insert manual vegetable entry
INSERT INTO patient_data_entries (
  user_id,
  field_id,
  entry_date,
  entry_timestamp,
  value_reference,
  source
) VALUES
(
  '00000000-0000-0000-0000-000000000001',  -- Use a real user_id
  'DEF_VEGETABLE_TYPE',
  '2025-10-21',
  '2025-10-21 10:30:00+00',
  'broccoli',
  'manual'
),
(
  '00000000-0000-0000-0000-000000000001',
  'DEF_VEGETABLE_QUANTITY',
  '2025-10-21',
  '2025-10-21 10:30:00+00',
  NULL,
  'manual'
);

UPDATE patient_data_entries
SET value_quantity = 2.0
WHERE user_id = '00000000-0000-0000-0000-000000000001'
  AND field_id = 'DEF_VEGETABLE_QUANTITY'
  AND entry_timestamp = '2025-10-21 10:30:00+00';
```

### Trigger edge function via curl:
```bash
curl -i --location --request POST 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations' \
  --header 'Authorization: Bearer YOUR_ANON_KEY' \
  --header 'Content-Type: application/json' \
  --data '{
    "user_id": "00000000-0000-0000-0000-000000000001",
    "event_type_id": "vegetable_intake",
    "entry_timestamp": "2025-10-21T10:30:00.000000+00:00"
  }'
```

### Verify results:
```sql
SELECT
  field_id,
  source,
  value_quantity,
  value_reference,
  metadata
FROM patient_data_entries
WHERE user_id = '00000000-0000-0000-0000-000000000001'
  AND entry_timestamp = '2025-10-21 10:30:00+00'
ORDER BY field_id;
```

### Expected results:
| field_id | source | value_quantity | value_reference | metadata |
|----------|--------|----------------|-----------------|----------|
| DEF_FIBER_GRAMS | auto_calculated | 8 | null | `{"calculated_by":"CALC_VEGETABLES_TO_FIBER",...}` |
| DEF_FIBER_SERVINGS | auto_calculated | 2 | null | `{"calculated_by":"CALC_VEGETABLES_TO_FIBER"}` |
| DEF_FIBER_SOURCE | auto_calculated | null | vegetables | `{"calculated_by":"CALC_VEGETABLES_TO_FIBER"}` |
| DEF_VEGETABLE_QUANTITY | manual | 2 | null | null |
| DEF_VEGETABLE_TIME | manual | null | null | null |
| DEF_VEGETABLE_TYPE | manual | null | broccoli | null |

---

## Step 4: Set Up Database Trigger (Optional)

To automatically trigger calculations when data is inserted, create a database trigger:

```sql
CREATE OR REPLACE FUNCTION trigger_instance_calculations()
RETURNS TRIGGER AS $$
DECLARE
  event_id TEXT;
BEGIN
  -- Get event_type_id from field
  SELECT event_type_id INTO event_id
  FROM data_entry_fields
  WHERE field_id = NEW.field_id
  LIMIT 1;

  -- Only trigger if field has an event_type
  IF event_id IS NOT NULL THEN
    -- Call edge function asynchronously
    PERFORM
      net.http_post(
        url := current_setting('app.settings.supabase_url') || '/functions/v1/run-instance-calculations',
        headers := jsonb_build_object(
          'Content-Type', 'application/json',
          'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
        ),
        body := jsonb_build_object(
          'user_id', NEW.user_id,
          'event_type_id', event_id,
          'entry_timestamp', NEW.entry_timestamp
        )
      );
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger on INSERT
CREATE TRIGGER auto_run_instance_calculations
AFTER INSERT ON patient_data_entries
FOR EACH ROW
WHEN (NEW.source = 'manual')  -- Only trigger for manual entries
EXECUTE FUNCTION trigger_instance_calculations();
```

**Note**: This requires the `pg_net` extension and proper configuration. For now, manually calling the edge function is simpler.

---

## Troubleshooting

### Edge function not found
- Make sure you deployed: `supabase functions deploy run-instance-calculations`
- Check deployment: `supabase functions list`

### No auto-calculated entries created
- Check edge function logs: `supabase functions logs run-instance-calculations`
- Verify event_types_dependencies table has entries for the event_type
- Verify instance_calculations exist
- Check that reference tables (def_ref_food_types, def_ref_fiber_sources) have data

### Permission errors
- Make sure you're using SUPABASE_SERVICE_ROLE_KEY in the edge function (not anon key)
- Check RLS policies on patient_data_entries allow the service role to insert

### Calculation not running
- Check calculation dependencies in instance_calculations_dependencies
- Verify the calculation_method is implemented in the edge function
- Check calculation_config JSONB structure matches what the function expects

---

## Next Steps

Once testing is successful:

1. **Integrate into app**: Call the edge function after user submits nutrition data
2. **Add more calculations**: Extend for protein, fat, other nutrition cross-populations
3. **Real-time updates**: Set up database trigger for automatic execution
4. **Error handling**: Add retry logic and error notifications
5. **Monitoring**: Set up alerts for failed calculations

---

## Test Cases to Validate

- [x] Vegetables → Fiber (category to macro)
- [ ] Broccoli → Specific nutrition values (food lookup)
- [ ] Fiber servings → grams (lookup multiply)
- [ ] Fiber grams → servings (lookup divide)
- [ ] Legumes → Fiber + Protein (multiple outputs)
- [ ] Nuts → Fiber + Protein + Fat (multiple outputs)
- [ ] Invalid food type (error handling)
- [ ] Missing quantity (validation)
- [ ] Concurrent entries (race conditions)
