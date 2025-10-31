# WellPath Dev Environment Setup Guide

## Overview
This guide sets up a development environment with a separate Supabase database for safely testing the new agentic adherence system.

## Step 1: Get Dev Database Password

1. Go to your Supabase dev project: https://supabase.com/dashboard/project/lhkabxlehrrbkkxyngrj
2. Navigate to **Settings** > **Database**
3. Scroll to **Connection String**
4. Click **Show** next to the connection string
5. Copy the password (it's after `postgres.lhkabxlehrrbkkxyngrj:` and before `@aws-0`)

## Step 2: Configure Dev Environment

1. Edit `.env.dev` file
2. Replace `[YOUR-PASSWORD]` with the actual dev database password in these places:
   - `DATABASE_URL`
   - `DB_PASSWORD`

## Step 3: Verify Database Connection

Test connection to dev database:

```bash
export PGPASSWORD='YOUR_DEV_PASSWORD'
psql -h aws-0-us-west-1.pooler.supabase.com \
     -U postgres.lhkabxlehrrbkkxyngrj \
     -d postgres \
     -p 6543 \
     -c "SELECT version();"
```

If this works, you're connected!

## Step 4: Set Up Base Schema (First Time Only)

Your dev database is empty. You need to set up the base WellPath schema first.

### Option A: Copy from Production (Recommended)
Use Supabase's built-in migration tools or pg_dump:

```bash
# Dump production schema (structure only)
pg_dump -h aws-1-us-west-1.pooler.supabase.com \
        -U postgres.csotzmardnvrpdhlogjm \
        -d postgres \
        -p 5432 \
        --schema-only \
        --no-owner \
        --no-privileges \
        -f /tmp/wellpath_schema.sql

# Load into dev database
psql -h aws-0-us-west-1.pooler.supabase.com \
     -U postgres.lhkabxlehrrbkkxyngrj \
     -d postgres \
     -p 6543 \
     -f /tmp/wellpath_schema.sql
```

### Option B: Use Supabase Dashboard
1. In production project, go to **Database** > **Migrations**
2. Create a migration for current state
3. Copy SQL
4. Apply to dev project via SQL Editor

## Step 5: Add Sample Data (Optional)

Add minimal test data for testing:

```sql
-- Insert test patient
INSERT INTO patients (patient_id, email, first_name, last_name)
VALUES (
  '00000000-0000-0000-0000-000000000001'::uuid,
  'test@wellpath.dev',
  'Test',
  'Patient'
);

-- Insert test biomarkers
-- (Copy from production or create minimal set)

-- Insert test recommendations
-- (Copy from production or create minimal set)
```

## Step 6: Run Agentic Adherence Migration

Once base schema is ready:

```bash
# Set environment to dev
export ENV=development

# Run the agent migration
psql -h aws-0-us-west-1.pooler.supabase.com \
     -U postgres.lhkabxlehrrbkkxyngrj \
     -d postgres \
     -p 6543 \
     -f database/migrations/agentic_adherence_integration.sql
```

## Step 7: Verify Migration

Check that new tables exist:

```bash
psql -h aws-0-us-west-1.pooler.supabase.com \
     -U postgres.lhkabxlehrrbkkxyngrj \
     -d postgres \
     -p 6543 \
     -c "\dt agent_*"
```

You should see:
- `agent_adherence_scores`
- `agent_pillar_scores`
- `agent_overall_scores`
- `agent_nudges`
- `agent_challenges`
- `agent_user_context`
- `agent_research_knowledge`
- `agent_recommendation_outcomes`
- `agent_execution_log`

And:
- `patient_modes`

## Step 8: Test the Agent System

Run the test script (once created):

```bash
# Use dev environment
cp .env.dev .env

# Run tests
python -m pytest services/adherence_agent/tests/

# Or run manual test
python scripts/test_agent_scoring.py --patient-id 00000000-0000-0000-0000-000000000001
```

## Environment Switching

### Use Dev:
```bash
cp .env.dev .env
# or
export ENV=development
```

### Use Production:
```bash
cp .env.prod .env
# or
export ENV=production
```

## Database Management

### Dev Database
- **Purpose**: Testing new features, migrations, breaking changes
- **Data**: Can be destroyed and rebuilt
- **Migrations**: Test here first
- **Connection**: lhkabxlehrrbkkxyngrj.supabase.co

### Production Database
- **Purpose**: Live patient data
- **Data**: CRITICAL - never destructive operations
- **Migrations**: Only after dev validation
- **Connection**: csotzmardnvrpdhlogjm.supabase.co

## Common Tasks

### Reset Dev Database
```bash
# Drop all agent tables
psql -h aws-0-us-west-1.pooler.supabase.com \
     -U postgres.lhkabxlehrrbkkxyngrj \
     -d postgres \
     -p 6543 \
     -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Rebuild from scratch
# (Run Step 4 and Step 6 again)
```

### Sync Dev with Production Schema
```bash
# Export production schema
pg_dump [production-connection] --schema-only > schema.sql

# Import to dev
psql [dev-connection] < schema.sql
```

### View Agent Execution Logs
```sql
-- In dev database
SELECT
  agent_type,
  status,
  duration_ms,
  created_at
FROM agent_execution_log
ORDER BY created_at DESC
LIMIT 10;
```

## Troubleshooting

### Can't Connect to Dev Database
- Check password in `.env.dev`
- Verify project URL: https://lhkabxlehrrbkkxyngrj.supabase.co
- Check if Supabase project is paused (free tier)

### Migration Fails
- Check if base schema exists first
- Verify no conflicting table names
- Check logs in Supabase dashboard

### Agent Tests Fail
- Verify Anthropic API key is set
- Check database has sample data
- Review agent_execution_log for errors

## Next Steps

1. ✅ Create dev Supabase project
2. ⏳ Get dev database password
3. ⏳ Set up base schema in dev
4. ⏳ Run agent migration in dev
5. ⏳ Add sample test data
6. ⏳ Test agent system end-to-end
7. ⏳ Validate everything works
8. ⏳ Deploy to production

## Safety Rules

1. **NEVER** run untested migrations on production
2. **ALWAYS** test in dev first
3. **BACKUP** production before major changes
4. **VALIDATE** migration success before proceeding
5. **DOCUMENT** all schema changes

## Resources

- Dev Supabase: https://supabase.com/dashboard/project/lhkabxlehrrbkkxyngrj
- Prod Supabase: https://supabase.com/dashboard/project/csotzmardnvrpdhlogjm
- Migration Plan: `database/migrations/AGENTIC_MIGRATION_PLAN.md`
- Agent Documentation: `services/adherence_agent/README.md` (to be created)
