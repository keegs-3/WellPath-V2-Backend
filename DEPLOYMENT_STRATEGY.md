# WellPath Agentic System - Deployment Strategy

## Current Approach (Revised)

### Phase 1: Development & Testing (NOW)
**Database:** Current Supabase (`csotzmardnvrpdhlogjm.supabase.co`)
- This contains dev/test data anyway
- Safe to test agent migrations here
- Can rebuild if needed

**GitHub:** `dev` branch
- All agent code development
- Test and validate

**Steps:**
1. ✅ Build agent system code
2. ⏳ Run agent migration on current database
3. ⏳ Test with existing patient data
4. ⏳ Validate scoring, nudges, challenges
5. ⏳ Fix any issues

### Phase 2: Production Deployment (LATER)
**When ready for real users:**
1. Create NEW Supabase project for production
2. Run all migrations cleanly from scratch
3. Set up proper production data
4. Deploy from `main` branch
5. Keep current database as permanent dev/staging

## Migration Safety

The agent migration (`agentic_adherence_integration.sql`) is designed to be **non-destructive**:

✅ **Safe Operations:**
- Adds new columns to existing tables (agent_goal, agent_context, etc.)
- Creates entirely new tables (agent_*)
- No data deletion
- No table drops
- No column drops

✅ **What it does:**
- Extends `recommendations_base` with 3 new optional columns
- Extends `patient_recommendations` with 3 new optional columns
- Creates 10 new agent-specific tables
- All new tables have their own namespace (agent_*)

❌ **What it doesn't do:**
- Doesn't modify existing data
- Doesn't change existing foreign keys
- Doesn't break existing functionality
- Doesn't require old tables to be dropped

## Rollback Plan

If anything breaks:
1. New tables can be dropped without affecting existing system
2. New columns are optional (existing code ignores them)
3. Can revert GitHub branch to before changes
4. Database can be restored from Supabase backup

## Current Database Details

**Production (Actually Dev Data):**
- URL: https://csotzmardnvrpdhlogjm.supabase.co
- Host: aws-1-us-west-1.pooler.supabase.com
- Database: postgres
- User: postgres.csotzmardnvrpdhlogjm
- Password: pd3Wc7ELL20OZYkE
- Status: Active, contains test data
- Tables: 222

**Usage:** Dev/testing environment for agent system

## Future Production Setup

When ready to go live with real patients:

1. **Create new Supabase project**
   - Fresh database
   - Clean production data only
   - Proper backups configured

2. **Run all migrations in order**
   - Base schema
   - Agent integration
   - Verified and tested

3. **Deploy from main branch**
   - Merge dev → main
   - Deploy to production environment
   - Monitor closely

4. **Keep current as staging**
   - csotzmardnvrpdhlogjm becomes permanent staging/dev
   - Continue testing new features there
   - Never touch production directly

## Environment Files

### `.env` (Current - Dev Data)
```bash
SUPABASE_URL=https://csotzmardnvrpdhlogjm.supabase.co
DATABASE_URL=postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres
ENVIRONMENT=development
```

### `.env.prod` (Future - Real Production)
```bash
SUPABASE_URL=https://[NEW-PROD-PROJECT].supabase.co
DATABASE_URL=postgresql://[NEW-PROD-DETAILS]
ENVIRONMENT=production
```

## Next Steps

1. ⏳ Run agent migration on current database
2. ⏳ Finish building nudge/challenge generators
3. ⏳ Create API endpoints
4. ⏳ Test end-to-end with sample data
5. ⏳ Fix bugs and iterate
6. ⏳ When stable, prepare for production deployment

---

**Bottom Line:** We're treating the current "production" database as dev, testing everything there, then creating a clean production instance later when ready to go live.
