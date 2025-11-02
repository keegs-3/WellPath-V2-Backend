# Patient Data Generator

Two-stage system for creating realistic test patients with internally consistent data.

## Stage 1: Initial Patient Creation
Creates baseline patient profile from archetype.

**Archetypes:**
- `high_performer` - Excellent health, good habits, markers reflect it
- `inconsistent` - Claims good habits but markers/body comp don't match
- `struggling` - Poor habits, declining markers
- `metabolic_syndrome` - Multiple elevated markers
- `injury_recovery` - Good baseline but currently injured

**Output:**
- `patient_biomarker_readings` - Lab results
- `patient_biometric_readings` - Vitals, body composition
- `patient_survey_responses` - Self-reported behaviors

## Stage 2: Adherence Simulation
Generates daily tracking data over time periods.

**Week Types:**
- `optimal_week` - 85-95% adherence
- `moderate_week` - 60-75% adherence
- `vacation_week` - 40-60% adherence (different patterns)
- `illness_week` - 20-40% adherence (recovery focus)

**Output:**
- `patient_data_entries` - Daily behaviors (steps, meals, workouts, sleep)
- `aggregation_results_cache` - Auto-calculated metrics

## Usage:

```python
# Create patient
patient_id = create_patient(archetype="high_performer")

# Generate month of adherence data
generate_adherence_month(
    patient_id=patient_id,
    weeks=[
        ("optimal_week", 0.9),      # Week 1: 90% adherence
        ("moderate_week", 0.7),     # Week 2: 70% adherence
        ("vacation_week", 0.5),     # Week 3: 50% adherence
        ("optimal_week", 0.85)      # Week 4: 85% adherence
    ]
)
```

Generates realistic data that tests the agent's intelligence!
