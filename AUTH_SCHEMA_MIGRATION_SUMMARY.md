# Authentication Schema Migration Summary

## Overview

Successfully refactored WellPath authentication schema from mixed auth_users table to clean separation between practice staff and patients.

## Schema Changes

### Before:
- `auth_users` - Mixed table (patients + clinicians)
- `patient_details` - Patient-specific fields
- `medical_practices` - Practice info

### After:
- **`practice_users`** - Staff only (clinicians, admins, nurses)
- **`patients`** - End users (completely separate from staff)
- **`practice_user_access`** - Junction table for admin/nurse access control
- **`medical_practices`** - Unchanged

## Data Migration Results

✅ **Successfully Migrated:**
- 2 Clinicians → `practice_users`
- 52 Patients → `patients` table
- 6,709 patient_data_entries (fixed 1,380 orphaned records)
- 3,144 aggregation_results_cache (deleted 7,200 orphaned duplicates)

✅ **Test Users Preserved:**
- `test.patient.21@wellpath.com` (8b79ce33-02b8-4f49-8268-3204130efa82)
- `old.test.patient.21@wellpath.com` (1758fa60-a306-440e-8ae6-9e68fd502bc2)
- `test.patient.3@wellpath.com` (d9581a86-0f30-4be4-ba9e-6ae269700d4d)

## New Columns Added

All patient data tables now have BOTH columns (for backward compatibility):
- `user_id` (legacy, still present)
- `patient_id` (new, references `patients.patient_id`)

RLS policies use: `COALESCE(patient_id, user_id)` to support both columns.

## RLS Policies Created

**Total:** 106 policies across 40 tables

###Patient Access:
- ✅ Read/Write own `patient_data_entries`
- ✅ Read/Write own `patient_survey_responses`
- ✅ Read own `aggregation_results_cache`
- ✅ Read all config tables

### Clinician Access:
- ✅ Read/Write `patient_biomarker_readings` for assigned patients
- ✅ Read/Write `patient_biometric_readings` for assigned patients
- ✅ Read patient data entries, surveys, aggregations

### Admin/Nurse Access:
- ✅ Based on `practice_user_access` junction table
- ✅ Can have access to specific clinicians or all clinicians

### Service Role:
- ✅ Bypasses all RLS (for edge functions, scripts)

## Next Steps

### For Mobile Development:
1. ✅ Auth is set up - use test.patient.21@wellpath.com
2. ✅ RLS policies allow patients to read/write their own data
3. ⚠️  **Important:** Eventually update Swift app to use `patient_id` instead of `user_id` in queries
   - For now, RLS policies support BOTH columns

### For Production:
1. After full testing, can drop legacy columns:
   - Drop `user_id` from patient data tables
   - Drop old `auth_users` and `patient_details` tables
2. Update RLS policies to use only `patient_id`

### For Backend Scripts:
- ✅ Python scripts use service role (bypasses RLS)
- ✅ Edge functions use service role (bypasses RLS)
- No changes needed!

## Database Connection Strings

**For Scripts/Edge Functions (Service Role):**
```
postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres
```

**For Swift App (Anon Key):**
```swift
SupabaseClient(
  supabaseURL: "https://csotzmardnvrpdhlogjm.supabase.co",
  supabaseKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." // anon key
)
```

## Files Created

1. **`20251025_refactor_auth_schema.sql`** - Main refactor migration
2. **`20251025_create_rls_policies.sql`** - RLS policies for all tables
3. **`AUTH_SCHEMA_MIGRATION_SUMMARY.md`** - This file

## Testing RLS

To test that a patient can access their own data:

```sql
-- Set role to patient (simulates JWT auth)
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims.sub TO '8b79ce33-02b8-4f49-8268-3204130efa82';

-- Should return patient's data
SELECT COUNT(*) FROM patient_data_entries;
SELECT COUNT(*) FROM aggregation_results_cache;

-- Should fail (trying to access another patient's data)
SET LOCAL request.jwt.claims.sub TO 'wrong-uuid';
SELECT COUNT(*) FROM patient_data_entries; -- Returns 0
```

## Status

🎉 **COMPLETE!** Authentication schema successfully refactored and RLS enabled.

- ✅ Schema migrated
- ✅ Data migrated (52 patients, 6.7K entries)
- ✅ RLS policies created (106 policies)
- ✅ Test users preserved
- ✅ Backward compatible (supports both user_id and patient_id)
- ✅ Ready for mobile dev and testing
