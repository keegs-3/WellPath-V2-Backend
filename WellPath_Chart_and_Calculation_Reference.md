# WellPath Chart and Calculation Reference

> Comprehensive guide to chart designs, calculation methods, and data visualization standards for WellPath

**Last Updated:** October 20, 2025

---

## Table of Contents

1. [Apple Health Sleep Charts](#apple-health-sleep-charts)
2. [Calculation Methods](#calculation-methods)
3. [Chart Types and Display Formats](#chart-types-and-display-formats)
4. [Time Windows and Aggregation](#time-windows-and-aggregation)

---

# Apple Health Sleep Charts

## Overview

WellPath sleep visualizations follow Apple Health design patterns for familiarity and usability. There are 2 main chart types with different time period views.

---

## Chart Type 1: Stages View

### What It Shows
- Sleep stages over time (Awake, REM, Core/Light, Deep)
- Horizontal timeline for single nights
- Vertical bars for multi-night views

### Time Period Options

#### Day View (Single Night)
- **Orientation:** Horizontal timeline (left to right)
- **X-axis:** Time progression (e.g., 10 PM to 8 AM)
- **Y-axis:** Sleep stages stacked vertically
- **Visual Pattern:** Like a Gantt chart showing continuous time blocks
- **Color Coding:**
  - Deep Sleep: Dark blue/navy
  - Core Sleep: Teal/cyan
  - REM Sleep: Purple/blue
  - Awake: Light coral/salmon

**CRITICAL:** This is a horizontal timeline where time flows left to right, NOT a vertical bar chart.

#### Week View (7 Nights)
- **Orientation:** Vertical bars (one per night)
- **X-axis:** Days of week (Mon-Sun)
- **Y-axis:** Time of day (dynamic range based on sleep data)
- **Stacking:** Top to bottom represents bedtime to wake time
  - Top of bar = Bedtime
  - Bottom of bar = Wake time
- **Visual Pattern:** Each bar is a vertical timeline of that night's sleep

**CRITICAL:** Time flows top-to-bottom in these bars (bedtime at top, wake at bottom), NOT the typical bottom-to-top bar chart pattern.

#### Month View (30+ Nights)
- Same vertical bar structure as Week View
- More bars compressed horizontally
- May show abbreviated labels (every 3-5 days)

#### 6-Month View (26 Weeks)
- Weekly aggregated data
- Each bar represents one week's average
- Simplified stage visualization

---

## Chart Type 2: Amounts View

### What It Shows
- Duration spent in each sleep stage
- Two modes: Default (all stages) and Selected (single stage)

### Default State (No Selection)

**Stacked Bar Chart showing all stages:**
- Each bar shows total sleep composition
- Stages stacked from bottom to top: Deep, Core, REM, Awake
- Standard stacked bar chart pattern

### Selected State (Stage Tapped)

**Single Stage View:**
- All bars show ONLY the selected stage's duration
- All bars use the selected stage's color
- Percentages section highlights the selected stage
- Use case: Track REM sleep trends over time

**CRITICAL for Longer Views:** When a stage is selected in Week/Month/6M views, that stage must be repositioned to the bottom of the chart to make trends more visible.

### Time Period Options
- Day: 4 bars (one per stage category)
- Week: 7 bars (one per night)
- Month: 30+ bars (one per night)
- 6-Month: 26 bars (weekly averages)

---

## Dynamic Time Axis Calculation

### Critical Requirement
Time axes must be **dynamically calculated** based on actual sleep data, NOT fixed ranges.

### Calculation Method

```javascript
// For Week/Month views with multiple nights:
function calculateTimeAxis(sleepData) {
  // 1. Find earliest bedtime across all nights
  const earliestBedtime = Math.min(...sleepData.map(night => night.bedtime));
  
  // 2. Find latest wake time across all nights
  const latestWakeTime = Math.max(...sleepData.map(night => night.wakeTime));
  
  // 3. Add 30-60 minute buffer on each end
  const startTime = earliestBedtime - 30 * 60; // 30 min buffer
  const endTime = latestWakeTime + 30 * 60; // 30 min buffer
  
  return { startTime, endTime };
}

// For Day view with single night:
function calculateDayViewAxis(nightData) {
  const bedtime = nightData.bedtime;
  const wakeTime = nightData.wakeTime;
  
  // Add buffer
  const startTime = bedtime - 45 * 60; // 45 min buffer
  const endTime = wakeTime + 45 * 60; // 45 min buffer
  
  return { startTime, endTime };
}
```

**Key Points:**
- Axis range is different for each user and time period
- Automatically adjusts to show actual sleep patterns
- All bars in Week/Month views share the same Y-axis
- Each bar is positioned within that shared range based on its individual bedtime/wake time

---

## Summary Metrics Display

### Always Show:
- Total Sleep Time (hours:minutes)
- Average Sleep Time (for multi-night views)
- Time in Bed
- Sleep Efficiency %
- Average by Stage (percentages):
  - Deep Sleep %
  - Core Sleep %
  - REM Sleep %
  - Awake %

### Optional Metrics:
- Time to Fall Asleep
- Times Awoken
- Sleep Consistency Score (for week+ views)

---

## Color Palette

### Official Apple Health Colors:
```css
--deep-sleep: #1E3A8A;     /* Dark blue/navy */
--core-sleep: #06B6D4;     /* Teal/cyan */
--rem-sleep: #7C3AED;      /* Purple/blue */
--awake: #FB7185;          /* Light coral/salmon */
--background: #F9FAFB;     /* Light gray */
--text-primary: #111827;   /* Dark gray */
--text-secondary: #6B7280; /* Medium gray */
```

---

## Implementation Checklist

- [ ] Day Stages view uses horizontal timeline (left-to-right)
- [ ] Week/Month Stages views use vertical bars with top-to-bottom time flow
- [ ] Amounts view supports both stacked (default) and single-stage modes
- [ ] Selected stage moves to bottom in longer Amounts views
- [ ] Time axis dynamically calculated from actual data
- [ ] Proper color coding for all sleep stages
- [ ] Summary metrics displayed accurately
- [ ] Charts responsive to different screen sizes
- [ ] Smooth transitions between time periods
- [ ] Touch/click interactions work correctly

---

# Calculation Methods

## Standard Aggregation Functions

| Method | Name | Description | SQL Function | Example | Use Cases |
|--------|------|-------------|--------------|---------|-----------|
| **SUM** | Sum | Adds all values together within the time window | `SUM()` | Total steps in a week: 5000 + 6000 + 7000 = 18,000 steps | Cumulative metrics like total calories, total active time, total meals |
| **COUNT** | Count | Counts the number of occurrences within the time window | `COUNT()` | Number of meals logged this week: 21 meals | Frequency metrics like number of workouts, number of meals, number of sleep sessions |
| **AVG** | Average | Calculates the mean of all values within the time window | `AVG()` | Average sleep: (7.5 + 8 + 6.5 + 7 + 8.5 + 7 + 6) / 7 = 7.2 hours | Typical values like average heart rate, average meal size, average workout duration |
| **MIN** | Minimum | Returns the lowest value within the time window | `MIN()` | Shortest sleep session this week: 5.5 hours | Identifying lowest points like minimum blood glucose, shortest workout, earliest wake time |
| **MAX** | Maximum | Returns the highest value within the time window | `MAX()` | Longest workout this month: 90 minutes | Identifying peak values like maximum heart rate, longest fasting window, highest step count |

---

## Advanced Statistical Functions

| Method | Name | Description | SQL Function | Example | Use Cases |
|--------|------|-------------|--------------|---------|-----------|
| **STDEV** | Standard Deviation | Measures variability/consistency of values within the time window | `STDDEV()` | Sleep consistency: [7, 7.5, 7, 8, 7] has low STDEV (consistent); [5, 9, 6, 10, 5] has high STDEV (inconsistent) | Consistency metrics like workout duration variability, eating window consistency, glucose stability |
| **MEDIAN** | Median | Returns the middle value when sorted (50th percentile) | `PERCENTILE_CONT(0.5)` | Median workout: 45 min (less affected by that one 3-hour hike outlier) | When outliers would skew AVG, like typical meal size, typical blood pressure |
| **MODE** | Mode | Returns the most frequently occurring value | `MODE()` | Most common meal time: 12:30 PM appears 15 times this month | Finding patterns like most common workout time, most frequent meal type |
| **RANGE** | Range | Difference between maximum and minimum values | `MAX() - MIN()` | Blood glucose range today: 140 - 80 = 60 mg/dL | Measuring spread like daily temperature variation, glucose variability |
| **CV** | Coefficient of Variation | Standard deviation divided by mean (normalized variability) | `STDDEV() / AVG()` | Activity consistency: STDEV(30) / AVG(45) = 0.67 (moderately consistent) | Comparing variability across metrics with different scales (sleep hours vs step counts) |

---

## Consistency Score Calculations

### Sleep/Wake Time Consistency

**Formula:**
```javascript
// Calculate standard deviation of times over analysis period
sleep_time_stdev_minutes = STDEV(sleep_times_over_analysis_period_in_minutes)
wake_time_stdev_minutes = STDEV(wake_times_over_analysis_period_in_minutes)
```

**Key Points:**
- Analysis period is configurable (7, 30, 90 days, or custom)
- Output in minutes (not percentages)
- Convert times to minutes from midnight for calculation
- Minimum data requirement: at least 50% of days in analysis period

**Interpretation:**
- 15 minutes STDEV = pretty consistent
- 45 minutes STDEV = somewhat inconsistent
- 90+ minutes STDEV = very inconsistent

**Why Standard Deviation:**
- More interpretable ("your wake time varies by ±30 minutes")
- More actionable (clear improvement targets)
- Avoids arbitrary thresholds and scaling factors

---

## Most Commonly Used Calculations

### Primary (Use Most Often):
1. **SUM** - Total values over time
2. **COUNT** - Frequency of occurrences
3. **AVG** - Typical/average values
4. **STDEV** - Consistency metrics
5. **MIN/MAX** - Ranges and extremes

### Specialized (Use When Appropriate):
1. **MEDIAN** - Better than AVG when outliers present
2. **CV** - For normalized consistency across different scales
3. **MODE** - For pattern identification
4. **RANGE** - For measuring variability spread

---

# Chart Types and Display Formats

## Display Type Categories

### 1. Current Value
**Use Case:** Single point-in-time metric

**Visual Elements:**
- Large number display
- Unit label
- Optional trend indicator (up/down arrow)
- Color coding based on target ranges

**Examples:**
- Last Night's Sleep: 7.2 hours
- Current Weight: 165 lbs
- Today's Eating Window: 10.5 hours

---

### 2. Progress Bar
**Use Case:** Progress toward a daily/weekly goal

**Visual Elements:**
- Horizontal bar showing percentage complete
- Current value / target value
- Color gradient (red → yellow → green)
- Percentage text overlay

**Examples:**
- Your Active Time Today: 35/60 minutes (58%)
- Daily Steps: 8,500/10,000 (85%)
- Water Intake: 6/8 cups (75%)

---

### 3. Trend Line
**Use Case:** Change over time with continuous data

**Visual Elements:**
- Line graph with time on X-axis
- Single or multiple lines for comparison
- Target line (if applicable)
- Data points with hover details
- Shaded areas for target ranges

**Examples:**
- This Week's Activity (7 days of active minutes)
- Sleep Duration Trend (30-day view)
- Weight Change (90-day view)

---

### 4. Bar Chart (Vertical)
**Use Case:** Discrete time periods with comparison

**Visual Elements:**
- Vertical bars (one per time unit)
- X-axis: Time periods (days/weeks/months)
- Y-axis: Value scale
- Color coding based on targets
- Value labels on/above bars

**Examples:**
- Weekly Workout Count (7 bars for Mon-Sun)
- Monthly Meal Timing (30 bars for each day)
- Quarterly Sleep Efficiency (3 bars for 3 months)

---

### 5. Bar Chart (Horizontal)
**Use Case:** Comparing multiple categories

**Visual Elements:**
- Horizontal bars (one per category)
- Y-axis: Category names
- X-axis: Value scale
- Sorted by value (descending)
- Value labels at end of bars

**Examples:**
- Vegetable Variety (bars for each color group)
- Exercise Types This Week (bars for cardio, strength, flexibility)
- Sleep Stage Distribution (bars for Deep, Core, REM, Awake)

---

### 6. Stacked Bar Chart
**Use Case:** Part-to-whole relationships over time

**Visual Elements:**
- Bars divided into colored segments
- Each segment represents a category
- Segments stack to show total
- Legend for color coding
- Hover shows individual segment values

**Examples:**
- Sleep Stages per Night (Deep + Core + REM + Awake)
- Macronutrient Distribution (Protein + Carbs + Fat)
- Daily Activity Breakdown (Active + Light + Sedentary)

---

### 7. Gauge/Radial Chart
**Use Case:** Performance against a scale with visual urgency

**Visual Elements:**
- Semi-circle or full-circle gauge
- Needle/pointer showing current value
- Color zones (red/yellow/green)
- Target marker
- Percentage or score in center

**Examples:**
- Your Sleep This Week: 85/100
- Overall Health Score: 7.8/10
- Adherence Rate: 92%

---

### 8. Heatmap
**Use Case:** Patterns across two dimensions (time + category)

**Visual Elements:**
- Grid of colored cells
- Rows = Categories (e.g., days of week)
- Columns = Time periods (e.g., hours of day)
- Color intensity = value magnitude
- Hover shows exact values

**Examples:**
- Meal Timing Pattern (days × hours grid)
- Sleep Schedule Consistency (weeks × days grid)
- Exercise Frequency (months × workout types grid)

---

### 9. Streak Counter
**Use Case:** Consecutive days meeting a goal

**Visual Elements:**
- Large number (current streak)
- Flame or check icon
- "days" label
- Best streak comparison
- Calendar dots showing history

**Examples:**
- Meditation Streak: 12 days 🔥
- No Alcohol: 45 days ✓
- Morning Light: 7 days ☀️

---

### 10. Comparison View
**Use Case:** Before/after or current vs target

**Visual Elements:**
- Two values side-by-side
- Difference calculation (± change)
- Percentage change
- Visual indicator (arrow, bar comparison)
- Time period labels

**Examples:**
- This Week vs Last Week: 185 min → 220 min (+19%)
- Current vs Target Weight: 175 lbs vs 165 lbs (-10 lbs needed)
- Morning vs Evening HRV: 65 ms vs 58 ms

---

## Chart Selection Guide

**Choose based on:**

1. **Data Type:**
   - Single value → Current Value, Gauge
   - Time series → Trend Line, Bar Chart
   - Categories → Horizontal Bar, Heatmap
   - Part-to-whole → Stacked Bar, Gauge

2. **User Goal:**
   - Track progress → Progress Bar, Streak Counter
   - Spot patterns → Trend Line, Heatmap
   - Compare periods → Comparison View, Bar Chart
   - Understand composition → Stacked Bar

3. **Time Frame:**
   - Real-time/today → Current Value, Progress Bar
   - Week view → Bar Chart (7 bars)
   - Month view → Trend Line, Heatmap
   - Long-term → Trend Line, Comparison View

---

# Time Windows and Aggregation

## Swift Charts Display Conventions

### Weekly View
- **Bars:** 7 bars (one per day)
- **Time Window:** Rolling 7 days or calendar week
- **Use Case:** See daily patterns and weekly trends

### Monthly View
- **Bars:** 28-31 bars (one per day) OR 4-5 bars (one per week)
- **Time Window:** Rolling 30 days or calendar month
- **Use Case:** Identify monthly patterns and consistency

### 6-Month View
- **Bars:** 26 bars (one per week)
- **Time Window:** Rolling 26 weeks (182 days)
- **Use Case:** Long-term trends and seasonal patterns

### Custom Range
- **Bars:** Variable based on range and granularity
- **Time Window:** User-specified start and end dates
- **Use Case:** Compare specific periods (vacation, diet change, etc.)

---

## Aggregation Windows

### Not Just Display Quirks
These time windows are actual data aggregation windows used for calculations, not just visual preferences.

### Window Definitions

**Daily Window:**
- From midnight to 11:59 PM
- Used for: Daily totals, daily averages
- Calculation: `WHERE date = CURRENT_DATE`

**Weekly Window:**
- 7 consecutive days
- Options: Calendar week (Sun-Sat) or Rolling 7 days
- Used for: Weekly totals, weekly consistency scores
- Calculation: `WHERE date >= CURRENT_DATE - 6`

**Monthly Window:**
- 30 consecutive days OR calendar month
- Used for: Monthly averages, monthly compliance rates
- Calculation: `WHERE date >= CURRENT_DATE - 29`

**6-Month Window:**
- 26 weeks = 182 days
- Used for: Long-term trends, habit establishment
- Calculation: `WHERE date >= CURRENT_DATE - 181`

---

## Supported Window Field in Database

### Example Structure
```json
{
  "aggregation_metric_id": "AGG_021",
  "metric_name": "avg_weekly_sleep",
  "calculation_method": "AVG",
  "supported_windows": ["daily", "weekly", "monthly", "6_month"],
  "default_window": "weekly",
  "chart_type": "trend_line"
}
```

### Implementation Notes
- Store `supported_windows` as array or JSONB
- Keep window definitions in application code (not database)
- Use PostgreSQL ENUM for window types if preferred
- Allow multiple windows per metric for flexible display

---

## Sample Data Structures

### Sleep Data Example
```json
{
  "date": "2025-10-19",
  "total_sleep_minutes": 432,
  "bedtime": "2025-10-19T22:30:00Z",
  "wake_time": "2025-10-20T06:42:00Z",
  "stages": {
    "deep": 98,
    "core": 215,
    "rem": 89,
    "awake": 30
  },
  "efficiency": 0.93
}
```

### Activity Data Example
```json
{
  "date": "2025-10-19",
  "step_count": 9847,
  "active_minutes": 52,
  "workouts": [
    {
      "type": "strength_training",
      "duration_minutes": 35,
      "start_time": "2025-10-19T07:00:00Z"
    }
  ]
}
```

### Nutrition Data Example
```json
{
  "date": "2025-10-19",
  "meals": [
    {
      "type": "breakfast",
      "time": "2025-10-19T07:30:00Z",
      "size": "medium"
    },
    {
      "type": "lunch",
      "time": "2025-10-19T13:00:00Z",
      "size": "large"
    },
    {
      "type": "dinner",
      "time": "2025-10-19T19:15:00Z",
      "size": "medium"
    }
  ],
  "eating_window_hours": 11.75,
  "first_meal_time": "2025-10-19T07:30:00Z",
  "last_meal_time": "2025-10-19T19:15:00Z"
}
```

---

## Common Pitfalls to Avoid

### 1. Fixed Time Ranges
❌ **Don't:** Use fixed axis ranges like 8 PM to 8 AM for all users
✅ **Do:** Calculate axis dynamically based on actual data

### 2. Wrong Bar Orientation
❌ **Don't:** Make Week Stages view bars bottom-to-top
✅ **Do:** Stack top-to-bottom (bedtime at top, wake at bottom)

### 3. Missing Selection State
❌ **Don't:** Only show stacked bars in Amounts view
✅ **Do:** Support both default stacked and single-stage selection

### 4. Hardcoded Time Windows
❌ **Don't:** Hardcode "last 7 days" in formulas
✅ **Do:** Make analysis period configurable

### 5. Ignoring Outliers
❌ **Don't:** Always use AVG for all metrics
✅ **Do:** Use MEDIAN when outliers are expected

### 6. Overcomplicated Consistency Scores
❌ **Don't:** Apply arbitrary thresholds and percentage conversions
✅ **Do:** Use simple standard deviation in interpretable units

---

## Testing Checklist

### Sleep Charts
- [ ] Day view horizontal timeline works correctly
- [ ] Week view vertical bars stack top-to-bottom
- [ ] Amounts view supports both stacked and single-stage modes
- [ ] Selected stage moves to bottom in longer views
- [ ] Dynamic time axis calculation based on data
- [ ] All stage colors match Apple Health palette
- [ ] Summary metrics calculate accurately
- [ ] Smooth transitions between time periods
- [ ] Touch/click interactions responsive
- [ ] Charts resize properly on different screens

### Calculations
- [ ] SUM totals match expected values
- [ ] AVG accounts for null/missing values
- [ ] STDEV calculations use proper sample vs population formula
- [ ] Consistency scores return values in correct units
- [ ] MIN/MAX handle edge cases (all same value, single value)
- [ ] Time-based calculations handle timezone correctly
- [ ] Analysis period parameter works for all time windows
- [ ] Minimum data requirements enforced

### Chart Displays
- [ ] Current value displays update in real-time
- [ ] Progress bars show accurate percentages
- [ ] Trend lines render smoothly without gaps
- [ ] Bar charts handle varying data lengths
- [ ] Stacked bars total correctly
- [ ] Gauges indicate correct zones
- [ ] Heatmaps show proper color gradients
- [ ] Streak counters reset appropriately
- [ ] Comparison views calculate differences correctly
- [ ] All charts have proper labels and legends

---

## Additional Resources

### Related Documentation
- [WellPath Health Impact Scoring System](/mnt/project/WellPath_Health_Impact_Scoring_System_-_Development_Documentation.md)
- [Complete HealthKit Reference](/mnt/project/Complete_HealthKit_Reference_for_WellPath.md)
- [WellPath Combined Scoring Methodology](/mnt/project/WellPath_Combined_Scoring_Methodology.md)
- [Comprehensive Check-in to Recommendation Mapping](/mnt/project/Comprehensive_Check-in_to_Recommendation_Mapping.md)

### External References
- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [Swift Charts Documentation](https://developer.apple.com/documentation/charts)
- [D3.js Documentation](https://d3js.org/) (for web visualizations)
- [Chart.js Documentation](https://www.chartjs.org/) (for web visualizations)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | October 20, 2025 | Initial compilation from conversations |

---

**Document Purpose:** This reference guide consolidates chart design patterns, calculation methodologies, and visualization standards from multiple WellPath development conversations. It serves as the authoritative source for implementing data visualizations and analytical calculations across the WellPath platform.

**Maintenance:** Update this document when new chart types are added, calculation methods are refined, or design patterns are updated based on user testing and feedback.
