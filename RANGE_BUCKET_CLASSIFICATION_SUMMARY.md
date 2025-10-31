# Range Bucket Classification Summary

## Overview

Added `range_bucket` column to `biomarkers_detail` and `biometrics_detail` tables to classify all ranges into three simple categories for easier frontend handling.

## Classification Logic

### 1. **Optimal**
Ranges with "optimal" in the name (excluding "suboptimal" and "near-optimal"):
- `Optimal`
- `Optimal Serum Calcium`
- `Optimal Ionized Calcium`

**Result:**
- Biomarkers: 3 unique ranges (89 rows)
- Biometrics: 1 unique range (52 rows)

### 2. **In-Range**
Ranges explicitly marked as in acceptable range:
- Contains `in-range` (any variation: In-Range, in-range low, in-range high, etc.)
- Contains `normal` (Normal, High Normal, High-Normal)
- Contains `good` (Good)
- Contains `near-optimal` (Near-Optimal)

**Examples:**
- `In-Range`
- `In-Range (High)`
- `In-Range (Low)`
- `Normal`
- `High Normal`
- `High-Normal`
- `Near-Optimal`
- `Good`

**Result:**
- Biomarkers: 12 unique ranges (72 rows)
- Biometrics: 2 unique ranges (6 rows)

### 3. **Out-of-Range**
Everything else - any value outside the optimal or in-range categories:

**Examples:**
- `Critically High` / `Critically Low`
- `High` / `Low`
- `Elevated` / `Deficient`
- `Suboptimal` / `Suboptimal High` / `Suboptimal Low`
- `Borderline High` / `Borderline Low`
- `Mildly Elevated` / `Mildly Low`
- `Moderately Elevated`
- `Severely Elevated` / `Severely Low`
- `Excessive` / `Insufficient`
- `Diabetes` / `Prediabetes`
- `High Risk` / `Moderate Risk` / `Low Risk`
- And many more clinical conditions...

**Result:**
- Biomarkers: 107 unique ranges (382 rows)
- Biometrics: 17 unique ranges (168 rows)

## Database Changes

### Migration: `20251022_add_range_bucket_classification.sql`

```sql
-- Added columns
ALTER TABLE biomarkers_detail ADD COLUMN range_bucket TEXT;
ALTER TABLE biometrics_detail ADD COLUMN range_bucket TEXT;

-- Updated all rows with classification
UPDATE biomarkers_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal';
-- ... (122 range classifications for biomarkers)

UPDATE biometrics_detail SET range_bucket = 'Optimal' WHERE range_name = 'Optimal';
-- ... (20 range classifications for biometrics)
```

## Results Summary

### Biomarkers
| Range Bucket | Unique Ranges | Total Rows |
|--------------|---------------|------------|
| Optimal      | 3             | 89         |
| In-Range     | 12            | 72         |
| Out-of-Range | 107           | 382        |
| **Total**    | **122**       | **543**    |

### Biometrics
| Range Bucket | Unique Ranges | Total Rows |
|--------------|---------------|------------|
| Optimal      | 1             | 52         |
| In-Range     | 2             | 6          |
| Out-of-Range | 17            | 168        |
| **Total**    | **20**        | **226**    |

## Frontend Usage

### SwiftUI Example

```swift
// Color coding based on bucket
func getBucketColor(bucket: String) -> Color {
    switch bucket {
    case "Optimal":
        return .green
    case "In-Range":
        return .blue
    case "Out-of-Range":
        return .red
    default:
        return .gray
    }
}

// Icon based on bucket
func getBucketIcon(bucket: String) -> String {
    switch bucket {
    case "Optimal":
        return "checkmark.circle.fill"
    case "In-Range":
        return "checkmark.circle"
    case "Out-of-Range":
        return "exclamationmark.triangle.fill"
    default:
        return "questionmark.circle"
    }
}

// Display in UI
struct BiomarkerRangeView: View {
    let range: BiomarkerRange

    var body: some View {
        HStack {
            Image(systemName: getBucketIcon(bucket: range.bucket))
                .foregroundColor(getBucketColor(bucket: range.bucket))

            Text(range.rangeName)

            Spacer()

            Text("\(range.rangeLow) - \(range.rangeHigh)")
        }
    }
}
```

### API Query Example

```sql
-- Get patient's biomarker with range and bucket
SELECT
    b.biomarker,
    pb.value,
    bd.range_name,
    bd.range_bucket,
    bd.range_low,
    bd.range_high
FROM patient_biomarkers pb
JOIN biomarkers b ON pb.biomarker = b.biomarker
JOIN biomarkers_detail bd
    ON b.biomarker = bd.biomarker
    AND pb.value BETWEEN bd.range_low AND bd.range_high
    AND (bd.gender = 'all' OR bd.gender = pb.patient_gender)
    AND (pb.patient_age BETWEEN bd.age_low AND bd.age_high)
WHERE pb.patient_id = 'user-123'
    AND pb.biomarker = 'glucose_fasting';
```

Result:
```json
{
  "biomarker": "glucose_fasting",
  "value": 105,
  "range_name": "Prediabetes",
  "range_bucket": "Out-of-Range",
  "range_low": 100,
  "range_high": 125
}
```

## Benefits for Mobile App

1. **Simplified Color Coding**: Three colors instead of 122 different range names
   - Green for Optimal
   - Blue for In-Range
   - Red/Orange for Out-of-Range

2. **Simplified Filtering**: Easy to filter/sort by bucket
   ```swift
   biomarkers.filter { $0.range_bucket == "Out-of-Range" }
   ```

3. **Simplified Summary Stats**: Count metrics by bucket
   ```sql
   SELECT range_bucket, COUNT(*)
   FROM patient_biomarkers_with_ranges
   GROUP BY range_bucket
   ```
   Result: "3 Optimal, 5 In-Range, 2 Out-of-Range"

4. **Simplified Alerts**: Only alert for Out-of-Range values
   ```swift
   if biomarker.range_bucket == "Out-of-Range" {
       showAlert()
   }
   ```

5. **Cleaner UI**: Can show bucket badge instead of full range name
   - ✅ Optimal
   - ✓ In-Range
   - ⚠️ Out-of-Range

## Notes on Classification

- **Conservative Approach**: Only ranges explicitly marked as "optimal", "in-range", "normal", or "good" are classified as such
- **Everything Else**: All borderline, suboptimal, elevated, deficient, etc. are Out-of-Range
- **Multiple In-Range Variants**: Accounts for different in-range levels (low, high, upper, lower, slightly high)
- **Gender/Age Specific**: Same range_name can have different buckets based on demographic filters
- **Clinical Relevance**: Out-of-Range includes everything from mild deviations to critical conditions

## Future Enhancements

Consider adding a `severity` column to Out-of-Range values:
- `mild` - Borderline, Mildly Elevated, Suboptimal
- `moderate` - Elevated, Moderately Elevated, High/Low
- `severe` - Critically High/Low, Severely Elevated
- `critical` - Kidney Failure, Diabetes, etc.

This would allow for more nuanced alerts and UI treatment within the Out-of-Range bucket.
