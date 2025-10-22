# Therapeutic Tracking Architecture

## Overview
Consolidated approach for tracking medications, supplements, and peptides using event-based pattern with flexible unit handling.

---

## Problem Solved
- Previously: 75+ individual data_entry_fields for each therapeutic
- Now: 3 reusable fields in an event pattern
- Benefit: Cleaner schema, easier maintenance, better aggregations

---

## Data Model

### Core Tables

#### therapeutics_base (Existing)
```sql
- id (uuid)
- therapeutic_name (text)
- therapeutic_type (text) -- 'MED' | 'PEP' | 'SUP'
- category (text)
- overview (text)
- recommendation_text (text)
- min_dosage (numeric)
- max_dosage (numeric)
- unit_id (uuid) → units_base -- Default display unit
- frequency (text)
- age_min (integer)
- therapeutic_timing (text) -- 'Morning' | 'With Meals' | 'Any' | etc.
```

#### units_base (Existing)
```sql
- id (uuid)
- unit_name (text) -- 'mg', 'mcg', 'IU', 'ml', etc.
- unit_abbreviation (text)
- unit_category (text) -- 'mass' | 'volume' | 'international_units'
```

#### therapeutic_unit_options (New)
```sql
- id (uuid)
- therapeutic_id (uuid) → therapeutics_base
- unit_id (uuid) → units_base
- conversion_to_base_factor (numeric) -- For IU conversions (substance-specific)
- is_default (boolean)
- is_available (boolean)
```

#### unit_conversions (New)
```sql
- id (uuid)
- from_unit_id (uuid) → units_base
- to_unit_id (uuid) → units_base
- conversion_factor (numeric)
- conversion_type (text) -- 'multiply' | 'divide'
```

---

## Event Pattern Implementation

### Data Entry Fields (Simplified from 75+ to 3)
```sql
data_entry_fields:
- therapeutic_taken (FK reference to therapeutics_base)
- therapeutic_dosage (numeric input)
- therapeutic_unit (FK reference to units_base)
```

### Event Type
```sql
event_types:
- event_type: "therapeutic_intake"
- contains fields: [therapeutic_taken, therapeutic_dosage, therapeutic_unit]
```

---

## Storage Strategy

### Store As Entered (Recommended)
**User enters:** Vitamin D, 5000 IU  
**Store:** `dosage: 5000, unit_id: 'IU'`  
**No conversion on storage**

### Benefits:
- User sees exactly what they entered
- No double conversion overhead
- Preserves historical accuracy
- Simpler implementation

---

## Conversion Strategy

### When to Convert:
1. **During aggregations** - Sum daily totals in common unit
2. **For validation** - Check against min/max dosage
3. **For comparisons** - Compare across different units

### How to Convert:

#### For generic units (mg ↔ g):
```sql
SELECT dosage * uc.conversion_factor as normalized_dosage
FROM patient_therapeutic_events pte
JOIN unit_conversions uc ON 
  uc.from_unit_id = pte.unit_id 
  AND uc.to_unit_id = target_unit_id
```

#### For substance-specific units (IU):
```sql
SELECT dosage * tuo.conversion_to_base_factor as normalized_dosage  
FROM patient_therapeutic_events pte
JOIN therapeutic_unit_options tuo ON
  tuo.therapeutic_id = pte.therapeutic_id
  AND tuo.unit_id = pte.unit_id
```

---

## Instance Calculations

### Examples:
```sql
instance_calculations:
- therapeutic_adherence_score -- Did they take as prescribed?
- therapeutic_timing_accuracy -- Taken at recommended time?
- therapeutic_dosage_variance -- How far from recommended dose?
- therapeutic_daily_total -- Total for specific therapeutic
```

### Dependencies:
```sql
instance_calculations_dependencies:
- instance_calculation_id → therapeutic_daily_total
- data_entry_field_id → therapeutic_dosage
- data_entry_field_id → therapeutic_taken
```

---

## Aggregation Patterns

### Pattern 3: Counter (Frequency)
```sql
aggregation_metric: "therapeutic_intake_count"
dependency_type: "event_type"
dependency_id: <therapeutic_intake_event_id>

Calculations:
- Daily count: How many therapeutics taken today?
- Weekly average: Average therapeutics per day
- Adherence rate: % of prescribed therapeutics taken
```

### Pattern 2: Event (Dosage Totals)
```sql
aggregation_metric: "vitamin_d_daily_total"
dependency_type: "instance_calculation"
dependency_id: <vitamin_d_total_calc_id>

Calculations:
- Daily sum: Total Vitamin D in mcg
- Weekly average: Average daily Vitamin D
- vs Recommended: % of recommended dose
```

---

## Query Examples

### Get all therapeutics taken today:
```sql
SELECT 
  t.therapeutic_name,
  pte.dosage,
  u.unit_abbreviation,
  pte.taken_at
FROM patient_therapeutic_events pte
JOIN therapeutics_base t ON t.id = pte.therapeutic_id
JOIN units_base u ON u.id = pte.unit_id
WHERE DATE(pte.taken_at) = CURRENT_DATE
  AND pte.user_id = ?
ORDER BY pte.taken_at DESC;
```

### Calculate daily Vitamin D total (with conversions):
```sql
WITH normalized_doses AS (
  SELECT 
    pte.dosage * COALESCE(tuo.conversion_to_base_factor, 1) as mcg_amount
  FROM patient_therapeutic_events pte
  LEFT JOIN therapeutic_unit_options tuo ON
    tuo.therapeutic_id = pte.therapeutic_id
    AND tuo.unit_id = pte.unit_id
  WHERE pte.therapeutic_id = 'vitamin_d_id'
    AND DATE(pte.taken_at) = CURRENT_DATE
    AND pte.user_id = ?
)
SELECT 
  SUM(mcg_amount) as total_mcg,
  SUM(mcg_amount) * 40 as total_iu  -- Convert to IU for display
FROM normalized_doses;
```

### Check adherence for medications:
```sql
WITH prescribed AS (
  SELECT COUNT(*) as prescribed_count
  FROM user_prescriptions
  WHERE user_id = ? 
    AND is_active = true
),
taken AS (
  SELECT COUNT(DISTINCT therapeutic_id) as taken_count
  FROM patient_therapeutic_events
  WHERE user_id = ?
    AND DATE(taken_at) = CURRENT_DATE
    AND therapeutic_type = 'MED'
)
SELECT 
  taken.taken_count,
  prescribed.prescribed_count,
  (taken.taken_count::float / prescribed.prescribed_count) * 100 as adherence_percentage
FROM prescribed, taken;
```

---

## Migration Steps

1. **Create new tables**: therapeutic_unit_options, unit_conversions
2. **Add event type**: "therapeutic_intake" 
3. **Add 3 data_entry_fields**: therapeutic_taken, therapeutic_dosage, therapeutic_unit
4. **Migrate existing data**: Convert 75+ field responses to new event format
5. **Update aggregations**: Point to new event-based structure
6. **Remove old fields**: Delete individual therapeutic fields

---

## Benefits

✅ **Reduced from 75+ fields to 3**  
✅ **Flexible unit handling without double conversion**  
✅ **Substance-specific conversions (IU) supported**  
✅ **Clean aggregation patterns**  
✅ **Historical data preserved in original units**  
✅ **Easier to add new therapeutics**  
✅ **Better adherence tracking**  

---

## Open Questions

1. **User prescriptions table** - How to link prescribed vs taken?
2. **Drug interactions** - Check when multiple therapeutics taken?
3. **Refill tracking** - Monitor when running low?
4. **Time-of-day validation** - Enforce therapeutic_timing rules?

---

*Last Updated: 2025-10-19*
