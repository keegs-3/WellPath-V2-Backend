# Intelligent Assignment Specification

## What Makes an Assignment "Intelligent"

### Current (Basic):
```
Recommendation: "Increase vegetable intake"
Rationale: "Patient has elevated LDL"
Target: "Eat more vegetables daily"
```

### Target (Intelligent):
```
Recommendation: "Increase Fiber Intake"

Biomarker Connection:
  Primary Target: LDL (Current: 160 mg/dL → Goal: <100 mg/dL)
  Mechanism: Soluble fiber binds bile acids, forcing liver to use cholesterol
  Expected Impact: 10g fiber = 5-10% LDL reduction
  Timeline: 8-12 weeks

Trackable Goal:
  Metric: AGG_FIBER_DAILY (from aggregation_results_cache)
  Target: 30g fiber daily
  Current: Unknown (needs tracking)

Implementation Plan:
  Week 1-2: Track current fiber intake
  Week 3-4: Add 10g fiber (1 cup oats + 1 cup beans)
  Week 5-8: Reach 30g target

Specific Foods:
  - Breakfast: 1 cup oatmeal (8g fiber)
  - Lunch: 1 cup lentil soup (10g fiber)
  - Dinner: 2 cups roasted vegetables (6g fiber)
  - Snacks: Apple + almonds (6g fiber)
  Total: 30g

How It's Measured:
  - Track in food log (patient_data_entries: DEF_FIBER_GRAMS)
  - Auto-aggregates to AGG_FIBER_DAILY (daily period)
  - Agent scores adherence: actual vs. 30g target

Evidence:
  - Meta-analysis (PMID: 12345): 10g/day fiber → 10% LDL reduction
  - Study shows 30g fiber → HbA1c improvement
```

## Required Fields in Assignment

```json
{
  "rec_id": "fiber_intake",

  "biomarker_rationale": {
    "primary_targets": [
      {
        "biomarker": "LDL",
        "current_value": 160,
        "goal_value": 100,
        "unit": "mg/dL",
        "mechanism": "Fiber binds bile acids...",
        "expected_impact": "5-10% reduction per 10g fiber",
        "timeline_weeks": 8
      }
    ],
    "secondary_targets": [
      {
        "biomarker": "HbA1c",
        "current_value": 6.1,
        "expected_impact": "0.2-0.4% reduction"
      }
    ]
  },

  "trackable_goal": {
    "metric_id": "AGG_FIBER_DAILY",
    "target_value": 30,
    "unit": "grams",
    "period": "daily",
    "data_entry_field": "DEF_FIBER_GRAMS",
    "current_baseline": null  // Unknown - needs tracking
  },

  "progressive_plan": {
    "phase_1": {
      "weeks": "1-2",
      "goal": "Track current intake",
      "target": "Establish baseline"
    },
    "phase_2": {
      "weeks": "3-4",
      "goal": "Add 10g fiber daily",
      "target": "20g total"
    },
    "phase_3": {
      "weeks": "5-8",
      "goal": "Reach full target",
      "target": "30g daily"
    }
  },

  "implementation_details": {
    "specific_foods": [
      "1 cup oatmeal (8g fiber)",
      "1 cup black beans (12g fiber)",
      "2 cups vegetables (6g fiber)",
      "Apple + almonds (4g fiber)"
    ],
    "practical_tips": [
      "Prep beans on Sunday for the week",
      "Add ground flaxseed to smoothies",
      "Choose whole grain bread (3g vs 1g fiber)"
    ],
    "common_mistakes": [
      "Fiber supplements don't work as well as food",
      "Increase slowly to avoid GI discomfort",
      "Drink more water with increased fiber"
    ]
  },

  "measurement_strategy": {
    "how_tracked": "Log fiber in food diary",
    "aggregation": "AGG_FIBER_DAILY (SUM calculation)",
    "scoring_logic": "Daily adherence = actual_fiber / 30g * 100%",
    "success_metric": "80%+ days meeting 30g target"
  },

  "evidence": [
    {
      "study": "Meta-analysis of fiber and cholesterol",
      "finding": "10g fiber → 10% LDL reduction",
      "pmid": "12345678"
    }
  ],

  "priority": "high",
  "difficulty_level": 2
}
```

## Database Schema Updates Needed

The `patient_recommendations` table needs to store all this:

```sql
ALTER TABLE patient_recommendations ADD COLUMN IF NOT EXISTS assignment_detail JSONB;

-- Structure:
{
  "biomarker_targets": [...],
  "trackable_metric": {...},
  "progressive_plan": {...},
  "implementation_details": {...},
  "measurement_strategy": {...}
}
```

## Agent System Prompt Structure

```
You are assigning health recommendations with MAXIMUM specificity and intelligence.

For EACH recommendation, you MUST provide:

1. BIOMARKER CONNECTION (Required)
   - Which biomarkers are out of range
   - WHY this recommendation fixes them (mechanism)
   - Expected improvement (quantified)
   - Timeline

2. TRACKABLE GOAL (Required)
   - Specific metric (maps to AGG_* or DEF_* in database)
   - Exact target value
   - Current baseline (from survey or "unknown - needs tracking")

3. PROGRESSIVE PLAN (Required)
   - Phase 1: Track baseline
   - Phase 2: Small increase
   - Phase 3: Full target
   - Each phase has weeks + specific goal

4. IMPLEMENTATION (Required)
   - Specific foods/exercises with quantities
   - Practical tips
   - Common mistakes to avoid

5. MEASUREMENT (Required)
   - How it's tracked (food log, step counter, etc.)
   - Which database field (DEF_FIBER_GRAMS, AGG_STEPS_DAILY, etc.)
   - How adherence is scored

6. EVIDENCE (Optional but preferred)
   - Studies supporting this intervention
   - Quantified expected outcomes

Be MAXIMALLY specific. No generic advice.
```

This is what we should build. Want me to implement this enhanced structure?