# HealthKit Sync Implementation Complete

## What Was Done

### 1. Database: Populated HealthKit Identifiers
**File**: `supabase/migrations/20251029_populate_healthkit_identifiers.sql`

Populated `healthkit_identifier` column for 33 data entry fields:

**Sleep**:
- `DEF_SLEEP_PERIOD_START/END/TYPE` → `HKCategoryTypeIdentifierSleepAnalysis`

**Nutrition**:
- `DEF_PROTEIN_GRAMS` → `HKQuantityTypeIdentifierDietaryProtein`
- `DEF_FIBER_GRAMS` → `HKQuantityTypeIdentifierDietaryFiber`
- `DEF_WATER_QUANTITY` → `HKQuantityTypeIdentifierDietaryWater`
- `DEF_CALORIES_CONSUMED` → `HKQuantityTypeIdentifierDietaryEnergyConsumed`
- `DEF_CAFFEINE_QUANTITY` → `HKQuantityTypeIdentifierDietaryCaffeine`
- `DEF_ADDED_SUGAR_QUANTITY` → `HKQuantityTypeIdentifierDietarySugar`

**Activity**:
- `DEF_STEPS` → `HKQuantityTypeIdentifierStepCount`
- `DEF_CARDIO_CALORIES` → `HKQuantityTypeIdentifierActiveEnergyBurned`
- `DEF_CARDIO_DISTANCE` → `HKQuantityTypeIdentifierDistanceWalkingRunning`

**Body Measurements**:
- `DEF_WEIGHT` → `HKQuantityTypeIdentifierBodyMass`
- `DEF_HEIGHT` → `HKQuantityTypeIdentifierHeight`
- `DEF_BODY_FAT_PCT` → `HKQuantityTypeIdentifierBodyFatPercentage`
- `DEF_BMI` → `HKQuantityTypeIdentifierBodyMassIndex`
- `DEF_WAIST_CIRCUMFERENCE` → `HKQuantityTypeIdentifierWaistCircumference`

**Vitals**:
- `DEF_BLOOD_PRESSURE_SYS` → `HKQuantityTypeIdentifierBloodPressureSystolic`
- `DEF_BLOOD_PRESSURE_DIA` → `HKQuantityTypeIdentifierBloodPressureDiastolic`
- `DEF_RESTING_HEART_RATE` → `HKQuantityTypeIdentifierRestingHeartRate`
- `DEF_VO2_MAX` → `HKQuantityTypeIdentifierVO2Max`

**Mindfulness**:
- `DEF_MINDFULNESS_*` → `HKCategoryTypeIdentifierMindfulSession`

### 2. iOS: Created HealthKitFieldMapper Service
**File**: `WellPath-V2-Mobile-Swift/WellPath/Services/HealthKitFieldMapper.swift`

**Features**:
- Queries backend for HealthKit identifier → field_id mappings
- Caches mappings locally for performance
- Single source of truth (database)
- No hardcoded field_ids required

**Usage**:
```swift
let mapper = HealthKitFieldMapper.shared
let fieldId = try await mapper.getFieldId(for: "HKQuantityTypeIdentifierDietaryProtein")
// Returns: "DEF_PROTEIN_GRAMS"
```

### 3. iOS: Created HealthKitSyncService
**File**: `WellPath-V2-Mobile-Swift/WellPath/Services/HealthKitSyncService.swift`

**Features**:
- Automatic sync of HealthKit data to backend
- Supports: Protein, Steps, Water, Weight, Sleep
- Prevents duplicate syncs using `healthkit_uuid` unique constraint
- Tracks last sync date to only sync new data
- Writes with `source = 'healthkit'` and `healthkit_source_name`

**How It Works**:
1. Queries HealthKit for samples since last sync
2. Gets field_id from HealthKitFieldMapper
3. Checks if sample already synced (by healthkit_uuid)
4. Writes to patient_data_entries via Supabase
5. Backend triggers fire automatically:
   - `auto_run_instance_calculations_http` → runs instance calculations
   - `auto_process_aggregations_on_insert` → processes aggregations

### 4. iOS: Updated App to Trigger Sync
**File**: `WellPath-V2-Mobile-Swift/WellPath/WellPathApp.swift`

**Change**: App now triggers `HealthKitSyncService.performFullSync()` on launch

**Flow**:
1. App launches
2. Checks if HealthKit authorized
3. If authorized, runs full sync
4. Syncs last 7 days of data (or since last sync)

### 5. iOS: Updated Manual Entry to Use Mapper
**File**: `WellPath-V2-Mobile-Swift/WellPath/Views/Nutrition/ProteinEntryView.swift`

**Change**: Replaced hardcoded `"DEF_PROTEIN_GRAMS"` with:
```swift
let proteinGramsFieldId = try await mapper.getFieldId(for: "HKQuantityTypeIdentifierDietaryProtein")
```

## Architecture

### Data Flow: HealthKit → Backend

```
1. User enters protein in Apple Health
   ↓
2. iOS app launches (or user manually triggers sync)
   ↓
3. HealthKitSyncService queries HealthKit
   ↓
4. HealthKitFieldMapper gets field_id from backend
   ↓
5. HealthKitSyncService writes to patient_data_entries
   - source: "healthkit"
   - healthkit_uuid: unique sample ID
   - healthkit_source_name: "iPhone" or "Apple Watch"
   ↓
6. Database triggers fire:
   - Instance calculations run
   - Aggregations process
   - Display metrics update
   - Scores recalculate
```

### Sleep Data Flow (Special Case)

Sleep uses generic fields + reference table:

```
HealthKit Sleep Sample
- HKCategoryValueSleepAnalysisAsleepCore
- Start: 11:00 PM
- End: 1:00 AM
   ↓
Query def_ref_sleep_period_types:
- WHERE healthkit_identifier = 'HKCategoryValueSleepAnalysisAsleepCore'
- Returns: UUID for "Core Sleep"
   ↓
Write 3 entries with same event_instance_id:
1. DEF_SLEEP_PERIOD_START (value_timestamp = 11:00 PM)
2. DEF_SLEEP_PERIOD_END (value_timestamp = 1:00 AM)
3. DEF_SLEEP_PERIOD_TYPE (value_reference = Core Sleep UUID)
   ↓
Instance calculation auto-runs:
4. DEF_SLEEP_PERIOD_DURATION (value_quantity = 120 minutes) ✅
```

### Sleep Duration Calculation Logic

Sleep duration is calculated at the **aggregation level** using this formula:

```
Sleep Duration = Time in Bed - Time Awake

Where:
- Time in Bed = duration of "in_bed" sleep period
- Time Awake = SUM of all "awake" period durations
```

**Example Night:**
```
11:00 PM - 7:00 AM (8 hours in bed)
├─ In Bed: 480 minutes
├─ Awake periods: 20 + 15 + 10 = 45 minutes
├─ Core sleep: 180 minutes
├─ Deep sleep: 90 minutes
└─ REM sleep: 165 minutes

Daily Aggregations:
✅ Time in Bed = 480 min
✅ Time Awake = 45 min
✅ Sleep Duration = 480 - 45 = 435 min
✅ Sleep Efficiency = 435/480 = 90.6%
```

**Why this approach?**
- Cleaner than summing all asleep stages
- More resilient (works even if some stages are unspecified)
- Matches Apple Health calculation method
- Single source of truth (in_bed period)

## How to Test

### 1. In Apple Health:
```
1. Open Health app
2. Browse → Nutrition → Protein
3. Add Data → 45g protein at current time
4. Save
```

### 2. In WellPath App:
```
1. Launch app
2. Check logs for: "🚀 Starting initial HealthKit sync..."
3. Should see: "✅ Synced X protein entries"
```

### 3. In Database:
```sql
SELECT
    field_id,
    value_quantity,
    source,
    healthkit_source_name,
    entry_timestamp
FROM patient_data_entries
WHERE source = 'healthkit'
ORDER BY created_at DESC;
```

Should see your protein entry with:
- field_id = `DEF_PROTEIN_GRAMS`
- value_quantity = `45.0`
- source = `healthkit`
- healthkit_source_name = `iPhone` or `Health`

## Sync Frequency

**Current**: On app launch

**Future Options**:
1. **Background Refresh**: iOS can wake app periodically
2. **Manual Sync Button**: Let users trigger sync
3. **Observer Queries**: HealthKit can notify app of new data
4. **Scheduled**: Daily at specific time

## Benefits of This Approach

1. **Single Source of Truth**: Database controls all mappings
2. **No App Updates Required**: Add new HealthKit mappings without releasing new iOS version
3. **Deduplication**: `healthkit_uuid` UNIQUE constraint prevents duplicate syncs
4. **Auditable**: `source` and `healthkit_source_name` track data provenance
5. **Extensible**: Easy to add new HealthKit data types

## Adding New HealthKit Data Types

To add a new HealthKit data type:

1. **Database**: Add mapping
```sql
UPDATE data_entry_fields
SET healthkit_identifier = 'HKQuantityTypeIdentifierHeartRate'
WHERE field_id = 'DEF_HEART_RATE';
```

2. **iOS**: Add sync method to HealthKitSyncService
```swift
private func syncHeartRate() async throws {
    let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    let fieldId = try await mapper.getFieldId(for: "HKQuantityTypeIdentifierHeartRate")
    let samples = try await fetchQuantitySamples(type: heartRateType, since: lastSyncDate ?? ...)
    try await writeSamplesToBackend(samples: samples, fieldId: fieldId, unit: .count().unitDivided(by: .minute()))
}
```

3. **iOS**: Call in `performFullSync()`
```swift
try await syncHeartRate()
```

That's it! No hardcoded field_ids anywhere.

## Files Modified/Created

### Backend:
- ✅ `supabase/migrations/20251029_populate_healthkit_identifiers.sql` (NEW)

### iOS:
- ✅ `WellPath/Services/HealthKitFieldMapper.swift` (NEW)
- ✅ `WellPath/Services/HealthKitSyncService.swift` (NEW)
- ✅ `WellPath/WellPathApp.swift` (MODIFIED)
- ✅ `WellPath/Views/Nutrition/ProteinEntryView.swift` (MODIFIED)

## Next Steps

1. Test sync with real device (simulator doesn't have real HealthKit data)
2. Add sync UI (show sync status, last sync time, manual sync button)
3. Implement background refresh for automatic syncing
4. Add remaining HealthKit data types (heart rate, exercise, etc.)
5. Add conflict resolution (what if user edits HealthKit data after sync?)
