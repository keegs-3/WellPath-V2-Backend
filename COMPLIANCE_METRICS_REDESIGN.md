# Compliance & Screening Metrics Redesign

## Problem Statement

Currently, all compliance/screening metrics are configured as `chart` widgets with `current_value` chart type. This doesn't make sense for these metrics because:

1. **They're event-based, not aggregation-based**: Screenings are discrete events with dates (DEF_SCREENING_DATE), not continuous measurements
2. **They need "time since" calculations**: Show "6 months since last dental exam", not aggregated values
3. **They need compliance status**: Show if overdue based on screening_compliance_rules (frequency_months)
4. **They need calendar/timeline visualization**: Plot all screening events on a calendar or timeline, not bar charts

## Current State

### Screening Event Structure
- **Event Type**: EVT_SCREENING
- **Fields**:
  - DEF_SCREENING_DATE (timestamp) - when the screening occurred
  - DEF_SCREENING_TYPE (reference) - mammogram, colonoscopy, dental, etc.
  - DEF_SCREENING_NAME (text) - specific name
  - DEF_SCREENING_RESULT (category) - result of screening

### Compliance Rules
Table: `screening_compliance_rules`
- screening_type (e.g., "mammogram_female_50_150_avg_high")
- frequency_months (e.g., 12 = annual, 6 = biannual)
- gender, age_min, age_max, risk_level filters

**Example Rules:**
- Dental: every 6 months (all genders, all ages)
- Mammogram (female 50+, avg risk): every 12 months
- Colonoscopy (all, avg risk): every 120 months (10 years)
- Colonoscopy (all, high risk): every 60 months (5 years)

### Current Display Metrics (INCORRECT)

22 screening-related metrics currently marked as:
- widget_type: 'chart'
- chart_type_id: 'current_value'
- Examples:
  - DISP_MONTHS_SINCE_LAST_DENTAL_EXAM (unit: months)
  - DISP_YEARS_SINCE_LAST_COLONOSCOPY (unit: months)
  - DISP_MAMMOGRAM_COMPLIANCE_STATUS (unit: percentage)
  - DISP_DENTAL_COMPLIANCE_STATUS (unit: percentage)

**Problems:**
1. These can't be queried from aggregation_results_cache (no aggregations for events)
2. "time since" must be calculated dynamically: `NOW() - MAX(screening_date) WHERE screening_type = 'dental'`
3. Compliance status depends on user's age/gender/risk + rule lookup
4. No way to show calendar view or timeline of all screening events

## Proposed Solution

### 1. New Widget Types

Add to display_metrics.widget_type:
- **'compliance_tracker'** - For screening compliance with overdue indicators
- **'event_timeline'** - For calendar/timeline view of all events
- **'time_since'** - For "X months since last..." displays

### 2. New Chart Types

Add to chart_types table:

```sql
INSERT INTO chart_types (chart_type_id, description) VALUES
('event_calendar', 'Calendar view showing discrete events with dates'),
('event_timeline', 'Timeline showing all events for a type with color coding'),
('time_since_indicator', 'Large number showing time elapsed with status indicator'),
('compliance_card', 'Card showing last event date, time since, next due date, and status');
```

### 3. New Display Metric Configuration

For compliance metrics, add metadata:

```sql
-- Example: Dental Screening Compliance
{
  display_metric_id: 'DISP_DENTAL_SCREENING',
  display_name: 'Dental Exams',
  widget_type: 'compliance_tracker',
  chart_type_id: 'compliance_card',

  -- New metadata for event-based metrics
  metadata: {
    event_type: 'EVT_SCREENING',
    screening_type_filter: 'dental',  -- filters DEF_SCREENING_TYPE
    calculation_method: 'time_since_last',
    compliance_rule_lookup: 'dental_male_female_0_150_avg',

    display_config: {
      show_last_date: true,
      show_time_since: true,
      show_next_due: true,
      show_status_indicator: true,  // green/yellow/red for compliant/warning/overdue
      calendar_view_enabled: true
    }
  }
}
```

### 4. Screening Types Taxonomy

Create a screening_types reference table:

```sql
CREATE TABLE screening_types (
    screening_type_id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    category TEXT NOT NULL,  -- 'preventive', 'diagnostic', etc.
    description TEXT,
    icon TEXT,
    typical_frequency_months INT,
    is_active BOOLEAN DEFAULT true
);

INSERT INTO screening_types VALUES
('dental_exam', 'Dental Exam', 'preventive', 'Regular dental checkup and cleaning', '🦷', 6, true),
('mammogram', 'Mammogram', 'preventive', 'Breast cancer screening', '🩺', 12, true),
('colonoscopy', 'Colonoscopy', 'preventive', 'Colon cancer screening', '🏥', 120, true),
('pap_smear', 'Pap Smear', 'preventive', 'Cervical cancer screening', '🩺', 36, true),
('hpv_test', 'HPV Test', 'preventive', 'HPV screening for cervical cancer', '🩺', 60, true),
('physical_exam', 'Annual Physical', 'preventive', 'Comprehensive annual physical exam', '👨‍⚕️', 12, true),
('skin_check', 'Skin Check', 'preventive', 'Skin cancer screening', '🔍', 12, true),
('vision_check', 'Vision Check', 'preventive', 'Eye exam and vision screening', '👓', 12, true),
('psa_test', 'PSA Test', 'preventive', 'Prostate cancer screening', '🩺', 12, true),
('breast_mri', 'Breast MRI', 'preventive', 'Breast imaging for high-risk individuals', '🩺', 12, true);
```

### 5. Calculation Functions

Create functions to calculate compliance metrics:

```sql
-- Function: Get time since last screening
CREATE OR REPLACE FUNCTION get_time_since_last_screening(
    p_user_id UUID,
    p_screening_type TEXT
) RETURNS INTERVAL AS $$
BEGIN
    RETURN NOW() - (
        SELECT MAX(pde_date.value_timestamp)
        FROM patient_data_entries pde_date
        JOIN patient_data_entries pde_type
            ON pde_date.user_id = pde_type.user_id
            AND pde_date.entry_date = pde_type.entry_date
        WHERE pde_date.user_id = p_user_id
            AND pde_date.field_id = 'DEF_SCREENING_DATE'
            AND pde_type.field_id = 'DEF_SCREENING_TYPE'
            AND pde_type.value_text = p_screening_type
    );
END;
$$ LANGUAGE plpgsql;

-- Function: Get compliance status
CREATE OR REPLACE FUNCTION get_screening_compliance_status(
    p_user_id UUID,
    p_screening_type TEXT
) RETURNS TABLE (
    last_screening_date TIMESTAMP,
    months_since NUMERIC,
    next_due_date TIMESTAMP,
    is_overdue BOOLEAN,
    status TEXT  -- 'compliant', 'due_soon', 'overdue', 'never_done'
) AS $$
DECLARE
    v_last_date TIMESTAMP;
    v_frequency_months INT;
    v_months_since NUMERIC;
    v_next_due TIMESTAMP;
BEGIN
    -- Get user's demographic info
    -- Get applicable rule based on age/gender/risk
    -- Get last screening date
    -- Calculate status

    -- Return results
    RETURN QUERY
    SELECT
        v_last_date,
        v_months_since,
        v_next_due,
        (v_months_since > v_frequency_months) as is_overdue,
        CASE
            WHEN v_last_date IS NULL THEN 'never_done'
            WHEN v_months_since > v_frequency_months THEN 'overdue'
            WHEN v_months_since > (v_frequency_months * 0.8) THEN 'due_soon'
            ELSE 'compliant'
        END as status;
END;
$$ LANGUAGE plpgsql;
```

### 6. Display Screens Integration

**Screen: SCREEN_COMPLIANCE** should show:

1. **Overview Card** - "Health Screenings Overview"
   - Count of compliant screenings
   - Count of overdue screenings
   - Next upcoming screening

2. **Individual Compliance Cards** - One per screening type
   ```
   🦷 Dental Exam
   Last: March 15, 2025
   Time since: 1 month ago
   Next due: September 15, 2025
   Status: ✅ Compliant
   ```

3. **Calendar View** - All screenings plotted
   ```
   [Calendar showing dots/icons on dates]
   🦷 3/15 | 🩺 1/10 | 🏥 2019
   ```

4. **Timeline View** - All screening types on one chart
   ```
   Dental:      |--●--|--●--|--●--| (every 6mo)
   Mammogram:   |-----●-----●-----| (every 12mo)
   Colonoscopy: ●----------------| (every 10yr)
   ```

## Metrics to Redesign

### Time Since Metrics (7 metrics)
Change from chart → time_since widget:

- DISP_MONTHS_SINCE_LAST_DENTAL_EXAM
- DISP_MONTHS_SINCE_LAST_MAMMOGRAM
- DISP_YEARS_SINCE_LAST_COLONOSCOPY
- DISP_YEARS_SINCE_LAST_HPV_SCREENING
- DISP_YEARS_SINCE_LAST_PHYSICAL

### Compliance Status Metrics (10+ metrics)
Change from chart → compliance_tracker widget:

- DISP_DENTAL_COMPLIANCE_STATUS
- DISP_MAMMOGRAM_COMPLIANCE_STATUS
- DISP_COLONOSCOPY_COMPLIANCE_STATUS
- DISP_CERVICAL_SCREENING_COMPLIANCE_STATUS
- DISP_PHYSICAL_EXAM_COMPLIANCE_STATUS
- DISP_PSA_TEST_COMPLIANCE_STATUS
- DISP_SKIN_CHECK_COMPLIANCE_STATUS
- DISP_BREAST_MRI_COMPLIANCE_STATUS
- DISP_VISION_CHECK_COMPLIANCE_STATUS

### Create New Comprehensive Metrics

- DISP_ALL_SCREENINGS_CALENDAR (event_timeline widget)
- DISP_SCREENING_COMPLIANCE_SUMMARY (compliance_tracker widget, shows overall status)

## Implementation Plan

### Phase 1: Data Model Updates
1. Create screening_types reference table
2. Add new widget types to ENUM or validation
3. Add new chart types to chart_types table
4. Add metadata column to display_metrics (JSONB)

### Phase 2: Calculation Functions
1. Create get_time_since_last_screening()
2. Create get_screening_compliance_status()
3. Create get_all_user_screenings()
4. Create view: patient_screening_compliance_status

### Phase 3: Update Display Metrics
1. Update all 22 screening metrics with correct widget_type
2. Add metadata for event-based calculations
3. Remove invalid display_metrics_aggregations links (these don't aggregate)
4. Create new comprehensive metrics for calendar/timeline views

### Phase 4: API Endpoints
Mobile app will need new endpoints:
- GET /api/screenings/{user_id}/compliance - all compliance statuses
- GET /api/screenings/{user_id}/timeline - all screening events for calendar
- GET /api/screenings/{user_id}/{type}/status - specific screening compliance
- POST /api/screenings/{user_id} - log a new screening event

### Phase 5: Mobile UI Components
Swift/SwiftUI views needed:
- ComplianceCardView - individual screening status
- ScreeningCalendarView - calendar with event dots
- ScreeningTimelineView - multi-type timeline chart
- TimeSinceIndicatorView - large "6 months" with status color

## Database Schema Changes

```sql
-- 1. Add screening types reference
CREATE TABLE screening_types (
    screening_type_id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    category TEXT,
    description TEXT,
    icon TEXT,
    typical_frequency_months INT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Update DEF_SCREENING_TYPE to reference this table
UPDATE data_entry_fields
SET reference_table = 'screening_types'
WHERE field_id = 'DEF_SCREENING_TYPE';

-- 3. Add metadata to display_metrics
ALTER TABLE display_metrics
ADD COLUMN IF NOT EXISTS metadata JSONB DEFAULT '{}';

-- 4. Add new chart types
INSERT INTO chart_types (chart_type_id, description) VALUES
('event_calendar', 'Calendar view showing discrete events'),
('event_timeline', 'Timeline with color-coded event types'),
('time_since_indicator', 'Time elapsed with status indicator'),
('compliance_card', 'Compliance card with dates and status');

-- 5. Create compliance view
CREATE OR REPLACE VIEW patient_screening_compliance_v AS
SELECT
    u.user_id,
    st.screening_type_id,
    st.display_name,
    MAX(pde_date.value_timestamp) as last_screening_date,
    EXTRACT(EPOCH FROM (NOW() - MAX(pde_date.value_timestamp))) / (30.44 * 86400) as months_since,
    scr.frequency_months,
    CASE
        WHEN MAX(pde_date.value_timestamp) IS NULL THEN 'never_done'
        WHEN EXTRACT(EPOCH FROM (NOW() - MAX(pde_date.value_timestamp))) / (30.44 * 86400) > scr.frequency_months THEN 'overdue'
        WHEN EXTRACT(EPOCH FROM (NOW() - MAX(pde_date.value_timestamp))) / (30.44 * 86400) > (scr.frequency_months * 0.8) THEN 'due_soon'
        ELSE 'compliant'
    END as compliance_status
FROM users u
CROSS JOIN screening_types st
LEFT JOIN patient_data_entries pde_date
    ON u.user_id = pde_date.user_id
    AND pde_date.field_id = 'DEF_SCREENING_DATE'
LEFT JOIN patient_data_entries pde_type
    ON pde_date.user_id = pde_type.user_id
    AND pde_date.id != pde_date.id  -- different row, same event
    AND pde_type.field_id = 'DEF_SCREENING_TYPE'
    AND pde_type.value_text = st.screening_type_id
LEFT JOIN screening_compliance_rules scr
    ON st.screening_type_id = scr.screening_type
    -- Add age/gender/risk matching logic here
WHERE st.is_active = true
GROUP BY u.user_id, st.screening_type_id, st.display_name, scr.frequency_months;
```

## Mobile App Query Examples

### Get Compliance Card Data
```swift
// Swift query for compliance card
struct ScreeningCompliance {
    let screeningType: String
    let displayName: String
    let lastDate: Date?
    let monthsSince: Double?
    let nextDueDate: Date?
    let status: ComplianceStatus  // .compliant, .dueSoon, .overdue, .neverDone
}

// Query: GET /api/screenings/{userId}/dental/status
// Returns:
{
  "screening_type": "dental_exam",
  "display_name": "Dental Exam",
  "last_screening_date": "2025-03-15T10:00:00Z",
  "months_since": 1.2,
  "next_due_date": "2025-09-15T00:00:00Z",
  "frequency_months": 6,
  "status": "compliant"
}
```

### Get All Screenings for Calendar
```swift
// Query: GET /api/screenings/{userId}/timeline
// Returns:
{
  "screenings": [
    {
      "date": "2025-03-15T10:00:00Z",
      "type": "dental_exam",
      "display_name": "Dental Exam",
      "icon": "🦷"
    },
    {
      "date": "2025-01-10T14:00:00Z",
      "type": "mammogram",
      "display_name": "Mammogram",
      "icon": "🩺"
    }
  ]
}
```

## Summary

**Key Changes:**
1. ✅ Create screening_types reference table
2. ✅ Add metadata JSONB column to display_metrics
3. ✅ Add new chart types for event/compliance display
4. ✅ Create calculation functions for time_since and compliance_status
5. ✅ Update 22 existing screening metrics with correct widget/chart types
6. ✅ Create patient_screening_compliance view for easy querying
7. ✅ Remove invalid aggregation links for these metrics

**Result:**
- Compliance metrics work correctly as event-based tracking
- Mobile app can show calendar views, timelines, and status cards
- Overdue indicators work based on screening_compliance_rules
- "Time since" calculated dynamically, not from aggregations
