# Apple Health Sleep Charts - Complete Action Plan

## Overview
This document provides a comprehensive guide to recreating Apple Health's sleep visualization charts based on actual screenshots and user behavior patterns.

---

## THERE ARE 2 MAIN CHART TYPES

### 1. STAGES VIEW
### 2. AMOUNTS VIEW

Each view has multiple time period options: Day (D), Week (W), Month (M), 6 Months (6M)

---

## CHART TYPE 1: STAGES VIEW

### Day View (Image 1) - HORIZONTAL TIMELINE

**Chart Type:** Horizontal timeline chart (like a Gantt chart)

**Key Characteristics:**
- X-axis = TIME (dynamically calculated, e.g., 8 PM, 11 PM, 2 AM, 5 AM)
- Y-axis = Stage labels (Awake, REM, Core, Deep)
- Sleep stages shown as **horizontal segments flowing LEFT TO RIGHT** across time
- Shows WHEN each stage occurred during the night
- Reads like a timeline: time progresses from left to right

**Colors:**
- Awake: `#ff6b6b` (coral/salmon)
- REM: `#4ecdc4` (light cyan)
- Core: `#3b8fd9` (medium blue)
- Deep: `#2d5f8a` (dark blue/navy)

**Data Structure:**
```javascript
const dayData = [
  { startTime: "22:00", endTime: "22:45", stage: "awake" },
  { startTime: "22:45", endTime: "23:30", stage: "core" },
  { startTime: "23:30", endTime: "01:00", stage: "deep" },
  { startTime: "01:00", endTime: "02:30", stage: "rem" },
  // etc - segments with start and end times
]
```

**Implementation Notes:**
- Think Gantt chart or horizontal stacked area chart
- Each segment spans from startTime to endTime horizontally
- Vertical position determined by stage type
- X-axis range is dynamically calculated (see Dynamic Time Axis section)

---

### Week View (Image 2) - VERTICAL BARS (TOP TO BOTTOM)

**Chart Type:** Vertical bar chart where bars represent time progression

**CRITICAL UNDERSTANDING:**
- Each bar represents ONE FULL NIGHT rolled up
- Bars are stacked **TOP TO BOTTOM** (NOT bottom to top!)
- Top of bar = bedtime (earlier in night)
- Bottom of bar = wake time (later in night)
- Y-axis shows time scale with **8 PM at TOP, 10 AM at BOTTOM** (inverted axis)
- Reading order: Start at top (bedtime) and read DOWN to bottom (wake time)

**Key Characteristics:**
- Shows 7 vertical bars (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
- Y-axis on RIGHT side shows time scale (inverted: early evening at top, morning at bottom)
- X-axis shows days of the week
- Stages flow from top down: Awake segments, then sleep cycles of Core/REM/Deep, ending with morning Awake
- All 7 bars share the same dynamically calculated Y-axis

**Data Structure:**
```javascript
const weekData = [
  {
    day: "Mon",
    bedtime: "22:00",      // Top of bar
    wakeTime: "07:00",     // Bottom of bar
    segments: [            // Order matters - top to bottom chronologically
      { stage: "awake", minutes: 15 },
      { stage: "core", minutes: 60 },
      { stage: "deep", minutes: 45 },
      { stage: "rem", minutes: 30 },
      { stage: "core", minutes: 90 },
      { stage: "deep", minutes: 60 },
      { stage: "rem", minutes: 45 },
      { stage: "core", minutes: 75 },
      { stage: "awake", minutes: 20 }
    ]
  },
  // ... 6 more days
]
```

**Visual Positioning:**
```
               Mon   Tue   Wed   Thu   Fri   Sat   Sun
9 PM    ←top   |     |     |     |     |     |     |
10 PM          █     |     |     █     █     |     |
11 PM          █     █     |     █     █     █     |
12 AM          █     █     |     █     █     █     █
1 AM           █     █     █     █     █     █     █
2 AM           █     █     █     █     █     █     █
3 AM           █     █     █     █     █     █     █
4 AM           █     █     █     █     █     █     █
5 AM           █     █     █     █     █     █     █
6 AM           █     █     █     █     █     █     █
7 AM           |     █     █     |     |     █     █
8 AM           |     |     █     |     |     |     █
9 AM    ←bottom|     |     |     |     |     |     |
```

**Implementation Notes:**
- This is NOT a standard bar chart where height = value
- It's a TIME-based visualization where vertical position = time of night
- Y-axis is inverted (higher times = higher on screen)
- Each bar is positioned vertically based on bedtime/wake time within the dynamic axis range
- Stack segments from TOP TO BOTTOM in chronological order

---

### Month/6M View

Same concept as Week view but with more bars compressed horizontally:
- Month = ~30 bars (one per day)
- 6M = ~180 bars aggregated (possibly showing weekly averages or selective days)
- Each bar still represents one night's full sleep summary
- Same top-to-bottom stacking logic

---

## CHART TYPE 2: AMOUNTS VIEW

### Day View (Image 3) - STAGE DURATION BARS

**Default State (No Selection):**
- Standard **stacked vertical bar chart** 
- Shows total sleep composition
- 4 segments stacked bottom to top: Deep, Core, REM, Awake
- Y-axis shows hours (0-10 hr scale)
- Single bar showing full night breakdown

**Selected State (Stage Tapped):**
- Chart changes to show **4 separate bars**: Awake, REM, Core, Deep
- All bars show duration of the SELECTED stage only
- All bars use the selected stage's color
- Shows how much of that stage occurred in each category/time period
- Selected stage highlighted in percentages section below (coral background)

**Data Structure:**
```javascript
// Default view
const amountsDay = {
  deep: 115,    // minutes
  core: 245,
  rem: 88,
  awake: 30
}

// Selected view (e.g., "awake" selected)
const amountsDaySelected = {
  stage: "awake",
  breakdown: [
    { category: "Awake", duration: 30 },
    { category: "REM", duration: 0 },
    { category: "Core", duration: 0 },
    { category: "Deep", duration: 0 }
  ]
}
```

---

### Week View (Image 4) - DAILY DURATION BARS

**Default State (No Selection):**
- Shows 7 **stacked vertical bars** (Mon-Sun)
- Each bar stacked bottom to top: Deep, Core, REM, Awake
- Y-axis shows hours (0-12 hr scale)
- Shows total sleep composition per night
- Standard stacked bar chart

**Selected State (Stage Tapped):**
- Shows 7 **solid color bars** (Mon-Sun)
- Each bar shows ONLY the selected stage's duration for that night
- All bars are the same color (selected stage's color)
- Example: If "Awake" is selected, shows awake time per night across the week
- Y-axis shows hours (0-3 hr typical for awake time)

**CRITICAL INTERACTION PATTERN:**
When a stage is selected in the percentages section:
1. The selected row gets highlighted background (coral/salmon color)
2. Chart immediately updates to show only that stage
3. All bars become uniform color of selected stage
4. Chart effectively becomes a "filtered view" showing one metric across time

**Data Structure:**
```javascript
// Default view
const amountsWeek = [
  { 
    day: "Mon",
    stages: { deep: 115, core: 245, rem: 88, awake: 30 }
  },
  // ... 6 more days
]

// Selected view (e.g., "awake" selected)
const amountsWeekSelected = {
  stage: "awake",
  data: [
    { day: "Mon", duration: 30 },
    { day: "Tue", duration: 45 },
    { day: "Wed", duration: 20 },
    // ... etc
  ]
}
```

---

### Month/6M View - Selected Stage Emphasis

**CRITICAL FEATURE:**
For longer time views (Month, 6 Months), when viewing as stacked bars with a stage selected:
- The selected stage is ALWAYS positioned at the BOTTOM of the stack
- This makes it easier to see trends in that specific stage
- Other stages stack above it in their normal order
- Without this, it's just a standard stacked bar chart

**Example:**
```
Default order (bottom to top): Deep, Core, REM, Awake

If "REM" is selected:
New order (bottom to top): REM, Deep, Core, Awake
                           ^^^^ selected stage moved to bottom

If "Awake" is selected:
Order stays: Deep, Core, REM, Awake (already at top, but...)
Actually shows: Awake, Deep, Core, REM (moved to bottom)
```

**Why This Matters:**
- When a stage is in the middle of a stack, it's hard to see trends
- By moving selected stage to bottom, it gets a flat baseline
- Makes it much easier to track that specific metric over time
- Week view doesn't need this because it shows filtered single-stage bars

---

## DYNAMIC TIME AXIS CALCULATION

**CRITICAL:** The time axis is NOT fixed to 8 PM - 10 AM. It's dynamically calculated from actual sleep data.

### Calculation Logic:

```javascript
function calculateTimeAxis(data, bufferMinutes = 30) {
  // Extract all sleep times
  const bedtimes = data.map(d => parseTime(d.bedtime)) // Convert to minutes since midnight
  const wakeTimes = data.map(d => parseTime(d.wakeTime))
  
  // Handle times after midnight (e.g., 1 AM = 1440 + 60 = 1500 minutes)
  const adjustedWakeTimes = wakeTimes.map(wt => 
    wt < 720 ? wt + 1440 : wt // If before noon, add 24 hours
  )
  
  // Find range
  const minTime = Math.min(...bedtimes) - bufferMinutes
  const maxTime = Math.max(...adjustedWakeTimes) + bufferMinutes
  
  // Generate axis labels
  const axisLabels = generateTimeLabels(minTime, maxTime)
  
  return {
    min: minTime,
    max: maxTime,
    labels: axisLabels,
    range: maxTime - minTime
  }
}
```

### Examples:

**Consistent Sleeper:**
```javascript
weekData = [
  { day: "Mon", bedtime: "22:30", wakeTime: "06:45" },
  { day: "Tue", bedtime: "22:45", wakeTime: "06:30" },
  { day: "Wed", bedtime: "22:15", wakeTime: "06:50" },
  // ... all similar times
]

// Axis calculation:
// earliestBedtime = 22:15 - 30min = 21:45 (9:45 PM)
// latestWakeTime = 06:50 + 30min = 07:20 (7:20 AM)
// Y-axis displays: 9:45 PM (top) to 7:20 AM (bottom)
// Result: Tight range because sleep schedule is consistent
```

**Inconsistent Sleeper:**
```javascript
weekData = [
  { day: "Mon", bedtime: "23:30", wakeTime: "07:00" },
  { day: "Tue", bedtime: "21:00", wakeTime: "06:30" },  // Early night
  { day: "Wed", bedtime: "01:15", wakeTime: "09:45" },  // Late night
  // ... varied times
]

// Axis calculation:
// earliestBedtime = 21:00 - 30min = 20:30 (8:30 PM)
// latestWakeTime = 09:45 + 30min = 10:15 (10:15 AM)
// Y-axis displays: 8:30 PM (top) to 10:15 AM (bottom)
// Result: Wide range because sleep schedule varies significantly
```

### Bar Positioning Within Dynamic Range:

```javascript
function positionBar(bedtime, wakeTime, axisMin, axisMax, chartHeight) {
  const timeRange = axisMax - axisMin
  
  // Convert times to minutes since midnight
  const bedtimeMinutes = parseTime(bedtime)
  const wakeTimeMinutes = parseTime(wakeTime)
  const adjustedWakeTime = wakeTimeMinutes < 720 ? wakeTimeMinutes + 1440 : wakeTimeMinutes
  
  // Calculate positions as percentage of axis range
  const topPosition = ((bedtimeMinutes - axisMin) / timeRange) * chartHeight
  const bottomPosition = ((adjustedWakeTime - axisMin) / timeRange) * chartHeight
  const barHeight = bottomPosition - topPosition
  
  return {
    top: topPosition,
    height: barHeight
  }
}
```

### Application by View:

**Day View (Horizontal):**
- X-axis calculated from that single night's bedtime/wake time + buffer
- Example: Slept 10:30 PM to 7:00 AM → axis shows 10:00 PM to 7:30 AM

**Week View (Vertical):**
- Y-axis calculated across ALL 7 nights
- Find earliest bedtime across week
- Find latest wake time across week
- Add buffer to both ends
- All 7 bars share this same Y-axis scale
- Each bar positioned within range based on its specific times

**Month/6M View:**
- Same logic but across more nights
- Axis accommodates the full range of sleep times in the period

---

## COLOR PALETTE

### Sleep Stages:
- **Awake:** `#ff6b6b` or `#ff5858` (coral/salmon)
- **REM:** `#4ecdc4` or `#5fd3d3` (light cyan)
- **Core:** `#3b8fd9` or `#45a2ff` (medium blue)
- **Deep:** `#2d5f8a` or `#1a4d7a` (dark blue/navy)

### UI Elements:
- **Background:** `#1c1c1e` (dark gray, almost black)
- **Grid lines:** `#2c2c2e` (subtle gray)
- **Text primary:** `#ffffff` (white)
- **Text secondary:** `#8e8e93` (gray for labels)
- **Selection highlight:** `#ff6b6b` with reduced opacity (coral background for selected items)

---

## UI COMPONENTS

### Time Period Selector (D / W / M / 6M buttons)
- 4 rounded buttons in a row
- Selected state: lighter gray background
- Unselected state: darker gray background
- Changes the data granularity and chart type

### View Selector (Stages / Amounts / Comparisons tabs)
- 3 tab buttons below the chart
- Selected state: lighter gray background
- Switches between different chart visualizations
- "Comparisons" tab exists but implementation unclear from screenshots

### Summary Stats
- **TIME IN BED:** Shows total time from bedtime to wake time
- **TIME ASLEEP:** Shows actual sleep time (excludes awake periods)
- Displayed prominently at top with large numbers
- Format: `10 hr 7 min`

### Percentages Section
- List of sleep stages with color indicators
- Shows percentage of sleep in each stage
- Tappable rows for filtering/selection
- Selected row gets highlighted background
- Format: `● Deep    21%`

---

## DESIGN PRINCIPLES (Apple Health Style)

1. **Clean and minimal** - Lots of white space, uncluttered
2. **Rounded corners** on all chart elements, buttons, cards
3. **Subtle shadows** for depth (very soft, not harsh)
4. **Smooth animations** on data load and interactions
5. **Clear typography** - SF Pro or system font, good hierarchy
6. **Pastel colors** that aren't too bright, easy on the eyes
7. **Interactive tooltips** that appear on hover/tap
8. **Responsive design** that works on all screen sizes
9. **Dark mode** - All screenshots show dark theme
10. **Accessibility** - Clear contrast, large touch targets

---

## IMPLEMENTATION PRIORITY

### Phase 1: Core Functionality
1. ✅ Set up project structure with React + charting library
2. ✅ Create sample sleep data structure
3. ✅ Implement dynamic time axis calculation
4. ✅ Build Day Stages View (horizontal timeline)
5. ✅ Build Week Stages View (vertical bars, top-down)

### Phase 2: Amounts View
6. ✅ Build Day Amounts View (default stacked + selected state)
7. ✅ Build Week Amounts View (default stacked + selected state)
8. ✅ Implement stage selection interaction
9. ✅ Implement "selected stage to bottom" for Month/6M stacked views

### Phase 3: Polish
10. ✅ Add time period selector (D/W/M/6M)
11. ✅ Add view selector (Stages/Amounts tabs)
12. ✅ Implement smooth transitions between views
13. ✅ Add summary stats display
14. ✅ Add percentages section with selection
15. ✅ Style everything to match Apple Health aesthetic

### Phase 4: Interactions
16. ✅ Add tooltips/hover states
17. ✅ Add animations
18. ✅ Mobile responsiveness
19. ✅ Touch gesture support
20. ✅ Testing with edge cases

---

## COMMON PITFALLS TO AVOID

1. **Don't use fixed time ranges** - Always calculate dynamically from data
2. **Don't forget top-to-bottom stacking** - Week Stages view is NOT bottom-to-top
3. **Don't confuse the two chart types** - Day Stages is horizontal, Week Stages is vertical
4. **Don't overcomplicate the time axis** - Keep labels simple and readable
5. **Don't use too many colors** - Stick to the 4 stage colors only
6. **Don't ignore the selection state** - Amounts view behavior changes completely when stage selected
7. **Don't forget to reorder stack** - Selected stage goes to bottom in Month/6M stacked views
8. **Don't make touch targets too small** - Ensure mobile usability
9. **Don't skip the buffer calculation** - Charts need breathing room on time axis
10. **Don't assume bottom-to-top** - Default mental model doesn't apply to Stages view bars

---

## TESTING CHECKLIST

- [ ] Day Stages view renders as horizontal timeline
- [ ] Week Stages view renders as vertical bars (top-to-bottom)
- [ ] Time axis calculates dynamically for each dataset
- [ ] All sleep stages display with correct colors
- [ ] Time axis labels are readable and accurate
- [ ] Stages view bars stack top-to-bottom chronologically
- [ ] Amounts view shows stacked bars by default
- [ ] Tapping stage in percentages filters Amounts view
- [ ] Selected stage moves to bottom in Month/6M stacked views
- [ ] Tooltips show correct information
- [ ] Responsive on mobile, tablet, desktop
- [ ] Handles edge cases (very short sleep, no data, etc.)
- [ ] Animations are smooth, not jarring
- [ ] Matches Apple Health visual style
- [ ] Time period selector (D/W/M/6M) works correctly
- [ ] View selector (Stages/Amounts) works correctly
- [ ] Summary stats calculate correctly
- [ ] Percentages calculate correctly
- [ ] Selection highlighting works
- [ ] Dark theme matches screenshots

---

## RECOMMENDED LIBRARIES

### Charting:
- **Recharts** - Good for React, handles custom shapes well
- **D3.js** - Most flexible, steeper learning curve
- **Chart.js with react-chartjs-2** - Simple, may need custom plugins
- **Nivo** - Beautiful defaults, D3-based React components

### Utilities:
- **date-fns** or **dayjs** - Time calculations and formatting
- **Tailwind CSS** - Styling to match Apple's clean aesthetic
- **Framer Motion** - Smooth animations and transitions

### Recommendation:
Start with **Recharts** for faster development, switch to **D3.js** if you need more custom control for the horizontal timeline and top-to-bottom stacking.

---

## FINAL NOTES FOR CLAUDE CODE

### Critical Understanding Points:

1. **Image 1 is HORIZONTAL** - Time flows left to right, not top to bottom
2. **Image 2 bars are TOP-TO-BOTTOM** - Time flows from top (bedtime) to bottom (wake), NOT bottom-to-top like standard bar charts
3. **Time axis is DYNAMIC** - Not fixed, calculated from actual sleep data with buffer
4. **Week view is ROLLUP data** - Each bar = one full night aggregated, not time-of-night granularity
5. **Amounts view CHANGES with selection** - Default shows stacked bars, selected shows filtered single-stage bars
6. **Selected stage goes to BOTTOM** - In Month/6M stacked views for easier trend visualization

### Build Approach:

**DO THIS:**
- Build one chart at a time, test thoroughly before moving on
- Start with data structure and dynamic axis calculation
- Get the Day Stages horizontal timeline working first
- Then tackle Week Stages vertical (top-down) bars
- Then add Amounts views with selection logic
- Polish and animate last

**DON'T DO THIS:**
- Try to build everything at once
- Use fixed time ranges
- Assume standard chart orientations
- Skip the selection interaction logic
- Forget to handle edge cases (late bedtimes, early wake times, etc.)

---

## SAMPLE DATA FOR TESTING

```javascript
const sampleWeekData = [
  {
    date: "2025-10-06",
    day: "Mon",
    bedtime: "22:30",
    wakeTime: "06:45",
    totalSleepMinutes: 541,
    stages: {
      awake: 30,
      rem: 120,
      core: 276,
      deep: 115
    },
    timeline: [
      { start: "22:30", end: "22:45", stage: "awake" },
      { start: "22:45", end: "23:30", stage: "core" },
      { start: "23:30", end: "00:30", stage: "deep" },
      { start: "00:30", end: "01:15", stage: "rem" },
      { start: "01:15", end: "02:30", stage: "core" },
      { start: "02:30", end: "03:30", stage: "deep" },
      { start: "03:30", end: "04:15", stage: "rem" },
      { start: "04:15", end: "05:45", stage: "core" },
      { start: "05:45", end: "06:30", stage: "rem" },
      { start: "06:30", end: "06:45", stage: "awake" }
    ]
  },
  {
    date: "2025-10-07",
    day: "Tue",
    bedtime: "23:00",
    wakeTime: "07:15",
    totalSleepMinutes: 475,
    stages: {
      awake: 20,
      rem: 95,
      core: 240,
      deep: 120
    },
    timeline: [
      { start: "23:00", end: "23:15", stage: "awake" },
      { start: "23:15", end: "00:45", stage: "core" },
      { start: "00:45", end: "01:45", stage: "deep" },
      { start: "01:45", end: "02:30", stage: "rem" },
      { start: "02:30", end: "03:45", stage: "core" },
      { start: "03:45", end: "04:45", stage: "deep" },
      { start: "04:45", end: "05:30", stage: "rem" },
      { start: "05:30", end: "07:00", stage: "core" },
      { start: "07:00", end: "07:15", stage: "awake" }
    ]
  },
  // Add 5 more days with varied sleep patterns
  {
    date: "2025-10-08",
    day: "Wed",
    bedtime: "21:45",
    wakeTime: "05:30",
    totalSleepMinutes: 425,
    stages: {
      awake: 20,
      rem: 80,
      core: 220,
      deep: 105
    },
    timeline: [
      { start: "21:45", end: "22:00", stage: "awake" },
      { start: "22:00", end: "23:15", stage: "core" },
      { start: "23:15", end: "00:00", stage: "deep" },
      { start: "00:00", end: "00:40", stage: "rem" },
      { start: "00:40", end: "01:45", stage: "core" },
      { start: "01:45", end: "02:30", stage: "deep" },
      { start: "02:30", end: "03:10", stage: "rem" },
      { start: "03:10", end: "04:45", stage: "core" },
      { start: "04:45", end: "05:30", stage: "deep" }
    ]
  },
  {
    date: "2025-10-09",
    day: "Thu",
    bedtime: "22:15",
    wakeTime: "06:30",
    totalSleepMinutes: 495,
    stages: {
      awake: 15,
      rem: 110,
      core: 250,
      deep: 120
    },
    timeline: [
      { start: "22:15", end: "22:30", stage: "awake" },
      { start: "22:30", end: "23:45", stage: "core" },
      { start: "23:45", end: "00:45", stage: "deep" },
      { start: "00:45", end: "01:40", stage: "rem" },
      { start: "01:40", end: "02:50", stage: "core" },
      { start: "02:50", end: "03:50", stage: "deep" },
      { start: "03:50", end: "04:40", stage: "rem" },
      { start: "04:40", end: "06:30", stage: "core" }
    ]
  },
  {
    date: "2025-10-10",
    day: "Fri",
    bedtime: "23:30",
    wakeTime: "07:45",
    totalSleepMinutes: 480,
    stages: {
      awake: 15,
      rem: 100,
      core: 255,
      deep: 110
    },
    timeline: [
      { start: "23:30", end: "23:45", stage: "awake" },
      { start: "23:45", end: "01:00", stage: "core" },
      { start: "01:00", end: "01:50", stage: "deep" },
      { start: "01:50", end: "02:40", stage: "rem" },
      { start: "02:40", end: "04:00", stage: "core" },
      { start: "04:00", end: "05:00", stage: "deep" },
      { start: "05:00", end: "05:50", stage: "rem" },
      { start: "05:50", end: "07:45", stage: "core" }
    ]
  },
  {
    date: "2025-10-11",
    day: "Sat",
    bedtime: "00:15",
    wakeTime: "08:30",
    totalSleepMinutes: 465,
    stages: {
      awake: 30,
      rem: 95,
      core: 235,
      deep: 105
    },
    timeline: [
      { start: "00:15", end: "00:45", stage: "awake" },
      { start: "00:45", end: "02:00", stage: "core" },
      { start: "02:00", end: "02:45", stage: "deep" },
      { start: "02:45", end: "03:30", stage: "rem" },
      { start: "03:30", end: "04:30", stage: "core" },
      { start: "04:30", end: "05:30", stage: "deep" },
      { start: "05:30", end: "06:15", stage: "rem" },
      { start: "06:15", end: "08:30", stage: "core" }
    ]
  },
  {
    date: "2025-10-12",
    day: "Sun",
    bedtime: "23:45",
    wakeTime: "07:00",
    totalSleepMinutes: 405,
    stages: {
      awake: 30,
      rem: 85,
      core: 200,
      deep: 90
    },
    timeline: [
      { start: "23:45", end: "00:15", stage: "awake" },
      { start: "00:15", end: "01:15", stage: "core" },
      { start: "01:15", end: "02:00", stage: "deep" },
      { start: "02:00", end: "02:40", stage: "rem" },
      { start: "02:40", end: "03:40", stage: "core" },
      { start: "03:40", end: "04:25", stage: "deep" },
      { start: "04:25", end: "05:10", stage: "rem" },
      { start: "05:10", end: "06:45", stage: "core" },
      { start: "06:45", end: "07:00", stage: "awake" }
    ]
  }
];
```

---

## SUCCESS CRITERIA

You'll know you've succeeded when:

1. ✅ Day view shows a horizontal timeline that reads left-to-right
2. ✅ Week view shows vertical bars that read top-to-bottom
3. ✅ Time axis adjusts automatically based on sleep data
4. ✅ All sleep stages render with correct colors and proportions
5. ✅ Tapping a stage in Amounts view filters to show only that stage
6. ✅ Selected stages move to bottom of stack in longer views
7. ✅ The charts look and feel like Apple Health
8. ✅ Someone could use this to actually track their sleep patterns

---

Good luck! Build one piece at a time, test thoroughly, and don't get overwhelmed. You've got this.
