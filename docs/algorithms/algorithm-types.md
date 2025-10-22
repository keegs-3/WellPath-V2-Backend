# Algorithm Types Overview

WellPath uses 14 sophisticated algorithm types to handle every possible behavioral pattern and health goal tracking scenario.

## Core Algorithm Types

### [Binary Threshold](binary-threshold.md)
Simple pass/fail scoring for clear compliance goals.
- Example: "Drink 8 glasses of water daily" → 100% or 0%

### [Minimum Frequency](minimum-frequency.md)  
Weekly patterns with minimum requirements.
- Example: "Exercise 30+ minutes on at least 3 days/week"

### [Proportional](proportional.md)
Gradual scoring based on achievement percentage.
- Example: "Work toward 10,000 steps daily" → 80% for 8,000 steps

### [Zone-Based](zone-based.md)
Multi-tier scoring with optimal performance ranges.
- Example: "Sleep 7-9 hours" → 100% optimal, 60% fair, 20% poor

### [Composite Weighted](composite-weighted.md)
Multiple component combinations with weighted scoring.
- Example: "Overall fitness = 40% exercise + 30% steps + 30% active minutes"

### [Weekly Elimination](SC-WEEKLY-ELIMINATION.md)
Zero tolerance patterns requiring perfect weekly compliance.
- Example: "No smoking every day of the week"

### [Sleep Composite](sleep-composite.md)
Advanced sleep optimization with multiple sleep metrics.

### [Categorical Filter](categorical-filter-threshold.md)
Category-based filtering with threshold requirements.

### [Constrained Weekly Allowance](constrained-weekly-allowance.md)
Weekly limits with allowance-based tracking.

### [Proportional Frequency Hybrid](proportional-frequency-hybrid.md)
Combined proportional and frequency-based scoring.

### [Baseline Consistency](baseline-consistency.md)
Personal baseline tracking for habit formation.

### [Weekend Variance](weekend-variance.md)
Weekend pattern analysis and flexibility accommodation.

### [Completion Based](completion-based.md)
Simple completion tracking for one-time screening and completion tasks.
- Example: "Schedule dental cleaning within 90 days" → 0% until completed, then 100%

### [Therapeutic Adherence](therapeutic-adherence.md)
Multi-therapeutic adherence tracking for supplements, peptides, and medications.
- Example: "Take CJC-1295 + Ipamorelin stack every 3 days" → Average adherence across both therapeutics

## Algorithm Selection

Each recommendation is matched with the most appropriate algorithm type based on:

- **Behavioral Pattern**: The natural way the behavior occurs
- **Measurement Type**: How the behavior can be quantified
- **Goal Structure**: Whether the goal is binary, progressive, or complex
- **Patient Preferences**: Individual tracking and motivation preferences

## Implementation

All algorithms are configuration-driven, using JSON schemas that define:

- Scoring parameters
- Threshold values
- Weighting factors
- Time windows
- Compliance rules

This approach enables infinite recommendation expansion without custom development while maintaining consistent scoring principles across all health behaviors.

## Testing and Validation

Every algorithm type is thoroughly tested with:

- Edge case scenarios
- Real patient data patterns
- Synthetic patient profiles
- Cross-validation studies

See individual algorithm documentation for detailed specifications and implementation examples.