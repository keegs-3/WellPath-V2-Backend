# Therapeutic Adherence Algorithm

## Overview

The `therapeutic_adherence` algorithm tracks adherence to therapeutic interventions including supplements, peptides, and medications. It supports **1-3 stacked therapeutics** per recommendation, making it perfect for complex protocols like peptide stacks or comprehensive supplement regimens.

## Key Features

- **Multi-Therapeutic Support**: Track 1-3 therapeutics in a single recommendation
- **Complex Dosing**: Min/max dose ranges with human-readable display (e.g., "10-20 mg")
- **Variable Frequencies**: Daily, nightly, weekly, "2-3x weekly", etc.
- **Status-Based Tracking**: scheduled/taken/missed/skipped compliance
- **Average Scoring**: Overall adherence = average across all therapeutics in stack

## Algorithm Logic

```
Overall Adherence = Σ(Individual Therapeutic Adherence) / Number of Therapeutics

Where each therapeutic adherence is calculated as:
- taken/compliant: 100%
- scheduled: 0%
- missed: 0% 
- skipped: 0%
- partial: 50%
- late: 80%
- early: 90%
- not_due: 100%
```

## Configuration Examples

### Single Supplement
```json
{
  "config_id": "SUP001.1-THERAPEUTIC-ADHERENCE",
  "therapeutics": [
    {
      "name": "Zinc",
      "type": "supplement", 
      "dose_min": 10,
      "dose_max": 20,
      "unit": "mg",
      "rollup": "10-20 mg",
      "frequency": "daily"
    }
  ]
}
```

### Peptide Stack
```json
{
  "config_id": "PEP005.1-THERAPEUTIC-ADHERENCE",
  "therapeutics": [
    {
      "name": "Epitalon",
      "type": "peptide",
      "dose_min": 5,
      "dose_max": 10, 
      "unit": "mg",
      "rollup": "5-10 mg",
      "frequency": "2x weekly"
    },
    {
      "name": "Thymalin",
      "type": "peptide",
      "dose_min": 10,
      "dose_max": 20,
      "unit": "mg", 
      "rollup": "10-20 mg",
      "frequency": "weekly"
    }
  ]
}
```

### Triple Medication Stack
```json
{
  "config_id": "MED005.1-THERAPEUTIC-ADHERENCE",
  "therapeutics": [
    {
      "name": "Metformin",
      "type": "medication",
      "dose_min": 500,
      "dose_max": 1000,
      "unit": "mg",
      "frequency": "daily"
    },
    {
      "name": "Empagliflozin", 
      "type": "medication",
      "dose_min": 10,
      "dose_max": 25,
      "unit": "mg",
      "frequency": "daily"
    },
    {
      "name": "Lisinopril",
      "type": "medication", 
      "dose_min": 10,
      "dose_max": 40,
      "unit": "mg",
      "frequency": "daily"
    }
  ]
}
```

## Data Input Formats

### Single Therapeutic
```python
daily_values = ["taken", "taken", "missed", "taken", "skipped"]
```

### Multi-Therapeutic Stack
```python
daily_values = [
  {
    "therapeutic_1": "taken",
    "therapeutic_2": "taken", 
    "therapeutic_3": "missed"
  },
  {
    "therapeutic_1": "taken",
    "therapeutic_2": "skipped",
    "therapeutic_3": "taken" 
  }
]
```

## Compliance Status Values

| Status | Adherence % | Description |
|--------|-------------|-------------|
| `taken` | 100% | Dose taken as scheduled |
| `compliant` | 100% | Alternative to "taken" |
| `scheduled` | 0% | Due today but not yet taken |
| `missed` | 0% | Scheduled dose not taken |
| `skipped` | 0% | Intentionally skipped |
| `partial` | 50% | Partial dose taken |
| `late` | 80% | Taken late but within window |
| `early` | 90% | Taken early |
| `not_due` | 100% | Not scheduled today |

## Dual Progress Output

```python
{
  'progress_towards_goal': 83.3,  # Current average adherence
  'max_potential_adherence': 95.0,  # Max possible if perfect going forward
  'algorithm_details': {
    'algorithm_type': 'therapeutic_adherence',
    'therapeutics_count': 3,
    'therapeutic_breakdown': {
      'therapeutic_1': {'status': 'taken', 'adherence_percent': 100.0},
      'therapeutic_2': {'status': 'taken', 'adherence_percent': 100.0}, 
      'therapeutic_3': {'status': 'missed', 'adherence_percent': 0.0}
    }
  }
}
```

## Generated Configurations

**Total**: 106 configurations
- **Supplements (27)**: SUP001-SINGLE through SUP027-SINGLE (including vitamin stacks)
- **Peptides (24)**: PEP001-SINGLE through PEP024-SINGLE (including growth hormone stacks)  
- **Medications (54)**: MED001(i)-SINGLE through MED034-SINGLE (covering cardiovascular, metabolic, mental health)
- **Multi-type Stacks (1)**: MULTI001-STACK (Empagliflozin + Semaglutide + Metformin)

### Naming Convention:
- **SINGLE**: Individual therapeutic (e.g., SUP001-SINGLE, PEP004-SINGLE, MED008-SINGLE)
- **STACK**: Multiple therapeutics in combination (e.g., SUP010-STACK, PEP003-STACK, MULTI001-STACK)
- **Variants**: Some therapeutics have multiple variants (e.g., SUP007(i)-SINGLE, SUP007(ii)-SINGLE)

## Widget Integration

The therapeutic_adherence algorithm integrates with the medication/supplement widget system:

- **Dashboard Cards**: Show daily adherence status for each therapeutic
- **Quick Logging**: Mark taken/skipped for individual therapeutics
- **Progress Tracking**: Visual progress rings for overall adherence
- **Dosage Validation**: Min/max range checking with alerts

## Use Cases

### Perfect For:
- Daily supplement regimens
- Complex peptide protocols 
- Medication adherence tracking
- Multi-therapeutic stacks
- Longevity intervention tracking

### Key Benefits:
- Handles 1-3 therapeutics per recommendation
- Flexible dosing ranges (10-20mg, 600-1200mg, etc.)
- Complex frequency patterns (2-3x weekly, nightly, etc.)
- Individual therapeutic performance tracking
- Average scoring across entire stack

---

*This algorithm enables WellPath to track the most sophisticated therapeutic protocols while maintaining simplicity for basic supplement adherence.*