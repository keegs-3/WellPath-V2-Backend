# HealthKit Patient Events Implementation - COMPLETE ✅

## Summary
Successfully implemented **4 patient event tables** following Apple's HealthKit data model architecture, with hybrid sync pattern (text + FK) for resilient bi-directional synchronization.

---

## Patient Event Tables Created

### 1. patient_quantity_events (HKQuantitySample)
**Purpose**: Stores numeric measurements with units
**Examples**: Steps, calories, heart rate, weight, blood pressure, nutrition

**Schema**:
```sql
CREATE TABLE patient_quantity_events (
  -- HKObject properties
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  healthkit_identifier TEXT,  -- Raw identifier
  healthkit_mapping_id UUID REFERENCES healthkit_mapping,
  healthkit_uuid UUID,  -- Original HK UUID for deduplication

  -- HKSample temporal
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,

  -- HKQuantitySample value
  quantity NUMERIC,
  unit TEXT,

  -- Metadata, source, device info
  metadata JSONB,
  source_name TEXT,
  device_name TEXT,
  -- ... (full schema in migration)
);
```

**Indexes** (8 total):
- User + time (DESC)
- HealthKit identifier
- HealthKit mapping FK
- HealthKit UUID (for deduplication)
- Sync source + time
- User-entered data (partial index)
- Unique constraint on (user_id, healthkit_uuid)

**Use Cases**:
- Import step count from HealthKit
- Sync nutrition data (calories, macros, vitamins)
- Track vital signs (heart rate, blood pressure, temperature)
- Monitor body measurements (weight, body fat, lean mass)
- Aggregate activity metrics (distance, energy burned)

---

### 2. patient_category_events (HKCategorySample)
**Purpose**: Stores categorical data from predefined enum values
**Examples**: Sleep stages, mindfulness sessions, toothbrushing

**Schema**:
```sql
CREATE TABLE patient_category_events (
  -- HKObject + HKSample properties
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping,
  healthkit_uuid UUID,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,

  -- HKCategorySample value
  category_value INTEGER,  -- HK enum value
  category_value_text TEXT,  -- Human-readable

  -- Metadata, source, device
  -- ... (full schema in migration)
);
```

**Indexes** (6 total):
- User + time
- HealthKit identifier
- HealthKit mapping FK
- HealthKit UUID
- Unique constraint on (user_id, healthkit_uuid)

**Use Cases**:
- Import sleep analysis (in bed, awake, core, deep, REM)
- Track mindfulness sessions
- Monitor self-care activities (toothbrushing, handwashing)
- Record health events (audio exposure, heart rate irregularities)

---

### 3. patient_workout_events (HKWorkout)
**Purpose**: Stores physical activity sessions with rich metadata
**Examples**: Running, cycling, swimming, strength training, yoga

**Schema**:
```sql
CREATE TABLE patient_workout_events (
  -- HKObject + HKSample properties
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  healthkit_identifier TEXT,  -- HKWorkoutActivityType
  healthkit_mapping_id UUID REFERENCES healthkit_mapping,
  healthkit_uuid UUID,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,
  duration_minutes NUMERIC GENERATED ALWAYS AS (...) STORED,

  -- HKWorkout specific
  workout_activity_type TEXT,
  total_distance NUMERIC,
  total_distance_unit TEXT,
  total_energy_burned NUMERIC,
  total_energy_burned_unit TEXT,

  -- Additional metrics
  average_heart_rate NUMERIC,
  max_heart_rate NUMERIC,
  elevation_gain NUMERIC,
  is_indoor BOOLEAN,

  -- Weather conditions
  weather_temperature NUMERIC,
  weather_humidity NUMERIC,

  -- Route data
  has_route BOOLEAN,
  route_data JSONB,

  -- Metadata, source, device
  -- ... (full schema in migration)

  CONSTRAINT workout_end_after_start CHECK (end_time > start_time)
);
```

**Indexes** (7 total):
- User + time
- HealthKit identifier
- HealthKit mapping FK
- Workout activity type
- HealthKit UUID
- Unique constraint on (user_id, healthkit_uuid)

**Use Cases**:
- Import workouts from Apple Watch
- Track exercise duration, distance, calories
- Monitor heart rate during workouts
- Store GPS routes
- Analyze workout patterns by activity type
- Calculate weekly exercise minutes

---

### 4. patient_correlation_events (HKCorrelation)
**Purpose**: Stores composite measurements combining multiple samples
**Examples**: Blood pressure (systolic + diastolic), Food (nutrition facts)

**Schema**:
```sql
CREATE TABLE patient_correlation_events (
  -- HKObject + HKSample properties
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users,
  healthkit_identifier TEXT,
  healthkit_mapping_id UUID REFERENCES healthkit_mapping,
  healthkit_uuid UUID,
  start_time TIMESTAMPTZ,
  end_time TIMESTAMPTZ,

  -- HKCorrelation type
  correlation_type TEXT,  -- 'blood_pressure', 'food'

  -- Components as JSONB for flexibility
  components JSONB,

  -- Metadata, source, device
  -- ... (full schema in migration)
);
```

**Indexes** (8 total):
- User + time
- HealthKit identifier
- HealthKit mapping FK
- Correlation type
- HealthKit UUID
- GIN index on components JSONB
- Unique constraint on (user_id, healthkit_uuid)

**Use Cases**:
- Import blood pressure readings (systolic + diastolic)
- Track food intake with complete nutrition facts
- Query complex correlations efficiently
- Maintain relationships between component samples

**Example Components**:
```json
// Blood Pressure
{
  "systolic": 120,
  "diastolic": 80,
  "unit": "mmHg"
}

// Food
{
  "name": "Grilled Chicken Salad",
  "calories": 350,
  "protein": 35,
  "carbs": 20,
  "fat": 12,
  "fiber": 5
}
```

---

## Architecture Features

### Hybrid HealthKit Pattern
**Best of both worlds approach**:

1. **healthkit_identifier** (TEXT)
   - Raw identifier from Apple (e.g., `HKQuantityTypeIdentifierStepCount`)
   - **Benefits**: Resilient to missing mappings, audit trail, debugging
   - Allows import even if mapping doesn't exist yet

2. **healthkit_mapping_id** (UUID FK)
   - Foreign key to `healthkit_mapping` table
   - **Benefits**: Structured queries, JOIN performance, categorization
   - Can be NULL if mapping not found

3. **healthkit_uuid** (UUID)
   - Original UUID from HealthKit
   - **Benefits**: Deduplication, prevents duplicate imports
   - Unique constraint per user prevents re-imports

**Why this works**:
- ✅ Resilient: Can import HealthKit data even without perfect mapping
- ✅ Fast queries: FK enables efficient JOINs and filtering
- ✅ Audit trail: Raw identifier preserved for debugging
- ✅ Deduplication: Prevents duplicate imports from HealthKit
- ✅ Flexible: Can add new HealthKit types without schema changes

### HKObject Properties (All Tables)
Following Apple's HealthKit architecture, all tables include:

**UUID**: Unique identifier (PostgreSQL `gen_random_uuid()`)
**Metadata**: JSONB field for extensibility
**Source Revision**: App name, version, bundle ID
**Device**: Hardware info (name, manufacturer, model, software)

### HKSample Properties (All Tables)
**start_time**: When measurement/event started
**end_time**: When measurement/event ended
- Point-in-time: start_time = end_time
- Time interval: end_time > start_time

### Sync Metadata (All Tables)
**was_user_entered**: Manual entry vs. auto-sync
**sync_source**: 'healthkit', 'manual', 'integration'
**sync_identifier**: External system reference
**last_synced_at**: Last sync timestamp

### Security (All Tables)
**Row Level Security (RLS)**: Enabled
**Policies**: Users can only access their own data
- SELECT, INSERT, UPDATE, DELETE policies per table
- Uses `auth.uid() = user_id` for isolation

### Performance (All Tables)
**Indexes**:
- User + time (DESC) for timeline queries
- HealthKit identifiers for lookups
- Foreign keys for JOINs
- Unique constraints for deduplication
- GIN indexes for JSONB queries

**Triggers**:
- `update_updated_at_column()` on all tables
- Automatically maintains `updated_at` timestamp

---

## Query Patterns

### 1. Import from HealthKit
```sql
-- Insert quantity event with hybrid pattern
INSERT INTO patient_quantity_events (
  user_id,
  healthkit_identifier,
  healthkit_mapping_id,
  healthkit_uuid,
  start_time,
  end_time,
  quantity,
  unit,
  source_name,
  device_name,
  sync_source
) VALUES (
  '123e4567-e89b-12d3-a456-426614174000',
  'HKQuantityTypeIdentifierStepCount',
  (SELECT id FROM healthkit_mapping WHERE healthkit_identifier = 'HKQuantityTypeIdentifierStepCount'),
  'a1b2c3d4-e5f6-7890-abcd-ef1234567890',  -- Original HK UUID
  '2025-10-20 10:00:00',
  '2025-10-20 10:00:00',
  8947,
  'count',
  'Apple Health',
  'iPhone 15 Pro',
  'healthkit'
)
ON CONFLICT (user_id, healthkit_uuid) DO NOTHING;  -- Prevent duplicates
```

### 2. Query by HealthKit Type (using FK)
```sql
-- Get all steps for user (fast with FK)
SELECT
  start_time,
  quantity,
  unit,
  source_name
FROM patient_quantity_events
WHERE user_id = '123e4567-e89b-12d3-a456-426614174000'
AND healthkit_mapping_id = (
  SELECT id FROM healthkit_mapping
  WHERE healthkit_identifier = 'HKQuantityTypeIdentifierStepCount'
)
ORDER BY start_time DESC;
```

### 3. Aggregate Quantity Data (for aggregation_metrics)
```sql
-- Calculate total steps for last 7 days (cumulative type)
SELECT
  DATE(start_time) as date,
  SUM(quantity) as total_steps
FROM patient_quantity_events pqe
JOIN healthkit_mapping hm ON pqe.healthkit_mapping_id = hm.id
WHERE pqe.user_id = '123e4567-e89b-12d3-a456-426614174000'
AND hm.healthkit_identifier = 'HKQuantityTypeIdentifierStepCount'
AND pqe.start_time >= NOW() - INTERVAL '7 days'
GROUP BY DATE(start_time)
ORDER BY date;
```

### 4. Query Discrete Metrics (supports AVG, MIN, MAX)
```sql
-- Get average heart rate for last 30 days
SELECT
  AVG(quantity) as avg_heart_rate,
  MIN(quantity) as min_heart_rate,
  MAX(quantity) as max_heart_rate
FROM patient_quantity_events pqe
JOIN healthkit_mapping hm ON pqe.healthkit_mapping_id = hm.id
WHERE pqe.user_id = '123e4567-e89b-12d3-a456-426614174000'
AND hm.healthkit_identifier = 'HKQuantityTypeIdentifierHeartRate'
AND hm.aggregation_style = 'discrete_arithmetic'
AND pqe.start_time >= NOW() - INTERVAL '30 days';
```

### 5. Sleep Analysis Query
```sql
-- Get sleep stages for last night
SELECT
  hm.display_name as sleep_stage,
  pce.start_time,
  pce.end_time,
  EXTRACT(EPOCH FROM (pce.end_time - pce.start_time)) / 3600 as hours
FROM patient_category_events pce
JOIN healthkit_mapping hm ON pce.healthkit_mapping_id = hm.id
WHERE pce.user_id = '123e4567-e89b-12d3-a456-426614174000'
AND hm.category = 'sleep'
AND pce.start_time >= DATE_TRUNC('day', NOW() - INTERVAL '1 day')
AND pce.start_time < DATE_TRUNC('day', NOW())
ORDER BY pce.start_time;
```

### 6. Workout Summary Query
```sql
-- Get workout summary for last week
SELECT
  DATE(start_time) as workout_date,
  workout_activity_type,
  COUNT(*) as workout_count,
  SUM(duration_minutes) as total_minutes,
  SUM(total_distance) as total_distance,
  AVG(average_heart_rate) as avg_hr
FROM patient_workout_events
WHERE user_id = '123e4567-e89b-12d3-a456-426614174000'
AND start_time >= NOW() - INTERVAL '7 days'
GROUP BY DATE(start_time), workout_activity_type
ORDER BY workout_date DESC, workout_activity_type;
```

### 7. Correlation Query (Blood Pressure)
```sql
-- Get blood pressure readings
SELECT
  start_time,
  (components->>'systolic')::numeric as systolic,
  (components->>'diastolic')::numeric as diastolic,
  source_name
FROM patient_correlation_events
WHERE user_id = '123e4567-e89b-12d3-a456-426614174000'
AND correlation_type = 'blood_pressure'
ORDER BY start_time DESC
LIMIT 10;
```

---

## Integration with Aggregation Metrics

### Linking to aggregation_metrics
Patient event tables serve as source data for `aggregation_metrics`:

```sql
-- Example: Create aggregation_metric for total steps (7-day rolling)
INSERT INTO aggregation_metrics (
  agg_id,
  metric_name,
  display_name,
  calculation_type,
  period_type,
  period_length
) VALUES (
  'AGG_STEPS_7D',
  'Total Steps (7 Days)',
  'Weekly Steps',
  'sum',
  'rolling',
  7
);

-- Link to patient_quantity_events via healthkit_mapping
INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id,
  dependency_type,
  source_table,
  source_column
) VALUES (
  'AGG_STEPS_7D',
  'healthkit_quantity',
  'patient_quantity_events',
  'quantity'
);
```

### Aggregation Query Pattern
```sql
-- Calculate aggregation metric value
WITH source_data AS (
  SELECT
    pqe.user_id,
    pqe.start_time,
    pqe.quantity
  FROM patient_quantity_events pqe
  JOIN healthkit_mapping hm ON pqe.healthkit_mapping_id = hm.id
  WHERE hm.healthkit_identifier = 'HKQuantityTypeIdentifierStepCount'
  AND pqe.start_time >= NOW() - INTERVAL '7 days'
)
SELECT
  user_id,
  SUM(quantity) as total_steps,
  AVG(quantity) as avg_daily_steps
FROM source_data
GROUP BY user_id;
```

---

## Migration Files

1. **20251019_enhance_healthkit_mapping.sql** - Enhanced healthkit_mapping table (92 identifiers)
2. **20251020_add_remaining_healthkit_workouts.sql** - Added 63 workout types
3. **20251020_add_characteristic_correlation_document_types.sql** - Added 9 remaining types + aggregation metadata
4. **20251020_add_healthkit_to_data_source_options.sql** - Hybrid columns in data_source_options
5. **20251020_create_patient_healthkit_events.sql** - Created 4 patient event tables ✅

---

## Next Steps

### Phase 5: Create Edge Functions for HealthKit Sync
- Import HealthKit data from mobile app
- Process and deduplicate incoming data
- Link to appropriate healthkit_mapping records
- Calculate aggregation metrics on new data

### Phase 6: Build Aggregation Pipelines
- Create scheduled functions to compute aggregation_metrics
- Use aggregation_style metadata to determine valid operations
- Store results in `aggregation_metrics_periods` table
- Support cumulative (SUM), discrete (AVG/MIN/MAX), and time-weighted aggregations

### Phase 7: Mobile App Integration
- Build Swift/Kotlin HealthKit import service
- Implement batch sync with conflict resolution
- Handle incremental updates (anchored queries)
- Support background sync when app is closed

---

## Benefits Achieved

✅ **Complete HealthKit data model**: Mirrors Apple's HKObject/HKSample hierarchy
✅ **Hybrid sync pattern**: Resilient text identifiers + performant FK references
✅ **Deduplication**: Prevents duplicate imports via healthkit_uuid unique constraint
✅ **Security**: RLS policies ensure users only access their own data
✅ **Performance**: Comprehensive indexes for common query patterns
✅ **Extensibility**: JSONB metadata fields for future HealthKit features
✅ **Audit trail**: Complete source and device information preserved
✅ **Temporal queries**: Optimized for time-series data with start/end times
✅ **Aggregation ready**: Schema supports computing aggregation_metrics
✅ **Type safety**: FK to healthkit_mapping provides categorization and validation

---

*Implemented: 2025-10-20*
*Tables Created: 4*
*Total Indexes: 29*
*RLS Policies: 10*
