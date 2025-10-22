# Completion Based Algorithm

The **completion_based** algorithm is the simplest algorithm in the WellPath system, designed specifically for one-time screening recommendations and completion tasks within 90-day cycles.

## Overview

This algorithm tracks binary completion status for screening recommendations like dental cleanings, mammograms, colonoscopies, and annual physicals. Unlike behavioral recommendations that require ongoing daily or weekly tracking, completion-based recommendations are either completed or not completed within the recommendation cycle.

## Key Characteristics

- **Binary Completion**: Either 0% (not completed) or 100% (completed)
- **Persistent Progress**: Once completed, maintains 100% for remainder of 90-day cycle
- **Simple Implementation**: Only requires one calculated metric parameter
- **Leverages Existing Infrastructure**: Uses compliance calculated metrics already built for screening

## Algorithm Logic

```
If compliance_status == "compliant":
    Progress = 100%
    Max Potential = 100% (stays at 100% for rest of cycle)
Else:
    Progress = 0%
    Max Potential = 100% (can always still complete it)
```

## Dual Progress Behavior

### Example: Dental Cleaning Recommendation

| Day | Compliance Status | Progress | Max Potential | Status |
|-----|------------------|----------|---------------|---------|
| 1-10 | "overdue" | 0% | 100% | Not completed |
| 11 | "compliant" | 100% | 100% | ✅ Completed |
| 12-90 | "compliant" | 100% | 100% | ✅ Stays completed |

## Schema Configuration

### Required Parameters

- **`calculated_metric`**: The compliance calculated metric to track
  - Example: `"current_compliance_dental_male_female_0_150_avg_custom_calc"`

### Standard Parameters

- **`unit`**: "completion" (default)
- **`progress_direction`**: "completion" (default)
- **`required_days`**: 1 (either done or not)
- **`total_days`**: 90 (recommendation cycle length)
- **`daily_limit`**: 1 (can only complete once per cycle)
- **`persistent_scoring`**: true (maintains 100% after completion)

## Example Configuration

```json
{
  "config_id": "COMPLETION-BASED-REC0060.1",
  "config_name": "Completion Based - dental_cleaning",
  "scoring_method": "completion_based",
  "configuration_json": {
    "method": "completion_based",
    "formula": "Binary completion: 0% until completed, then 100% for remainder of cycle",
    "evaluation_pattern": "completion",
    "schema": {
      "calculated_metric": "current_compliance_dental_male_female_0_150_avg_custom_calc",
      "measurement_type": "completion",
      "evaluation_period": "cycle",
      "success_criteria": "completion",
      "calculation_method": "completion_check",
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

## Integration with Compliance System

The completion_based algorithm leverages WellPath's existing compliance calculated metrics:

### Available Compliance Metrics

- **Dental**: `current_compliance_dental_male_female_0_150_avg_custom_calc`
- **Mammogram**: `current_compliance_mammogram_female_50_150_avg_high_custom_calc`
- **Colonoscopy**: `current_compliance_colonoscopy_male_female_0_150_avg_custom_calc`
- **Annual Physical**: `current_compliance_physical_male_female_0_150_avg_custom_calc`
- **Vision Check**: `current_compliance_vision_check_male_female_0_150_avg_custom_calc`
- **Skin Cancer Screening**: `current_compliance_skin_check_male_female_0_150_avg_custom_calc`
- **HPV Screening**: `current_compliance_cervical_hpv_female_0_64.9_avg_custom_calc` (5-year intervals)
- **Pap Smear**: `current_compliance_cervical_pap_female_0_64.9_avg_custom_calc` (3-year intervals)

### Compliance Status Values

- **`"compliant"`**: Patient is up to date with screening
- **`"overdue"`**: Patient needs to schedule/complete screening
- **`"due_soon"`**: Patient is approaching due date
- **`"not_applicable"`**: Screening not applicable for this patient

## Use Cases

### Perfect For

1. **Screening Recommendations**: Dental cleanings, mammograms, colonoscopies, HPV screenings, Pap smears
2. **Annual Checkups**: Physical exams, vision screenings, skin checks
3. **One-Time Completions**: Lab work orders, specialist consultations
4. **Certification Renewals**: CPR training, safety certifications

### Not Suitable For

1. **Daily Behaviors**: Exercise, nutrition, sleep tracking
2. **Weekly Patterns**: Meal planning, workout schedules
3. **Progressive Goals**: Step counts, strength improvements
4. **Complex Metrics**: Multi-component health behaviors

## Patient Experience

### Recommendation Flow

1. **Patient Assessment**: Compliance metrics identify overdue screenings
2. **Recommendation Generation**: Only overdue patients receive recommendations
3. **Goal Assignment**: Recommendation becomes trackable 90-day goal
4. **Completion Tracking**: Binary progress (0% → 100%)
5. **Persistent Success**: Maintains 100% score after completion

### User Interface Implications

- **Clear Binary Status**: "Not Completed" vs "Completed"
- **Scheduling Integration**: Direct links to booking systems
- **Progress Indicators**: Simple binary progress bars
- **Achievement Recognition**: Clear completion celebrations

## Implementation Notes

### Simplicity Benefits

- **Minimal Configuration**: Only one required parameter
- **Easy Testing**: Simple binary test cases
- **Clear Semantics**: Obvious behavior and expectations
- **Reliable Scoring**: No complex edge cases or calculations

### Technical Integration

- **Existing Infrastructure**: Leverages compliance calculated metrics
- **Standard Interfaces**: Compatible with dual progress system
- **Configuration Driven**: No hardcoded logic required
- **Scalable Design**: Easy to add new screening types

## Testing Scenarios

### Standard Test Cases

1. **Not Yet Completed**: Verify 0% progress, 100% potential
2. **Completed During Cycle**: Verify 100% progress and potential
3. **Persistent Completion**: Verify maintained 100% after completion
4. **No Data Available**: Verify graceful handling of missing data
5. **Edge Cases**: Invalid compliance status values

### Example Test Data

```python
# Not completed
daily_values = ["overdue"] * 7
assert progress == 0.0 and potential == 100.0

# Completed on day 3
daily_values = ["overdue", "overdue", "compliant", "compliant", "compliant"]
assert progress == 100.0 and potential == 100.0 on days 3-5

# Final score
assert final_score == 100.0 if any(status == "compliant" for status in daily_values)
```

## Comparison with Other Algorithms

| Algorithm | Complexity | Use Case | Scoring Pattern |
|-----------|------------|----------|-----------------|
| **completion_based** | Minimal | One-time tasks | Binary: 0% → 100% |
| binary_threshold | Simple | Daily compliance | Binary: pass/fail daily |
| minimum_frequency | Medium | Weekly patterns | Frequency-based |
| proportional | Medium | Progressive goals | Gradual: 0-100% |
| composite_weighted | High | Multi-component | Weighted combinations |

## Future Enhancements

### Potential Extensions

1. **Recurring Completions**: Support for annual/periodic renewals
2. **Deadline Pressure**: Increasing urgency as cycle progresses
3. **Completion Quality**: Different completion levels (basic vs comprehensive)
4. **Integration Hooks**: Direct scheduling system connections

### Configuration Flexibility

While keeping the algorithm simple, future versions could support:

- **Custom Cycle Lengths**: Beyond 90-day standard
- **Grace Periods**: Buffer time after completion
- **Reminder Schedules**: Integrated nudge timing
- **Provider Coordination**: Healthcare provider notification systems

The completion_based algorithm represents the perfect balance of simplicity and functionality for screening recommendations, providing clear tracking without unnecessary complexity.