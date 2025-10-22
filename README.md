# WellPath V2 Backend

Backend system for WellPath - a comprehensive health scoring and tracking platform.

## Overview

WellPath calculates a holistic health score (0-100%) based on:
- **72% Biomarkers & Biometrics** - Lab results and health measurements
- **18% Survey Responses** - Lifestyle and behavior questions
- **10% Education** - Health education completion (future)

The score is broken down into 7 core pillars of health, each contributing to the overall WellPath Score.

## Repository Structure

```
WellPath-V2-Backend/
├── supabase/              # Supabase configuration and migrations
│   ├── functions/         # Edge Functions (scoring engine)
│   └── migrations/        # Database schema migrations
├── scripts/               # Utility scripts
│   ├── dev_only/         # Development and testing scripts
│   └── archive/          # Archived debug and test scripts
├── docs/                  # Documentation
│   ├── ui-architecture/  # WellPath Score UI system
│   ├── scoring/          # Scoring system documentation
│   └── archive/          # Archived documentation
├── outputs/               # Generated reports and breakdowns
├── data/                  # Reference data and lookups
├── preliminary_data/      # Test patient data
└── tests/                 # Test suites
```

## Key Components

### 1. Scoring Engine (Supabase Edge Function)

**Location**: `supabase/functions/calculate-wellpath-score/`

The scoring engine calculates:
- Overall WellPath Score (0-1.0)
- 7 Pillar Scores (Core Care, Nutrition, Movement, Sleep, Stress, Cognitive, Connection)
- Individual item scores (biomarkers, biometrics, survey questions)

**Calculation Method**:
```
Overall Score = 0.72 * markers_score + 0.18 * survey_score + 0.10 * education_score

For each pillar:
  markers_score = weighted_sum(biomarkers + biometrics) / total_possible
  survey_score = weighted_sum(questions + functions) / total_possible
```

### 2. Database Schema

**Core Tables**:
- `patient_details` - Patient demographics and metadata
- `patient_biomarker_readings` - Lab test results
- `patient_biometric_readings` - Physical measurements
- `patient_survey_responses` - Survey answers
- `wellpath_scoring_*` - Scoring configuration (weights, ranges, functions)

**UI Display Tables** (NEW):
- `wellpath_score_display_sections` - UI hierarchy and navigation
- `wellpath_score_display_items` - Individual items within sections
- `wellpath_score_question_content` - Question tips and alternatives
- `patient_wellpath_score_display` - Calculated patient scores + content

### 3. Active Scripts

#### Development Tools (`scripts/dev_only/`)

**Data Management**:
- `import_all_test_data.py` - Import complete test patient dataset
- `create_auth_for_patients.py` - Create Supabase auth for test patients
- `create_perfect_patient.py` - Generate a patient with perfect scores

**Scoring**:
- `batch_calculate_scores.py` - Calculate scores for all patients
- `calculate_one_score.py` - Calculate score for a single patient

**Tracking Data**:
- `generate_metric_tracking_data.py` - Generate sample tracking data

## Quick Start

### Prerequisites

- Python 3.9+
- Supabase account
- Environment variables configured (see `.env.example`)

### Setup

```bash
# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your Supabase credentials

# Run migrations (if needed)
supabase db push

# Import test data
cd scripts/dev_only
python import_all_test_data.py
```

### Calculate Scores

```bash
# Calculate for all patients
python scripts/dev_only/batch_calculate_scores.py

# Calculate for one patient
python scripts/dev_only/calculate_one_score.py <user_id>

# Create a perfect score patient
python scripts/dev_only/create_perfect_patient.py
```

## Documentation

### Architecture & Design
- `docs/DATA_ARCHITECTURE.md` - Overall data architecture
- `docs/ui-architecture/WELLPATH_SCORE_UI_ARCHITECTURE.md` - UI display system design
- `docs/ui-architecture/WELLPATH_SCORE_UI_IMPLEMENTATION.md` - Implementation guide
- `docs/EDUCATION_COMPONENT_README.md` - Education component (future)

### Scoring System
- `docs/scoring/SCORING_STATUS.md` - Current scoring implementation status
- `docs/scoring/MARKER_SCORING_STATUS.md` - Biomarker/biometric scoring details
- `docs/scoring/API_SCORING_SUMMARY.md` - API scoring summary

### Setup Guides
- `docs/ui-architecture/WELLPATH_SCORE_UI_SETUP_COMPLETE.md` - UI system setup verification
- `docs/ui-architecture/SCORE_DETAILS_AND_CONDITIONS.md` - Patient conditions and scoring

## Recent Major Updates

### Phase 1: WellPath Score UI System (Oct 2024) ✅
- Created flexible UI display architecture
- Implemented hierarchical navigation (Home → Behaviors → Substances → Alcohol)
- Added rich question content with alternative responses and tips
- Deployed 4 new database tables and helper functions
- **Status**: Database ready, Edge Function integration pending

### Perfect Patient Test Case (Oct 2024) ✅
- Created test patient with 90% overall score
- Verified all 7 pillars calculating correctly
- Validated biomarker range matching
- Confirmed demographic filtering (gender-specific screenings)

### Batch Scoring (Oct 2024) ✅
- Successfully calculated scores for 50 test patients
- Average score: ~54% (realistic for general population)
- Range: 30-90%
- All pillars contributing correctly

## Current Status

✅ **Production Ready**:
- Scoring engine functioning correctly
- All 7 pillars calculating accurately
- Biomarker/biometric scoring with age/gender filtering
- Survey scoring with complex functions
- Batch processing for multiple patients

🚧 **In Progress**:
- Edge Function integration with UI display tables
- Patient condition support (CKD, athlete, menopausal status, cycle stage)
- Content population for all survey questions

📋 **Planned**:
- Education component scoring (10% of total)
- Historical score tracking
- Recommendation engine integration
- Real-time score updates via webhooks

## Environment Variables

Required in `.env`:

```bash
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
SUPABASE_DB_PASSWORD=your-db-password
```

## Database Connection

```bash
# Direct psql connection
PGPASSWORD='<db-password>' psql -h aws-1-us-west-1.pooler.supabase.com \
  -p 6543 -U postgres.<project-ref> -d postgres
```

## Testing

```bash
# Run all tests
pytest tests/

# Run specific test suite
pytest tests/test_scoring.py
pytest tests/test_database.py
```

## Contributing

1. Create a feature branch
2. Make changes and test thoroughly
3. Update documentation as needed
4. Submit pull request with clear description

## License

Proprietary - WellPath Health Technologies

## Support

For questions or issues, contact the development team.

---

**Last Updated**: October 16, 2024
**Version**: 2.0
**Status**: Active Development
