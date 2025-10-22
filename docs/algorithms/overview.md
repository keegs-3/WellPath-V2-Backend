# WellPath Progress Tracking Algorithms - Complete Reference

This document provides comprehensive definitions and examples for all WellPath progress tracking algorithm types used for monitoring patient adherence and goal achievement.

## Progress Tracking Algorithm Classification

WellPath uses a **14-type progress tracking algorithm system** designed to handle all health and wellness behavioral patterns for recommendation adherence:

```
WellPath Progress Tracking Algorithms (14 Types)
├── Binary Threshold (SC-BINARY-*)
│   ├── Daily (SC-BINARY-DAILY)
│   └── Frequency (SC-BINARY-FREQUENCY) [DEPRECATED]
├── Minimum Frequency (SC-MINIMUM-FREQUENCY) 
├── Weekly Elimination (SC-WEEKLY-ELIMINATION)  
├── Proportional (SC-PROPORTIONAL-*)
│   ├── Daily (SC-PROPORTIONAL-DAILY)
│   └── Frequency (SC-PROPORTIONAL-FREQUENCY)
├── Proportional Frequency Hybrid (SC-PROPORTIONAL-FREQUENCY-HYBRID) 
├── Zone-Based (SC-ZONE-BASED-*)
│   ├── Daily (SC-ZONE-BASED-DAILY)  
│   └── Frequency (SC-ZONE-BASED-FREQUENCY)
├── Composite Weighted (SC-COMPOSITE-*)
│   ├── Daily (SC-COMPOSITE-DAILY)
│   └── Frequency (SC-COMPOSITE-FREQUENCY)
├── Sleep Composite (SC-COMPOSITE-SLEEP-ADVANCED)
├── Categorical Filter Threshold (SC-CATEGORICAL-FILTER-*)
│   ├── Daily (SC-CATEGORICAL-FILTER-DAILY)
│   └── Frequency (SC-CATEGORICAL-FILTER-FREQUENCY)
├── Constrained Weekly Allowance (SC-CONSTRAINED-WEEKLY-ALLOWANCE)
├── Baseline Consistency (SC-BASELINE-CONSISTENCY)
├── Weekend Variance (SC-WEEKEND-VARIANCE)
├── Completion Based (COMPLETION-BASED)
└── Therapeutic Adherence (THERAPEUTIC-ADHERENCE)
```

## 1. Binary Threshold Algorithms

### 1.1 SC-BINARY-DAILY
**Purpose:** Simple daily pass/fail scoring  
**Pattern:** Single threshold evaluation per day  
**Scoring:** Binary (100 or 0)  
**Formula:** `if (actual_value >= threshold) then 100 else 0`

**Configuration Example:**
```json
{
  "config_id": "SC-BINARY-DAILY-WATER_8_GLASSES",
  "scoring_method": "binary_threshold",
  "configuration_json": {
    "method": "binary_threshold",
    "evaluation_pattern": "daily",
    "schema": {
      "threshold": 8,
      "comparison_operator": ">=",
      "success_value": 100,
      "failure_value": 0,
      "unit": "glasses"
    }
  }
}
```

**Use Cases:**
- "Drink 8 glasses of water daily"
- "Complete 30-minute workout daily"  
- "Take vitamins daily"
- "Meditate for 10 minutes daily"

### 1.2 SC-BINARY-FREQUENCY [DEPRECATED]
**Status:** **DEPRECATED - Use SC-MINIMUM-FREQUENCY instead**

This pattern was replaced because "binary frequency" was ambiguous. The new SC-MINIMUM-FREQUENCY algorithm explicitly handles "achieve threshold on at least X days per week" patterns.

## 2. Minimum Frequency Algorithm 

### SC-MINIMUM-FREQUENCY  
**Purpose:** Must achieve threshold on minimum number of days per week  
**Pattern:** Weekly evaluation with daily threshold checks  
**Scoring:** Binary (100 if ≥required_days meet threshold, 0 otherwise)  
**Formula:** `100 if days_meeting_threshold >= required_days else 0`

**Configuration Example:**
```json
{
  "config_id": "SC-MIN-FREQ-CAFFEINE_400MG_5_DAYS",
  "scoring_method": "minimum_frequency",
  "configuration_json": {
    "method": "minimum_frequency",
    "evaluation_pattern": "weekly_minimum_frequency",
    "schema": {
      "daily_threshold": 400,
      "daily_comparison": "<=",
      "required_days": 5,
      "total_days": 7,
      "success_value": 100,
      "failure_value": 0,
      "unit": "mg"
    }
  }
}
```

**Algorithm Implementation:**
```python
from algorithms.minimum_frequency import calculate_minimum_frequency_score

result = calculate_minimum_frequency_score(
    daily_values=[350, 450, 380, 420, 370, 390, 410],  # Weekly data
    daily_threshold=400,
    daily_comparison="<=",
    required_days=5
)
# Returns: {
#   'score': 100,
#   'successful_days': 6,
#   'required_days': 5,
#   'threshold_met': True,
#   'success_rate': 0.857,
#   'daily_breakdown': [...],
#   'algorithm': 'SC-MINIMUM-FREQUENCY'
# }
```

**Use Cases:**
- "Limit caffeine to ≤400mg on at least 5 days per week"
- "Finish eating by 7pm on at least 4 days per week"  
- "Exercise for 30+ minutes on at least 3 days per week"
- "Get 8+ hours sleep on at least 5 days per week"

## 3. Weekly Elimination Algorithm 

### SC-WEEKLY-ELIMINATION
**Purpose:** Zero tolerance patterns - any violation fails entire week  
**Pattern:** Weekly evaluation with daily requirements  
**Scoring:** Binary (100 if perfect week, 0 if any violation)  
**Formula:** `100 if all_days_meet_elimination_criteria else 0`

**Configuration Example:**
```json
{
  "config_id": "SC-WEEKLY-ELIM-CAFFEINE_TIMING_2PM_DAILY",
  "scoring_method": "weekly_elimination",
  "configuration_json": {
    "method": "weekly_elimination",
    "evaluation_pattern": "weekly_elimination",
    "schema": {
      "elimination_threshold": "14:00",
      "elimination_comparison": "<=",
      "total_days": 7,
      "tolerance_level": "zero",
      "success_value": 100,
      "failure_value": 0,
      "unit": "time"
    }
  }
}
```

**Algorithm Implementation:**
```python
from algorithms.weekly_elimination import calculate_weekly_elimination_score

result = calculate_weekly_elimination_score(
    daily_values=["13:30", "14:00", "13:45", "15:00", "13:30", "14:00", "13:00"],
    elimination_threshold="14:00",
    elimination_comparison="<="
)
# Returns: {
#   'score': 0,
#   'violations': 1,
#   'violation_days': [4],
#   'clean_days': 6,
#   'elimination_achieved': False,
#   'daily_breakdown': [...],
#   'algorithm': 'SC-WEEKLY-ELIMINATION'
# }
```

**Use Cases:**
- "No smoking every day of the week"
- "Finish all caffeinated beverages by 2pm every day"
- "Stay within 8-hour eating window every day"  
- "No ultra-processed foods every day"
- "Complete elimination of specific substances/behaviors"

**Specialized Variations:**
- `calculate_weekly_limit_score()` - Weekly sum limits (≤2 takeout meals/week)
- `calculate_monthly_limit_score()` - Monthly sum limits

## 4. Proportional Algorithms

### 4.1 SC-PROPORTIONAL-DAILY
**Purpose:** Gradual scoring based on percentage of target achieved  
**Pattern:** Daily evaluation with continuous scoring  
**Scoring:** Continuous (0-100 based on achievement percentage)  
**Formula:** `(actual_value / target) * 100` (with caps and minimums)

**Configuration Example:**
```json
{
  "config_id": "SC-PROPORTIONAL-DAILY-STEPS_10000",
  "scoring_method": "proportional",
  "configuration_json": {
    "method": "proportional", 
    "evaluation_pattern": "daily",
    "schema": {
      "target": 10000,
      "unit": "steps",
      "maximum_cap": 100,
      "minimum_threshold": 20,
      "progress_direction": "buildup"
    }
  }
}
```

**Use Cases:**
- "Work toward 10,000 steps daily"
- "Increase water intake toward 8 glasses"
- "Build up to 30g fiber daily"
- "Progressive goal achievement"

### 4.2 SC-PROPORTIONAL-FREQUENCY  
**Purpose:** Proportional scoring for frequency-based goals  
**Pattern:** Weekly evaluation with proportional achievement  
**Scoring:** Continuous based on frequency achievement rate

**Use Cases:**
- "Work toward exercising 5 days per week"
- "Gradually increase meditation frequency"

## 5. Zone-Based Algorithms

### 5.1 SC-ZONE-BASED-DAILY
**Purpose:** Multi-tier scoring based on performance zones  
**Pattern:** Daily evaluation with predefined score zones  
**Scoring:** Zone-specific scores (e.g., Poor=25, Good=75, Excellent=100)

**Configuration Example:**
```json
{
  "config_id": "SC-ZONE-BASED-SLEEP_DURATION_5_TIER",
  "scoring_method": "zone_based",
  "configuration_json": {
    "method": "zone_based",
    "evaluation_pattern": "daily",
    "schema": {
      "zones": [
        {"min": 0, "max": 5, "score": 25, "label": "Poor"},
        {"min": 5, "max": 6.5, "score": 50, "label": "Fair"},
        {"min": 6.5, "max": 7.5, "score": 75, "label": "Good"},
        {"min": 7.5, "max": 9, "score": 100, "label": "Excellent"},
        {"min": 9, "max": 12, "score": 75, "label": "Too Much"}
      ],
      "tier_count": 5,
      "unit": "hours"
    }
  }
}
```

**Use Cases:**
- Sleep duration scoring (optimal zones)
- Heart rate zone training
- Blood pressure categories
- Any metric with "optimal ranges"

## 6. Composite Weighted Algorithms

### 6.1 SC-COMPOSITE-DAILY
**Purpose:** Weighted combination of multiple components  
**Pattern:** Daily evaluation combining multiple metrics  
**Scoring:** Weighted average of component scores

**Configuration Example:**
```json
{
  "config_id": "SC-COMPOSITE-FITNESS_DAILY",
  "scoring_method": "composite_weighted",
  "configuration_json": {
    "method": "composite_weighted",
    "evaluation_pattern": "daily", 
    "schema": {
      "components": [
        {"name": "Exercise Duration", "weight": 0.4, "target": 30, "unit": "minutes"},
        {"name": "Steps", "weight": 0.3, "target": 10000, "unit": "steps"},
        {"name": "Active Minutes", "weight": 0.3, "target": 150, "unit": "minutes"}
      ]
    }
  }
}
```

**Use Cases:**
- Overall fitness scores
- Comprehensive wellness assessments
- Multi-factor health metrics

## 7. Completion Based Algorithm

### COMPLETION-BASED
**Purpose:** Simple completion tracking for one-time screening and completion tasks  
**Pattern:** Binary completion within 90-day recommendation cycle  
**Scoring:** Binary (0% until completed, then 100% for remainder of cycle)  
**Formula:** `100 if compliance_status == "compliant" else 0`

**Configuration Example:**
```json
{
  "config_id": "COMPLETION-BASED-REC0060.1",
  "scoring_method": "completion_based",
  "configuration_json": {
    "method": "completion_based",
    "evaluation_pattern": "completion",
    "schema": {
      "calculated_metric": "current_compliance_dental_male_female_0_150_avg_custom_calc",
      "unit": "completion",
      "progress_direction": "completion",
      "required_days": 1,
      "total_days": 90,
      "daily_limit": 1,
      "persistent_scoring": true
    }
  }
}
```

**Algorithm Implementation:**
```python
from algorithms.completion_based import calculate_completion_based_dual_progress

result = calculate_completion_based_dual_progress(
    daily_values=["overdue", "overdue", "compliant", "compliant"],
    current_day=4,
    calculated_metric="current_compliance_dental_male_female_0_150_avg_custom_calc"
)
# Returns: {
#   'progress_towards_goal': 100.0,
#   'max_potential_adherence': 100.0,
#   'algorithm_details': {
#     'completion_status': 'completed',
#     'current_compliance_status': 'compliant'
#   }
# }
```

**Use Cases:**
- "Schedule dental cleaning within 90 days"
- "Complete mammogram screening within 90 days"
- "Get annual physical exam within 90 days"
- "Schedule colonoscopy within 90 days"
- Any one-time screening or completion task

**Key Features:**
- **Persistent Progress**: Once completed, stays at 100% for remainder of cycle
- **Leverages Compliance Metrics**: Uses existing compliance calculated metrics
- **Simplest Algorithm**: Only requires one calculated_metric parameter
- **Perfect for Screenings**: Designed specifically for healthcare screening recommendations

## Algorithm Selection Decision Tree

```
What type of behavior are you tracking?

├─ SINGLE METRIC TRACKING
│  ├─ Pass/Fail Compliance?
│  │  ├─ Daily requirement → SC-BINARY-DAILY
│  │  ├─ Weekly frequency requirement → SC-BINARY-FREQUENCY [DEPRECATED → SC-MINIMUM-FREQUENCY]
│  │  ├─ Zero tolerance (any failure = week fails) → SC-WEEKLY-ELIMINATION
│  │  └─ Minimum frequency ("at least X days/week") → SC-MINIMUM-FREQUENCY
│  │
│  ├─ Gradual Improvement Tracking?
│  │  ├─ Daily target progress → SC-PROPORTIONAL-DAILY  
│  │  ├─ Weekly frequency progress → SC-PROPORTIONAL-FREQUENCY
│  │  └─ Hybrid (frequency + progress) → SC-PROPORTIONAL-FREQUENCY-HYBRID
│  │
│  ├─ Optimal Range Tracking?
│  │  ├─ Daily optimal zones → SC-ZONE-BASED-DAILY
│  │  └─ Weekly frequency in zones → SC-ZONE-BASED-FREQUENCY
│  │
│  ├─ Category-Specific Requirements?
│  │  ├─ Daily category filtering → SC-CATEGORICAL-FILTER-DAILY
│  │  └─ Weekly category filtering → SC-CATEGORICAL-FILTER-FREQUENCY
│  │
│  ├─ Personal Baseline Consistency?
│  │  └─ Maintain individual patterns → SC-BASELINE-CONSISTENCY
│  │
│  ├─ Weekend vs Weekday Flexibility?
│  │  └─ Different weekend expectations → SC-WEEKEND-VARIANCE
│  │
│  └─ Weekly Allowance/Budget?
│     └─ Limited weekly portions → SC-CONSTRAINED-WEEKLY-ALLOWANCE
│
├─ MULTIPLE METRIC TRACKING
│  ├─ General multi-component goals → SC-COMPOSITE-DAILY / SC-COMPOSITE-FREQUENCY
│  └─ Sleep-specific multi-metrics → SC-COMPOSITE-SLEEP-ADVANCED
│
└─ SPECIAL CASES
   ├─ One-time completion tasks → COMPLETION-BASED
   ├─ Complex sleep optimization → SC-COMPOSITE-SLEEP-ADVANCED
   ├─ Food/supplement portions → SC-CONSTRAINED-WEEKLY-ALLOWANCE  
   ├─ Personal habit consistency → SC-BASELINE-CONSISTENCY
   └─ Lifestyle flexibility needs → SC-WEEKEND-VARIANCE
```

## Migration Guide: Deprecated Patterns

### SC-BINARY-FREQUENCY → SC-MINIMUM-FREQUENCY
**Old Pattern (Deprecated):**
```json
{
  "scoring_method": "binary_threshold",
  "configuration_json": {
    "method": "binary_threshold", 
    "evaluation_pattern": "weekly_frequency"
  }
}
```

**New Pattern:**
```json
{
  "scoring_method": "minimum_frequency",
  "configuration_json": {
    "method": "minimum_frequency",
    "evaluation_pattern": "weekly_minimum_frequency"
  }
}
```

### SC-BINARY-DAILY → SC-WEEKLY-ELIMINATION (when appropriate)
**When to Migrate:**
- Recommendation says "every day" with zero tolerance
- Any single day failure should fail the entire week
- Complete elimination patterns

**Migration Example:**
```json
// OLD: Daily binary that should be weekly elimination
{
  "scoring_method": "binary_threshold",
  "evaluation_pattern": "daily"
}

// NEW: Weekly elimination with zero tolerance  
{
  "scoring_method": "weekly_elimination", 
  "evaluation_pattern": "weekly_elimination"
}
```

## 14. Therapeutic Adherence Algorithm

### 14.1 THERAPEUTIC-ADHERENCE
**Purpose:** Multi-therapeutic adherence tracking for supplements, peptides, and medications  
**Pattern:** 1-3 stacked therapeutics per recommendation with status-based compliance  
**Scoring:** Average adherence across all therapeutics in stack  
**Formula:** `Overall Adherence = Σ(Individual Therapeutic Adherence) / Number of Therapeutics`

**Key Features:**
- **Multi-Therapeutic Support**: Track 1-3 therapeutics in a single recommendation
- **Complex Dosing**: Min/max dose ranges with human-readable display (e.g., "10-20 mg")
- **Variable Frequencies**: Daily, nightly, weekly, "every 3 days", etc.
- **Status-Based Tracking**: taken/missed/scheduled/skipped compliance
- **Stacked Protocols**: Perfect for peptide stacks and complex supplement regimens

**Configuration Example:**
```json
{
  "scoring_method": "therapeutic_adherence",
  "configuration_json": {
    "schema": {
      "therapeutics": [
        {
          "name": "CJC-1295",
          "type": "PEP",
          "dose_min": 100.0,
          "dose_max": 200.0,
          "unit_symbol": "µg",
          "frequency": "every 3 days",
          "timing": "Before bed"
        },
        {
          "name": "Ipamorelin", 
          "type": "PEP",
          "dose_min": 200.0,
          "dose_max": 300.0,
          "unit_symbol": "µg",
          "frequency": "every 3 days",
          "timing": "Empty stomach"
        }
      ],
      "therapeutics_count": 2,
      "target_adherence": 90.0
    }
  }
}
```

**Naming Convention:**
- SUP001-SINGLE: Individual supplement
- PEP003-STACK: Peptide combination stack
- MED008-SINGLE: Individual medication
- MULTI001-STACK: Multi-type therapeutic stack

**Generated Configurations:** 106 total
- Supplements (27): SUP001-SINGLE through SUP027-SINGLE
- Peptides (24): PEP001-SINGLE through PEP024-SINGLE  
- Medications (54): MED001(i)-SINGLE through MED034-SINGLE
- Multi-type Stacks (1): MULTI001-STACK

## Testing & Validation

Each algorithm type has comprehensive test coverage:

```bash
# Test minimum frequency algorithms
python test_complex_config_validation.py "configs/REC0013.1-BINARY-FREQUENCY.json"

# Test weekly elimination algorithms  
python test_complex_config_validation.py "configs/REC0013.3-BINARY-DAILY.json"

# Test all configurations
python tests/test_with_csv_configs.py
```

## Implementation Status

| Algorithm Type | Implementation | Testing | Documentation |
|----------------|----------------|---------|---------------|
| Binary Threshold | Complete | Complete | Complete |
| Minimum Frequency | Complete | Complete | Complete |
| Weekly Elimination | Complete | Complete | Complete |
| Proportional | Complete | Complete | Complete |
| Zone-Based | Complete | Complete | Complete |
| Composite Weighted | Complete | Complete | Complete |
| Completion Based | Complete | Complete | Complete |
| Therapeutic Adherence | Complete | Complete | Complete |

---

*Last Updated: 2025-09-27 - Added THERAPEUTIC-ADHERENCE algorithm (14th algorithm) for supplements, peptides, and medications*