# WellPath V2 Backend - Complete Self-Contained System

**Last Updated:** 2025-10-08
**Status:** Fully self-contained, no cross-repo dependencies

---

## 🚨 CRITICAL INFO FOR CLAUDE SESSIONS

If you're a new Claude session helping with this project, READ THIS FIRST:

### System Architecture Overview

WellPath V2 Backend is a **completely self-contained** FastAPI backend for the WellPath longevity platform. It handles:

1. **Patient Health Scoring** (7 pillars: Nutrition, Movement, Sleep, Cognitive, Stress, Connection, Core Care)
2. **Adherence Tracking** (182 recommendations with 14 algorithm types)
3. **AI-Driven Recommendations** (20 personalized recommendations per patient)
4. **Behavioral Support** (Challenges, Nudges, Check-ins, Education)

### ⚠️ NO CROSS-REPO DEPENDENCIES

**IMPORTANT:** This repo should NOT import from `/preliminary_data` or any other repo. Everything needed is contained here.

If you see imports like:
```python
from /Users/keegs/Documents/GitHub/preliminary_data/...
```
**THESE ARE WRONG** - Remove them and use local modules instead.

---

## Directory Structure

```
WellPath-V2-Backend/
├── ALL_AIRTABLE/                    # Source of truth data from Airtable
│   ├── csvs/                        # 81 CSV exports (recommendations, challenges, etc.)
│   └── script/                      # Airtable export scripts
│
├── scoring_engine/                  # Core scoring and adherence engine
│   ├── algorithms/                  # 14 adherence algorithm types
│   │   ├── binary_threshold.py      # Simple pass/fail
│   │   ├── proportional.py          # Linear progress tracking
│   │   ├── minimum_frequency.py     # "At least X times per week"
│   │   ├── zone_based.py            # Optimal range tracking
│   │   ├── composite_weighted.py    # Multi-factor scoring
│   │   ├── sleep_composite.py       # Advanced sleep tracking
│   │   ├── weekly_elimination.py    # Zero-tolerance tracking
│   │   ├── constrained_weekly_allowance.py  # Budget limits
│   │   ├── categorical_filter_threshold.py  # Category-based
│   │   ├── proportional_frequency_hybrid.py # Partial credit + frequency
│   │   ├── baseline_consistency.py  # Baseline maintenance
│   │   ├── weekend_variance.py      # Weekday/weekend patterns
│   │   ├── completion_based.py      # One-time tasks
│   │   └── therapeutic_adherence.py # Medication tracking
│   │
│   ├── adherence/                   # Adherence tracking system
│   │   ├── __init__.py
│   │   ├── tracker.py               # Track patient adherence data
│   │   ├── calculator.py            # Calculate adherence scores
│   │   └── configs/                 # 320+ recommendation configurations
│   │       ├── REC0001.1-PROPORTIONAL.json
│   │       ├── REC0001.2-PROPORTIONAL.json
│   │       ├── MED001-SINGLE.json
│   │       ├── SUP001-SINGLE.json
│   │       └── ... (320 total configs)
│   │
│   ├── configs/                     # Marker/metric configurations
│   │   ├── marker_config.json       # Biomarker scoring rules
│   │   └── marker_name_mapping.json # Marker name standardization
│   │
│   ├── utils/                       # Utility modules
│   │   ├── data_fetcher.py          # Database queries
│   │   └── supabase_data_adapter.py # Supabase client
│   │
│   ├── biomarker_scorer.py          # Score biomarkers/lab values
│   ├── survey_scorer.py             # Score survey responses
│   ├── education_scorer.py          # Score educational engagement
│   └── scoring_service.py           # Main scoring orchestration
│
├── api/                             # FastAPI endpoints
│   └── routers/
│       ├── scores.py                # Scoring endpoints
│       ├── recommendations.py       # Recommendation endpoints
│       └── adherence.py             # Adherence tracking endpoints
│
├── outputs/                         # Generated outputs (gitignored)
│   ├── scores/                      # Patient score exports
│   ├── breakdowns/                  # Detailed score breakdowns
│   └── reports/                     # Generated reports
│
├── docs/                            # Comprehensive documentation
│   ├── algorithms/                  # 18 algorithm documentation files
│   ├── adherence/                   # Adherence system guides
│   └── architecture/                # System architecture docs
│
├── supabase/                        # Database management
│   ├── migrations/                  # Database migrations
│   └── sync_scripts/                # Data sync scripts
│
└── tests/                           # Test suite
```

---

## Core Components

### 1. Scoring Engine

**Location:** `scoring_engine/`

**Purpose:** Calculate patient health scores across 7 pillars using:
- **Biomarkers** (lab values, vital signs)
- **Survey responses** (lifestyle, behaviors, history)
- **Education engagement** (article/module completion)

**Key Files:**
- `scoring_service.py` - Main orchestration
- `biomarker_scorer.py` - Lab value scoring
- `survey_scorer.py` - Survey response scoring
- `education_scorer.py` - Education engagement scoring

**Pillar Weights:**
```python
PILLAR_WEIGHTS = {
    "Healthful Nutrition": {"markers": 0.72, "survey": 0.18, "education": 0.10},
    "Movement + Exercise": {"markers": 0.54, "survey": 0.36, "education": 0.10},
    "Restorative Sleep": {"markers": 0.63, "survey": 0.27, "education": 0.10},
    "Cognitive Health": {"markers": 0.36, "survey": 0.54, "education": 0.10},
    "Stress Management": {"markers": 0.27, "survey": 0.63, "education": 0.10},
    "Connection + Purpose": {"markers": 0.18, "survey": 0.72, "education": 0.10},
    "Core Care": {"markers": 0.495, "survey": 0.405, "education": 0.10}
}
```

### 2. Adherence Tracking System

**Location:** `scoring_engine/adherence/`

**Purpose:** Track patient adherence to 182 recommendations using 14 algorithm types

**Components:**
- **AdherenceTracker** (`tracker.py`) - Fetch patient tracking data
- **AdherenceCalculator** (`calculator.py`) - Calculate adherence scores
- **Configs** (`configs/`) - 320+ recommendation configurations

**14 Algorithm Types:**
1. **Binary Threshold** - Simple pass/fail (e.g., "Take medication daily")
2. **Minimum Frequency** - "At least X times per week"
3. **Weekly Elimination** - Zero tolerance (e.g., "No processed foods")
4. **Proportional** - Linear progress (e.g., "Work toward 10,000 steps")
5. **Zone-Based** - Optimal ranges (e.g., "Sleep 7-9 hours")
6. **Composite Weighted** - Multi-factor scoring
7. **Sleep Composite** - Advanced sleep tracking
8. **Categorical Filter** - Category-specific tracking
9. **Constrained Weekly Allowance** - Budget limits (e.g., "≤2 takeout meals/week")
10. **Proportional Frequency Hybrid** - Partial credit + frequency
11. **Baseline Consistency** - Maintain baseline values
12. **Weekend Variance** - Weekday/weekend patterns
13. **Completion Based** - One-time tasks (screenings, appointments)
14. **Therapeutic Adherence** - Medication/supplement tracking

**Usage Example:**
```python
from scoring_engine.adherence import AdherenceCalculator

# Load recommendation config
calculator = AdherenceCalculator(config_id="REC0001.1-PROPORTIONAL")

# Calculate adherence score
score = calculator.calculate_score(patient_data)

print(f"Progress: {score['progress_towards_goal']}%")
print(f"Max Potential: {score['max_potential_adherence']}%")
```

### 3. Airtable Data (ALL_AIRTABLE/)

**Source of Truth:** All system data exported from Airtable

**Key CSVs:**
- `recommendations_v2.csv` - 182 recommendations
- `challenges_v3.csv` - 1,247 behavioral challenges
- `nudges_v2.csv` - Motivational nudges
- `education_modules.csv` - Educational content
- `calculated_metrics_vfinal.csv` - Calculated metrics definitions
- `metric_types_v3.csv` - Tracked metrics
- `adherence_scoring.csv` - Algorithm configurations

**Sync Process:**
1. Export from Airtable → `ALL_AIRTABLE/csvs/`
2. Run sync scripts → Update Supabase database
3. Generate configs → `scoring_engine/adherence/configs/`

### 4. API Endpoints

**Location:** `api/routers/`

**Key Endpoints:**
- `GET /api/v1/scores/patient/{patient_id}` - Get patient scores
- `GET /api/v1/scores/breakdown/{patient_id}` - Detailed score breakdown
- `POST /api/v1/adherence/track` - Track adherence data
- `GET /api/v1/adherence/score/{patient_id}/{recommendation_id}` - Get adherence score

---

## Common Tasks

### Run the API Server

```bash
cd /Users/keegs/Documents/GitHub/WellPath-V2-Backend
uvicorn api.main:app --reload --host 127.0.0.1 --port 8000
```

### Calculate Patient Scores

```python
from scoring_engine.scoring_service import ScoringService

service = ScoringService()
scores = service.calculate_patient_scores(patient_id="UUID-HERE")

print(f"Overall Score: {scores['overall_score']}")
print(f"Pillar Scores: {scores['pillar_scores']}")
print(f"Breakdown: {scores['breakdown']}")
```

### Calculate Adherence Score

```python
from scoring_engine.adherence import AdherenceCalculator, AdherenceTracker

# Track adherence data
tracker = AdherenceTracker(patient_id="UUID-HERE")
data = tracker.get_recommendation_data("REC0001.1")

# Calculate score
calculator = AdherenceCalculator(config_id="REC0001.1-PROPORTIONAL")
score = calculator.calculate_score(data)
```

### List Available Recommendation Configs

```python
from scoring_engine.adherence import AdherenceCalculator

configs = AdherenceCalculator.list_available_configs()
print(f"Found {len(configs)} recommendation configs")

# Get configs for specific recommendation
rec_configs = AdherenceCalculator.get_config_by_recommendation("REC0001")
print(f"REC0001 has {len(rec_configs)} levels")
```

---

## Database Schema (Supabase)

### Key Tables

**patient_details**
- Patient demographics, assigned clinician

**biomarker_readings**
- Lab values, vital signs
- Links to `intake_markers_raw`

**survey_responses**
- Survey answers
- Links to `survey_questions`

**adherence_tracking**
- Daily/weekly adherence data
- Links to recommendations

**patient_goals**
- Active patient goals (selected recommendations)
- 90-day cycles

**education_engagement**
- Article/module completion
- Time spent, completion percentage

---

## Troubleshooting

### "Module not found" errors

If you see:
```
ModuleNotFoundError: No module named 'preliminary_data'
```

**FIX:** Remove the import. Everything should be imported from local modules:
```python
# ❌ WRONG
from /Users/keegs/Documents/GitHub/preliminary_data/scripts/...

# ✅ CORRECT
from scoring_engine.adherence import AdherenceCalculator
```

### "Config not found" errors

Check that configs exist:
```bash
ls scoring_engine/adherence/configs/*.json | wc -l
# Should show 320+
```

If missing, copy from preliminary_data:
```bash
cp /Users/keegs/Library/CloudStorage/OneDrive-Personal/Documents/GitHub/preliminary_data/src/generated_configs/*.json scoring_engine/adherence/configs/
```

### Database connection issues

Check MCP/Supabase connection:
```python
from scoring_engine.utils.data_fetcher import DataFetcher

fetcher = DataFetcher()
# Should connect without errors
```

### Scoring returns all zeros

1. Check patient has data in database
2. Verify pillar weights are loaded
3. Check survey/biomarker scorers are working

```python
# Debug scoring
service = ScoringService()
service.calculate_patient_scores(patient_id="UUID", debug=True)
```

---

## Development Guidelines

### Adding New Algorithms

1. Create algorithm file in `scoring_engine/algorithms/`
2. Inherit from base algorithm class
3. Implement `calculate_score()` method
4. Add to `AdherenceCalculator.ALGORITHM_MAP`
5. Create documentation in `docs/algorithms/`

### Adding New Recommendation Configs

1. Add to `ALL_AIRTABLE/csvs/recommendations_v2.csv`
2. Run config generator (TODO: create this script)
3. Configs auto-generated to `scoring_engine/adherence/configs/`

### Testing

```bash
# Run all tests
pytest tests/

# Test specific component
pytest tests/test_adherence/

# Test with coverage
pytest --cov=scoring_engine tests/
```

---

## Key Differences from preliminary_data

**preliminary_data** = Research/testing repo with:
- Synthetic patient generation
- Algorithm development/testing
- Documentation generation
- Output analysis scripts

**WellPath-V2-Backend** = Production backend with:
- FastAPI endpoints
- Supabase integration
- Real patient data
- Complete adherence tracking
- Self-contained (no cross-repo deps)

---

## Contact & Support

**Repository:** WellPath-V2-Backend
**Database:** Supabase (csotzmardnvrpdhlogjm)
**API:** FastAPI on port 8000

**Documentation:**
- Algorithm docs: `docs/algorithms/`
- Adherence guide: `docs/adherence/WellPath-Adherence-System-Overview.md`
- Implementation guide: `docs/adherence/WellPath-Adherence-Scoring-Implementation-Guide.md`

---

## Quick Reference

### Patient Scoring Flow
1. Fetch patient data (biomarkers, surveys, education)
2. Score each component using configured weights
3. Combine into 7 pillar scores
4. Calculate overall score (weighted average)
5. Generate breakdown showing contributions

### Adherence Tracking Flow
1. Patient selects recommendations (becomes goals)
2. Track daily/weekly adherence data
3. Calculate adherence score using algorithm
4. Show dual progress (current vs. potential)
5. Trigger interventions (nudges/challenges) based on adherence

### Recommendation Matching Flow
1. Calculate patient pillar scores
2. Identify improvement opportunities (gap analysis)
3. Score recommendations by impact potential
4. AI selects 20 recommendations (2 per pillar + 6 best)
5. Patient/doctor review and select final goals

---

**Remember:** This is a COMPLETE, SELF-CONTAINED system. No external dependencies. Everything you need is here.
