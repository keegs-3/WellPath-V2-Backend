# How Authentication Works in WellPath

## The Source of Truth

**`auth.users`** (Supabase Auth) is THE single source of truth for authentication.

This is Supabase's built-in auth table in the `auth` schema (NOT your custom tables).

## The Table Structure

```
┌─────────────────────────────────────────┐
│  auth.users (Supabase Auth)             │
│  - THE source of truth                  │
│  - Manages passwords, JWTs, sessions    │
│  - id = user's UUID                     │
│  - email, phone, metadata               │
└─────────────────────────────────────────┘
           │
           ├──────────────┬─────────────────┐
           │              │                 │
           ▼              ▼                 ▼
  ┌──────────────┐  ┌──────────┐  ┌──────────────┐
  │ practice_    │  │ patients │  │ (other       │
  │ users        │  │          │  │  tables)     │
  │              │  │          │  │              │
  │ Staff only:  │  │ End      │  │ Reference    │
  │ - clinicians │  │ users    │  │ auth.users   │
  │ - admins     │  │          │  │ for user_id  │
  │ - nurses     │  │          │  │              │
  └──────────────┘  └──────────┘  └──────────────┘
```

## How Login Works

### Patient Login Flow

1. **Patient opens Swift app** → Supabase Auth SDK
2. **Enters email/password** → `test.patient.21@wellpath.com / wellpath123`
3. **Supabase Auth validates** → Checks `auth.users` table
4. **Issues JWT token** → Contains `sub` claim = user's UUID
5. **JWT stored in app** → Used for all subsequent requests

```swift
// Swift app (already set up!)
let client = SupabaseClient(
  supabaseURL: "https://csotzmardnvrpdhlogjm.supabase.co",
  supabaseKey: "eyJhbGci..." // anon key
)

// When user logs in:
await client.auth.signIn(
  email: "test.patient.21@wellpath.com",
  password: "wellpath123"
)

// JWT automatically included in all subsequent queries
let entries = try await client
  .from("patient_data_entries")
  .select()
  .execute()
// RLS policy checks: auth.uid() = patient_id
```

### RLS Enforcement

When Swift makes a query:
```sql
-- User queries:
SELECT * FROM patient_data_entries;

-- PostgreSQL actually executes:
SELECT * FROM patient_data_entries
WHERE COALESCE(patient_id, user_id) = auth.uid();
-- auth.uid() comes from JWT's 'sub' claim
-- Returns '8b79ce33-02b8-4f49-8268-3204130efa82' for test.patient.21
```

## Your 3 Test Users

All 3 are now correctly set up:

| Email | Password | UUID | Has Data? |
|-------|----------|------|-----------|
| `test.patient.21@wellpath.com` | wellpath123 | `8b79ce33-02b8-4f49-8268-3204130efa82` | ✅ Yes (1,380 entries, 177 biomarkers, 52 biometrics) |
| `old.test.patient.21@wellpath.com` (auth: test@wellpath.dev) | ??? | `1758fa60-a306-440e-8ae6-9e68fd502bc2` | ✅ Yes (5,329 entries, 59 biomarkers, 20 biometrics, 3,144 cached aggs) |
| `test.patient.3@wellpath.com` | ??? | `e21d19f7-4f80-4b76-b047-a74a4e87956e` | ❌ No (clean slate) |

## What Happened to public.auth_users?

**DELETED!** ✅

That was YOUR custom table (confused with Supabase's real auth).

You were maintaining TWO auth systems:
- ❌ `public.auth_users` (your custom table) - DELETED
- ✅ `auth.users` (Supabase Auth) - THE real one

We deleted the custom one and now use only Supabase Auth.

## How to Create New Users

### Option 1: Via Supabase Dashboard
1. Go to https://supabase.com/dashboard
2. Auth → Users → Add User
3. Enter email, password, auto-confirm

### Option 2: Via SQL (for clinicians/admins)
```sql
-- This only creates metadata - auth.users entry must exist first!
INSERT INTO practice_users (
  user_id,  -- Must match existing auth.users.id
  medical_practice_id,
  role,
  first_name,
  last_name,
  email
) VALUES (
  'uuid-from-auth-users',
  'practice-uuid',
  'clinician',
  'Dr. Jane',
  'Smith',
  'jane.smith@wellpath.com'
);
```

### Option 3: Via Swift App (for patients)
```swift
// Patient self-signup
let response = try await client.auth.signUp(
  email: "newpatient@example.com",
  password: "securepassword123"
)

// Then create patient metadata
let userId = response.user!.id
try await client
  .from("patients")
  .insert([
    "patient_id": userId,
    "medical_practice_id": "practice-uuid",
    "assigned_clinician_id": "clinician-uuid",
    "email": "newpatient@example.com",
    "first_name": "John",
    "last_name": "Doe"
  ])
  .execute()
```

## Backend Scripts & Edge Functions

Your Python scripts use the **service role** which BYPASSES RLS:

```python
# Scripts use direct DB connection
DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@...'
conn = psycopg2.connect(DB_URL)

# Can read/write ANY data - no RLS checks
# Perfect for aggregation calculations, admin tasks, etc.
```

## Security Model

| User Type | Access Method | Can Access |
|-----------|---------------|------------|
| **Patient** | JWT (anon key) | Own data only (RLS enforced) |
| **Clinician** | JWT (anon key) | Assigned patients' data (RLS enforced) |
| **Admin/Nurse** | JWT (anon key) | Based on access grants (RLS enforced) |
| **Backend Scripts** | Service role | Everything (bypasses RLS) |
| **Edge Functions** | Service role | Everything (bypasses RLS) |

## Current Status

✅ **ALL PERMISSION ISSUES SHOULD BE FIXED!**

- Auth table confusion resolved
- RLS policies properly configured
- All 3 test users have matching auth.users accounts
- Old confusing tables deleted
- Clear separation: staff (practice_users) vs patients

## Testing

Login with test.patient.21@wellpath.com in your Swift app:
```swift
// Should work now!
await client.auth.signIn(
  email: "test.patient.21@wellpath.com",
  password: "wellpath123"
)

// Should return 1,380 rows (patient's own data)
let entries = try await client
  .from("patient_data_entries")
  .select()
  .execute()
```

🎉 **You're all set!**
