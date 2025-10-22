# Development & Testing Scripts

⚠️ **These scripts are for development and testing only**

They may reference preliminary_data or contain hard-coded test paths.
They are NOT required for production operation.

## Main Import Script

### `import_all_test_data.py`

**Purpose**: Imports complete test dataset into Supabase with proper foreign key relationships.

**What it imports:**
- 50 patient profiles
- ~9,000+ biomarker readings (blood work, vitals)
- ~750 biometric readings (weight, height, BMI, VO2 max, HRV, etc.)
- ~10,000+ survey responses (327 questions per patient)

**Usage:**
```bash
python scripts/dev_only/import_all_test_data.py
```

**Data Sources:**
- Biomarkers/Biometrics: `data/dummy_lab_results_full.csv`
- Survey Responses: `data/synthetic_patient_survey.csv`

### Key Features

#### 1. Foreign Key Mapping

**Biomarkers**: Links to `intake_markers_raw.record_id`
- CSV column `hdl` → DB name `HDL` → Airtable record_id

**Biometrics**: Links to `intake_metrics_raw.record_id`
- CSV column `weight_lb` → DB name `Weight` → Airtable record_id
- Includes proper units (lb, in, kg/m², ms, etc.)

**Survey Responses**:
- Question IDs: Numeric (1.01, 2.04) → `survey_questions.record_id`
- Response Options: Text matching → `survey_response_options.record_id`

#### 2. Survey Response Matching Logic

1. **Empty responses**: No matching, `response_option_id` = NULL
2. **Exact match**: Case-insensitive matching to predefined options
3. **Fallback for unmatched values**:
   - `free-response` → `[Free numeric]` or `[Free text]`
   - `date-entry` → `[date]`
   - `single-select/multi-select` → "Other (please specify)"
   - `rank` → rank fallback

This ensures proper scoring and trigger logic for all response types.

#### 3. Expected Match Rates

- **70-80%** of survey responses should have `response_option_id` populated
- Remaining are legitimately unmatched:
  - Free-form text answers
  - Numeric inputs (that get mapped to fallback)
  - Multi-select pipe-separated values
  - Empty conditional responses

### Database Schema

**Key Changes** (see `supabase/migrations/fix_survey_responses_foreign_keys.sql`):

```sql
survey_responses:
  - question_id TEXT → survey_questions.record_id
  - response_option_id TEXT → survey_response_options.record_id
  - response_value TEXT (stores actual response)
```

### Import Process

1. **STEP 1**: Patient Details (50 patients + auth_users)
2. **STEP 2**: Biomarker Readings (~40 markers per patient)
3. **STEP 2.5**: Biometric Readings (15 metrics per patient)
4. **STEP 3**: Survey Responses (327 questions per patient)

### Troubleshooting

**Foreign key violations:**
- Sync Airtable tables first: `python supabase/sync_scripts/selective_update_from_airtable.py intake_metrics_raw intake_markers_raw`

**Slow import (2-3 min):**
- Normal for survey responses due to complex matching logic

**Low match rate:**
- Check question types - free-response and multi-select won't all match

## Other Scripts

- `debug_*.py` - Debugging tools for development
- `import_survey_data.py` - Deprecated, use `import_all_test_data.py`
- `validate_*.py` - Validation scripts for testing

## Database Configuration

```python
DB_CONFIG = {
    'host': 'aws-1-us-west-1.pooler.supabase.com',
    'database': 'postgres',
    'user': 'postgres.csotzmardnvrpdhlogjm',
    'password': 'qLa4sE9zV1yvxCP4',
    'port': 6543
}
```

Default practice: `a1b2c3d4-5678-90ab-cdef-123456789abc`
