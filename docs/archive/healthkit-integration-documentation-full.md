# HealthKit Data Integration Reference

## Overview
WellPath integrates with Apple HealthKit to automatically sync health and fitness data. When HealthKit access is enabled, data from compatible apps and devices will flow into WellPath automatically. This document provides technical details about which HealthKit data types map to each WellPath metric.

---

## Nutrition Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Daily Fiber Intake (grams) | Fiber (g) | `HKQuantityTypeIdentifierDietaryFiber` | Grams (g) | MyFitnessPal, Lose It!, Cronometer, other nutrition tracking apps | - |
| Daily Protein Intake (grams) | Protein (g) | `HKQuantityTypeIdentifierDietaryProtein` | Grams (g) | MyFitnessPal, Lose It!, Cronometer, other nutrition tracking apps | - |
| Daily Caffeine Intake (milligrams) | Caffeine (mg) | `HKQuantityTypeIdentifierDietaryCaffeine` | Milligrams (mg) | MyFitnessPal, Starbucks app, other nutrition tracking apps | - |
| Daily Water Intake (mixed units) | Water (mL) | `HKQuantityTypeIdentifierDietaryWater` | Milliliters (ml) | WaterMinder, MyWater, Waterly, other hydration tracking apps | - |

---

## Exercise & Movement Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Zone 2 Cardio Duration (minutes) | Zone 2 Cardio Duration | `HKWorkoutActivityTypeWalking`, `HKWorkoutActivityTypeRunning`, `HKWorkoutActivityTypeCycling`, `HKWorkoutActivityTypeHandCycling`, `HKWorkoutActivityTypeElliptical`, `HKWorkoutActivityTypeMixedCardio`, `HKWorkoutActivityTypeStairClimbing`, `HKWorkoutActivityTypeJumpRope`, `HKWorkoutActivityTypeStairs`, `HKWorkoutActivityTypeStepTraining`, `HKWorkoutActivityTypeCardioDance`, `HKWorkoutActivityTypeSocialDance`, `HKWorkoutActivityTypeOther`, `HKWorkoutActivityTypeSwimBikeRun`, `HKWorkoutActivityTypeRowing`, `HKWorkoutActivityTypeSwimming`, `HKWorkoutActivityTypeWaterFitness` + `HKQuantityTypeIdentifierHeartRate` | Minutes per week (total) | Apple Fitness+, Strava, Nike Run Club, Peloton, Zwift, any app with HR tracking | Cardio workouts are automatically classified as Zone 2 when heart rate data shows 60-70% of max heart rate. Only duration in Zone 2 range counts toward total. |
| Zone 2 Cardio Sessions | Zone 2 Cardio Sessions | `HKWorkoutActivityTypeWalking`, `HKWorkoutActivityTypeRunning`, `HKWorkoutActivityTypeCycling`, `HKWorkoutActivityTypeHandCycling`, `HKWorkoutActivityTypeElliptical`, `HKWorkoutActivityTypeMixedCardio`, `HKWorkoutActivityTypeStairClimbing`, `HKWorkoutActivityTypeJumpRope`, `HKWorkoutActivityTypeStairs`, `HKWorkoutActivityTypeStepTraining`, `HKWorkoutActivityTypeCardioDance`, `HKWorkoutActivityTypeSocialDance`, `HKWorkoutActivityTypeOther`, `HKWorkoutActivityTypeSwimBikeRun`, `HKWorkoutActivityTypeRowing`, `HKWorkoutActivityTypeSwimming`, `HKWorkoutActivityTypeWaterFitness` + `HKQuantityTypeIdentifierHeartRate` | Sessions per week (count) | Apple Fitness+, Strava, Nike Run Club, Peloton, Zwift, any app with HR tracking | Each cardio workout with heart rate in 60-70% of max range counts as one session |
| Daily Steps | Steps | `HKQuantityTypeIdentifierStepCount` | Steps per day | iPhone (built-in), Apple Watch, Fitbit, Garmin (via sync), other fitness trackers | - |
| Strength Training Sessions | Strength Training Sessions | `HKWorkoutActivityTypeFunctionalStrengthTraining`, `HKWorkoutActivityTypeTraditionalStrengthTraining`, `HKWorkoutActivityTypeCrossTraining` | Sessions per week (count) | Apple Fitness+, Strong, JEFIT, Nike Training Club, Fitbod | Each workout under these types counts as one session |
| Strength Training Duration (minutes) | Strength Training Duration | `HKWorkoutActivityTypeFunctionalStrengthTraining`, `HKWorkoutActivityTypeTraditionalStrengthTraining`, `HKWorkoutActivityTypeCrossTraining` | Minutes per session (average) | Apple Fitness+, Strong, JEFIT, Nike Training Club, Fitbod | Duration of each strength workout |
| HIIT (High-Intensity Interval Training) Sessions | HIIT Sessions | `HKWorkoutActivityTypeHighIntensityIntervalTraining` | Sessions per week (count) | Apple Fitness+, Peloton, CrossFit apps, Freeletics | - |
| HIIT (High-Intensity Interval Training) Session Duration | HIIT Duration | `HKWorkoutActivityTypeHighIntensityIntervalTraining` | Minutes per session (average) | Apple Fitness+, Peloton, CrossFit apps, Freeletics | Includes warm-up and cool-down if logged as part of session |
| Active Time (minutes) | Active Time | `HKQuantityTypeIdentifierAppleExerciseTime` | Minutes per day | Apple Watch, third-party apps | Tracks movement at or above brisk walk intensity |
| Sedentary Time (minutes) | Sedentary Time | `HKQuantityTypeIdentifierAppleStandHour` (calculated) | Hours per day | Apple Watch, other devices with stand tracking | Calculated from waking hours minus active/stand time |
| Mobility Sessions | Mobility Sessions | `HKWorkoutActivityTypeFlexibility`, `HKWorkoutActivityTypeCooldown`, `HKWorkoutActivityTypePreparationAndRecovery`, `HKWorkoutActivityTypeYoga` | Sessions per week (count) | Apple Fitness+, Down Dog, StretchIt, Pliability | - |
| Mobility Session Duration (minutes) | Mobility Duration | `HKWorkoutActivityTypeFlexibility`, `HKWorkoutActivityTypeCooldown`, `HKWorkoutActivityTypePreparationAndRecovery`, `HKWorkoutActivityTypeYoga` | Minutes per session (average) | Apple Fitness+, Down Dog, StretchIt, Pliability | Duration of each mobility/flexibility workout |
| Grip Strength | Grip Strength | `HKQuantityTypeIdentifierHandGripStrength` | Kilograms (kg) or Pounds (lbs) | Smart dynamometers (e.g., Camry Digital Hand Dynamometer) | Measured for each hand; may display average or maximum |
| VO2 Max | VO2 Max | `HKQuantityTypeIdentifierVO2Max` | mL/kg/min | Apple Watch Series 3+, fitness testing equipment | Estimated during outdoor cardio with HR and GPS |

---

## Sleep Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Sleep Duration | Sleep Duration | `HKCategoryTypeIdentifierSleepAnalysis` | Hours per night | Apple Watch (Sleep app), AutoSleep, Pillow, Sleep Cycle, Oura Ring (via sync) | Aggregates Core, Deep, and REM sleep stages. Excludes awake time in bed |
| Sleep Timing Consistency (minutes) | Sleep Time Consistency | `HKCategoryTypeIdentifierSleepAnalysis` (start time) | Time (HH:MM) | Apple Watch (Sleep app), AutoSleep, Pillow, Sleep Cycle, Oura Ring (via sync) | Extracts bedtime from sleep session start |
| Wake Time Consistency (Minutes) | Wake Time Consistency | `HKCategoryTypeIdentifierSleepAnalysis` (end time) | Time (HH:MM) | Apple Watch (Sleep app), AutoSleep, Pillow, Sleep Cycle, Oura Ring (via sync) | Extracts wake time from sleep session end |

---

## Cardiovascular & Recovery Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| HRV | HRV | `HKQuantityTypeIdentifierHeartRateVariabilitySDNN` | Milliseconds (ms) | Apple Watch, Oura Ring (via sync), Whoop (via sync), chest strap monitors | SDNN measurement method. Higher values indicate better recovery |

---

## Body Composition Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Weight | Weight | `HKQuantityTypeIdentifierBodyMass` | Pounds (lbs) | Withings, Eufy, QardioBase, FitTrack, other smart scales | - |
| BMI | BMI | `HKQuantityTypeIdentifierBodyMassIndex` | BMI value (kg/m²) | Withings, Eufy, QardioBase, FitTrack, other smart scales (or auto-calculated from height/weight) | - |
| Body Fat % | Body Fat % | `HKQuantityTypeIdentifierBodyFatPercentage` | Percent (%) | Withings Body+, Eufy, FitTrack, InBody scales | From bioelectrical impedance or DEXA scans |
| Lean Body Mass | Lean Body Mass | `HKQuantityTypeIdentifierLeanBodyMass` | Pounds (lbs) or Kilograms (kg) | InBody scales, Withings Body Comp, other body composition analyzers | Muscle + bone + organs, excluding fat |

---

## Core Care Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Daily Alcohol Intake (drinks) | Alcohol | `HKQuantityTypeIdentifierNumberOfAlcoholicBeverages` | Drinks (standard drinks) | DrinkControl, Moins, other alcohol tracking apps | 1 drink = 12oz beer, 5oz wine, or 1.5oz spirits |
| Daily Brushing (times/day) | Toothbrushing | `HKCategoryTypeIdentifierToothbrushingEvent` | Count (times per day) | Oral-B smart toothbrushes, Philips Sonicare smart toothbrushes | Each brushing session counts as one event |

---

## Lifestyle Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Outdoor Time (minutes) | Outdoor Time | TBD - Not using `HKQuantityTypeIdentifierTimeInDaylight` for MVP | Minutes per day | TBD | TimeInDaylight only tracks daylight hours (>1,000 lux) and would exclude outdoor time before sunrise/after sunset. Alternative approach needed. |

---

## Device Usage Metrics

| Deprecated Metric Name | Current Metric Name | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|------------------------|---------------------|----------------|------|------------------------|-------|
| Wearable/Tracking Protocol | Wearable/Tracking | Any active HealthKit data sync | Binary (Yes/No per day) | Any device or app syncing to HealthKit | Automatically tracks whether data is syncing from devices |

---

## Setting Up HealthKit Sync

### Initial Setup
1. Open the WellPath app
2. Navigate to **Settings** > **Connected Devices**
3. Tap **"Connect to Apple Health"**
4. Review and grant permissions for the metrics you want to track
5. Data will begin syncing automatically

### Managing Permissions
- You can adjust HealthKit permissions at any time through:
  - **iPhone Settings** > **Privacy & Security** > **Health** > **WellPath**
  - Or through the **Health app** > **Sharing** > **Apps** > **WellPath**

### Data Refresh
- HealthKit data syncs to WellPath automatically when:
  - The app is opened
  - Background refresh is enabled
  - New data is added to HealthKit
- Manual refresh: Pull down on any metric screen to force a sync

---

## Troubleshooting

### Data Not Syncing
1. Verify HealthKit permissions are enabled for the specific metric
2. Ensure the source app/device is properly syncing to Apple Health
3. Check that WellPath has background app refresh enabled
4. Try force-closing and reopening WellPath
5. Verify your device is running iOS 16.0 or later

### Duplicate Data
- If you're both manually logging and syncing data from HealthKit for the same metric, duplicates may occur
- Choose one method (manual or HealthKit sync) per metric for best results
- WellPath will attempt to deduplicate identical timestamps automatically

### Missing Workouts
- Ensure workouts are categorized correctly in Apple Health (check workout type)
- For Zone 2 cardio, verify that heart rate data was recorded during the workout
- Some older workout entries may not include heart rate data needed for Zone 2 classification

---

## Privacy & Data Security

- All HealthKit data remains on your device and is subject to Apple's strict privacy policies
- WellPath only accesses the specific health data types you explicitly authorize
- You can revoke HealthKit access at any time through iOS Settings
- WellPath does not sell or share your health data with third parties

---

## To Be Confirmed Metrics

The following metrics are under consideration for HealthKit integration:

| Metric | HealthKit Type | Unit | Compatible Apps/Devices | Notes |
|--------|---------------|------|------------------------|-------|
| Breathwork/Mindfulness Sessions | `HKCategoryTypeIdentifierMindfulSession` | Sessions per day (count) | Headspace, Calm, Insight Timer, Apple Health Mindfulness | Would track meditation and breathwork sessions |

---

## Notes for Future Development

- **Fiber Servings:** Currently, fiber grams sync from HealthKit via nutrition tracking apps, but fiber servings are tracked separately in WellPath and require manual logging. Auto-conversion from grams to servings is planned for v2.
