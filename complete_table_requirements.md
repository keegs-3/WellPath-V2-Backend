# Complete Table Requirements for Data Consolidation

## Core Reference Tables Needed (Count: ~20)

### 1. FOOD/NUTRITION TABLES (5 tables)
```sql
-- Table 1: food_categories
CREATE TABLE food_categories (
    id UUID PRIMARY KEY,
    category_name TEXT, -- Fruit, Vegetable, Protein, Grain, Legume, Fat, Dairy
    category_type TEXT, -- produce, protein, grain, etc.
    recommended_daily_servings NUMERIC,
    default_serving_unit_id UUID
);

-- Table 2: food_items  
CREATE TABLE food_items (
    id UUID PRIMARY KEY,
    item_name TEXT, -- Apple, Banana, Chicken Breast, Olive Oil, etc.
    category_id UUID REFERENCES food_categories,
    subcategory TEXT, -- berries, citrus, leafy_greens, etc.
    typical_serving_size NUMERIC,
    typical_serving_unit_id UUID,
    calories_per_serving NUMERIC,
    protein_grams NUMERIC,
    carb_grams NUMERIC,
    fat_grams NUMERIC,
    fiber_grams NUMERIC,
    nutrients_json JSONB
);

-- Table 3: food_unit_options
CREATE TABLE food_unit_options (
    id UUID PRIMARY KEY,
    food_item_id UUID REFERENCES food_items,
    unit_id UUID REFERENCES units_base,
    conversion_to_base_factor NUMERIC,
    is_default BOOLEAN
);

-- Table 4: meal_types
CREATE TABLE meal_types (
    id UUID PRIMARY KEY,
    meal_name TEXT, -- Breakfast, Lunch, Dinner, Snack, Beverage
    typical_time_range TEXT,
    sort_order INTEGER
);

-- Table 5: food_preparation_methods
CREATE TABLE food_preparation_methods (
    id UUID PRIMARY KEY,
    method_name TEXT, -- Raw, Steamed, Grilled, Fried, Baked
    health_impact_score NUMERIC
);
```

### 2. EXERCISE/WORKOUT TABLES (4 tables)
```sql
-- Table 6: exercise_categories
CREATE TABLE exercise_categories (
    id UUID PRIMARY KEY,
    category_name TEXT, -- Strength, Cardio, Flexibility, Balance
    description TEXT
);

-- Table 7: exercise_types
CREATE TABLE exercise_types (
    id UUID PRIMARY KEY,
    exercise_name TEXT, -- Squats, Running, Yoga, HIIT, Zone 2 Cardio
    category_id UUID REFERENCES exercise_categories,
    met_score NUMERIC,
    typical_duration_minutes INTEGER,
    equipment_needed TEXT[],
    muscle_groups TEXT[]
);

-- Table 8: exercise_unit_options
CREATE TABLE exercise_unit_options (
    id UUID PRIMARY KEY,
    exercise_type_id UUID REFERENCES exercise_types,
    unit_id UUID REFERENCES units_base, -- reps, sets, minutes, miles, etc.
    is_default BOOLEAN
);

-- Table 9: exercise_intensity_levels
CREATE TABLE exercise_intensity_levels (
    id UUID PRIMARY KEY,
    level_name TEXT, -- Light, Moderate, Vigorous, Max
    rpe_range TEXT, -- 1-3, 4-6, 7-9, 10
    heart_rate_zone INTEGER
);
```

### 3. SLEEP TABLES (2 tables)
```sql
-- Table 10: sleep_period_types
CREATE TABLE sleep_period_types (
    id UUID PRIMARY KEY,
    period_type TEXT, -- REM, Deep, Core/Light, Awake, In Bed
    description TEXT,
    is_restorative BOOLEAN
);

-- Table 11: sleep_quality_factors
CREATE TABLE sleep_quality_factors (
    id UUID PRIMARY KEY,
    factor_name TEXT, -- Temperature, Noise, Light, Stress, Alcohol
    impact_direction TEXT -- positive, negative, neutral
);
```

### 4. MEASUREMENT TABLES (2 tables)
```sql
-- Table 12: measurement_types
CREATE TABLE measurement_types (
    id UUID PRIMARY KEY,
    measurement_name TEXT, -- Weight, HRV, VO2 Max, Body Fat, Blood Pressure
    measurement_category TEXT, -- body_composition, cardiovascular, metabolic
    default_unit_id UUID REFERENCES units_base,
    healthy_range_min NUMERIC,
    healthy_range_max NUMERIC,
    frequency_recommendation TEXT
);

-- Table 13: measurement_unit_options
CREATE TABLE measurement_unit_options (
    id UUID PRIMARY KEY,
    measurement_type_id UUID REFERENCES measurement_types,
    unit_id UUID REFERENCES units_base,
    conversion_to_base_factor NUMERIC,
    is_default BOOLEAN
);
```

### 5. HEALTH SCREENING TABLES (1 table)
```sql
-- Table 14: screening_types
CREATE TABLE screening_types (
    id UUID PRIMARY KEY,
    screening_name TEXT, -- Colonoscopy, Mammogram, PSA, Dental, Vision
    screening_category TEXT, -- cancer, preventive, diagnostic
    recommended_frequency_months INTEGER,
    age_start INTEGER,
    age_end INTEGER,
    gender_specific TEXT, -- male, female, both
    risk_factors TEXT[],
    cpt_codes TEXT[]
);
```

### 6. WELLNESS/MINDFULNESS TABLES (2 tables)
```sql
-- Table 15: wellness_activity_types
CREATE TABLE wellness_activity_types (
    id UUID PRIMARY KEY,
    activity_name TEXT, -- Meditation, Breathwork, Journaling, Gratitude
    activity_category TEXT, -- mindfulness, stress_management, emotional
    typical_duration_minutes INTEGER,
    benefits TEXT[]
);

-- Table 16: wellness_techniques
CREATE TABLE wellness_techniques (
    id UUID PRIMARY KEY,
    technique_name TEXT, -- Box Breathing, Body Scan, Loving Kindness
    activity_type_id UUID REFERENCES wellness_activity_types,
    difficulty_level TEXT,
    instructions TEXT
);
```

### 7. SUBSTANCE USE TABLES (2 tables)
```sql
-- Table 17: substance_types
CREATE TABLE substance_types (
    id UUID PRIMARY KEY,
    substance_name TEXT, -- Cigarette, Alcohol, Caffeine, Cannabis
    substance_category TEXT, -- stimulant, depressant, etc.
    default_unit_id UUID REFERENCES units_base,
    daily_limit_recommendation NUMERIC
);

-- Table 18: substance_sources
CREATE TABLE substance_sources (
    id UUID PRIMARY KEY,
    source_name TEXT, -- Coffee, Tea, Beer, Wine, Spirits
    substance_type_id UUID REFERENCES substance_types,
    typical_serving_size NUMERIC,
    typical_unit_id UUID REFERENCES units_base,
    substance_content_per_serving NUMERIC -- mg caffeine, grams alcohol, etc.
);
```

### 8. SELF-CARE TABLES (1 table)
```sql
-- Table 19: selfcare_activity_types
CREATE TABLE selfcare_activity_types (
    id UUID PRIMARY KEY,
    activity_name TEXT, -- Brushing, Flossing, Skincare, Sunscreen
    activity_category TEXT, -- oral_hygiene, skin_care, grooming
    recommended_frequency_per_day INTEGER,
    typical_duration_minutes INTEGER
);
```

### 9. SOCIAL CONNECTION TABLES (1 table)
```sql
-- Table 20: social_activity_types
CREATE TABLE social_activity_types (
    id UUID PRIMARY KEY,
    activity_name TEXT, -- In-person meeting, Phone call, Video chat, Group activity
    connection_quality_score INTEGER,
    typical_duration_minutes INTEGER
);
```

---

## Summary: Total Tables Needed

### Food/Nutrition: 5 tables
- food_categories
- food_items
- food_unit_options
- meal_types
- food_preparation_methods

### Exercise: 4 tables
- exercise_categories
- exercise_types
- exercise_unit_options
- exercise_intensity_levels

### Sleep: 2 tables
- sleep_period_types
- sleep_quality_factors

### Measurements: 2 tables
- measurement_types
- measurement_unit_options

### Health Screenings: 1 table
- screening_types

### Wellness: 2 tables
- wellness_activity_types
- wellness_techniques

### Substances: 2 tables
- substance_types
- substance_sources

### Self-care: 1 table
- selfcare_activity_types

### Social: 1 table
- social_activity_types

## **TOTAL: 20 NEW TABLES**

Plus you already have:
- therapeutics_base ✅
- therapeutic_unit_options ✅
- units_base ✅
- unit_conversions ✅

---

## Consolidated Data Entry Fields (15 patterns)

After creating these tables, you'll only need about 15 data entry field patterns:

1. **food_intake** (category, item, quantity, unit, meal_type)
2. **exercise_session** (type, start, end, intensity)
3. **sleep_period** (type, start, end, quality)
4. **body_measurement** (type, value, unit)
5. **health_screening** (type, date, status)
6. **wellness_activity** (type, start, end, quality)
7. **substance_use** (type, source, quantity, unit)
8. **selfcare_activity** (type, completed, time)
9. **social_connection** (type, duration, quality)
10. **therapeutic_intake** (id, dosage, unit) ✅
11. **water_intake** (quantity, unit)
12. **step_count** (quantity)
13. **calorie_tracking** (quantity, context)
14. **macro_nutrients** (protein, carbs, fats)
15. **simple_metrics** (metric_type, value, unit)

---

## Why This Many Tables?

Each domain needs its own reference data because:
- **Foods** have calories and nutrients
- **Exercises** have MET scores and muscle groups
- **Measurements** have healthy ranges
- **Screenings** have age/gender requirements
- **Substances** have daily limits

You can't combine these into fewer tables without losing important domain-specific attributes.

This is still MUCH better than 139 individual fields!
