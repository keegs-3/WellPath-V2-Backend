# Supabase Airtable Sync Scripts

Scripts for syncing Airtable CSV exports to Supabase database.

## Scripts

### `selective_update_from_airtable.py`

**Purpose**: Selectively sync specific Airtable tables to Supabase

**Usage:**
```bash
# Sync specific tables
python supabase/sync_scripts/selective_update_from_airtable.py intake_metrics_raw intake_markers_raw

# List available tables
python supabase/sync_scripts/selective_update_from_airtable.py --list

# Sync all tables (not recommended - takes 10+ minutes)
python supabase/sync_scripts/selective_update_from_airtable.py --all
```

**Features:**
- Updates existing records by `record_id`
- Inserts new records
- Skips tables that don't exist in Supabase
- Much faster than batch updating all tables

**Common Use Cases:**
```bash
# After updating metrics in Airtable
python selective_update_from_airtable.py intake_metrics_raw

# After updating markers in Airtable
python selective_update_from_airtable.py intake_markers_raw

# After updating survey questions
python selective_update_from_airtable.py survey_questions survey_response_options

# After updating recommendations
python selective_update_from_airtable.py recommendations_v2
```

### `batch_update_from_airtable.py`

**Purpose**: Sync ALL Airtable CSVs to Supabase (100+ tables)

**⚠️ Warning**: Takes 10-15 minutes, updates everything

**Usage:**
```bash
python supabase/sync_scripts/batch_update_from_airtable.py
```

**When to use:**
- Initial database setup
- Major Airtable schema changes
- Complete refresh needed

**Not recommended for**:
- Quick updates to 1-2 tables (use `selective_update_from_airtable.py` instead)
- Development workflow (too slow)

## Data Source

Both scripts read from: `ALL_AIRTABLE/csvs/`

This directory contains CSV exports from Airtable. To refresh:
1. Export tables from Airtable
2. Place CSVs in `ALL_AIRTABLE/csvs/`
3. Run sync scripts

## How Syncing Works

1. **Read CSV**: Load data from `ALL_AIRTABLE/csvs/{table_name}.csv`
2. **Check table exists**: Skip if table not in Supabase
3. **Get existing records**: Query for existing `record_id` values
4. **Update or Insert**:
   - If `record_id` exists: UPDATE
   - If new `record_id`: INSERT
5. **Commit**: Transaction per table

## Column Mapping

CSV columns are automatically sanitized:
- Spaces → underscores
- Parentheses removed
- Hyphens → underscores
- Lowercase

Example: `Blood Pressure (Systolic)` → `blood_pressure_systolic`

## Special Handling

**Linked Records** (comma-separated in Airtable):
- Takes first value only for single-link fields
- Fields: `metric_types_vfinal`, `calculated_metrics_vfinal`, `screening_compliance_matrix`

## Database Configuration

```python
DATABASE_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:qLa4sE9zV1yvxCP4@aws-1-us-west-1.pooler.supabase.com:6543/postgres'
```

## Troubleshooting

**Table not found:**
- Check table name matches Supabase exactly
- Use `--list` to see available CSVs

**Foreign key violations:**
- Sync parent tables first (e.g., sync `survey_questions` before `survey_response_options`)

**Column not found:**
- Column might not exist in Supabase schema
- Check migration files in `supabase/migrations/`
