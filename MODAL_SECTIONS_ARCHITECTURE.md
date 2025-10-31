

# Modal Sections Architecture - Apple Health Pattern

**Date**: 2025-10-23
**Status**: Fully Implemented ✅

---

## UX Flow

Based on Apple Health Sleep screen pattern:

```
Display Screen (e.g., "Nutrition")
  ↓
Parent Metric Card
  - Main chart (e.g., Protein bar chart)
  - Unit toggle (Servings ↔ Grams)
  - Summary stats ("3.5 servings today")
  - [Show More] button
  - About section (what, why, tips)
  ↓
Tap [Show More] → Opens MODAL with Sections/Tabs
  ↓
Section Tabs (horizontal pagination)
  - Tab 1: "Timing" (Breakfast, Lunch, Dinner charts)
  - Tab 2: "Type" (Plant-based %, Processed, etc.)
  - Tab 3: "Variety" (Distribution of sources)
```

---

## Database Structure

### New Hierarchy

```
display_screens
  ↓
parent_display_metrics (the card on screen)
  ↓
parent_detail_sections (tabs in "Show More" modal)
  ↓
child_display_metrics (charts within each tab)
```

### Tables

**`parent_display_metrics`** - The card shown on screen
- `parent_metric_id` - Identifier
- `parent_name` - "Protein Intake"
- Main chart configuration
- Unit toggle support
- About section content

**`parent_detail_sections`** - Tabs in modal
- `section_id` - Identifier
- `parent_metric_id` - FK to parent
- `section_name` - "Timing", "Type", "Variety"
- `section_icon` - Icon for tab
- `display_order` - Tab order
- `section_layout` - How children display
- `is_default_tab` - Opens by default

**`child_display_metrics`** - Charts in tabs
- `child_metric_id` - Identifier
- `parent_metric_id` - FK to parent
- `section_id` - FK to section (NEW!)
- `child_name` - "Breakfast", "Plant-Based %"
- Chart configuration
- Display order within section

---

## Protein Example

### Parent Card (On Screen)

**Visual**:
```
┌────────────────────────────────────────┐
│  Protein Intake                        │
│  ═══════════════════                   │
│  [● Servings | Grams]   ← Toggle      │
│                                        │
│  Current: 3.5 servings                 │
│  ╔═══════════════════════════════════╗ │
│  ║  [Bar Chart: Last 7 Days]         ║ │
│  ╚═══════════════════════════════════╝ │
│                                        │
│  [Show More]                           │
│                                        │
│  About Protein                         │
│  ─────────────                         │
│  Protein is essential for...           │
│                                        │
│  Why It Matters                        │
│  Building muscle, repairing...         │
│                                        │
│  Quick Tips                            │
│  • Aim for 0.8g per kg body weight    │
│  • Spread intake across meals          │
└────────────────────────────────────────┘
```

### Modal Sections (After Tapping "Show More")

**Visual**:
```
┌────────────────────────────────────────┐
│  Protein Intake                     [X]│
│  ═══════════════════                   │
│  [Timing] [Type] [Variety]  ← Tabs    │
│  ════════                              │
│                                        │
│  Breakfast                             │
│  ╔═══════════════════════════════════╗ │
│  ║  [Chart: 1.5 servings]            ║ │
│  ╚═══════════════════════════════════╝ │
│                                        │
│  Lunch                                 │
│  ╔═══════════════════════════════════╗ │
│  ║  [Chart: 1.0 servings]            ║ │
│  ╚═══════════════════════════════════╝ │
│                                        │
│  Dinner                                │
│  ╔═══════════════════════════════════╗ │
│  ║  [Chart: 2.0 servings]            ║ │
│  ╚═══════════════════════════════════╝ │
└────────────────────────────────────────┘
```

Swipe to "Type" tab:
```
┌────────────────────────────────────────┐
│  Protein Intake                     [X]│
│  ═══════════════════                   │
│  [Timing] [Type] [Variety]             │
│        ════════                        │
│                                        │
│  Plant-Based Percentage                │
│  ╔═══════════════════════════════════╗ │
│  ║  [Chart: 40%]                     ║ │
│  ╚═══════════════════════════════════╝ │
│                                        │
│  Plant-Based Grams                     │
│  ╔═══════════════════════════════════╗ │
│  ║  [Chart: 48g]                     ║ │
│  ╚═══════════════════════════════════╝ │
└────────────────────────────────────────┘
```

---

## Database Queries

### Get Parent for Screen

```sql
SELECT
  parent_metric_id,
  parent_name,
  parent_description,
  supported_units,
  default_unit,
  expand_by_default,
  summary_display_mode
FROM parent_display_metrics
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS';
```

### Get Modal Sections (Tabs)

```sql
SELECT
  section_id,
  section_name,
  section_description,
  section_icon,
  display_order,
  section_layout,
  is_default_tab
FROM parent_detail_sections
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND is_active = true
ORDER BY display_order;
```

**Result**:
```
section_id               | section_name | display_order | is_default_tab
-------------------------|--------------|---------------|---------------
SECTION_PROTEIN_TIMING   | Timing       | 1             | true
SECTION_PROTEIN_TYPE     | Type         | 2             | false
SECTION_PROTEIN_VARIETY  | Variety      | 3             | false
```

### Get Children for a Section

```sql
SELECT
  child_metric_id,
  child_name,
  child_description,
  supported_units,
  default_unit,
  inherit_parent_unit,
  display_order_in_parent
FROM child_display_metrics
WHERE section_id = 'SECTION_PROTEIN_TIMING'
  AND is_active = true
ORDER BY display_order_in_parent;
```

**Result** (Timing tab):
```
child_metric_id      | child_name          | inherit_parent_unit
---------------------|---------------------|--------------------
DISP_PROTEIN_BREAKFAST | Protein: Breakfast  | true
DISP_PROTEIN_LUNCH     | Protein: Lunch      | true
DISP_PROTEIN_DINNER    | Protein: Dinner     | true
```

### Get Children Not in Any Section

Some children don't belong in modal (e.g., alternative units like g/kg):

```sql
SELECT
  child_metric_id,
  child_name
FROM child_display_metrics
WHERE parent_metric_id = 'DISP_PROTEIN_SERVINGS'
  AND section_id IS NULL
  AND is_active = true;
```

**Result**:
```
child_metric_id                     | child_name
------------------------------------|----------------------------------
DISP_PROTEIN_PER_KILOGRAM_BODY_WEIGHT | Protein per Kilogram Body Weight
```

These show as alternative data points on the parent card (not in modal).

---

## Section Layouts

The `section_layout` column determines how children are displayed in that section:

**`vertical_stack`** (default):
- Children stacked vertically
- Each gets full width
- Good for: Meal breakdowns, stage breakdowns

**`grid_2col`**:
- 2 column grid
- Good for: Type comparisons, binary metrics

**`grid_3col`**:
- 3 column grid
- Good for: Multiple small metrics

**`comparison`**:
- Side-by-side comparison view
- Good for: Before/after, goal vs actual

**`timeline`**:
- Chronological/time-based layout
- Good for: Historical trends

---

## Protein Sections Configured

### Section 1: Timing (Default Tab)
- **Layout**: `vertical_stack`
- **Children**:
  - Breakfast (chart)
  - Lunch (chart)
  - Dinner (chart)
- **Purpose**: Show when protein is consumed

### Section 2: Type
- **Layout**: `vertical_stack`
- **Children**:
  - Plant-Based Percentage (chart)
  - Plant-Based Grams (chart)
- **Purpose**: Show protein source types

### Section 3: Variety
- **Layout**: `vertical_stack`
- **Children**:
  - Protein Variety (count/distribution chart)
- **Purpose**: Show diversity of protein sources

---

## Other Parents with Sections

### Fiber (DISP_FIBER_SERVINGS)
- **Timing**: Breakfast, Lunch, Dinner
- **Sources**: Source types
- **Variety**: Source variety metrics

### Sleep (DISP_TOTAL_SLEEP_DURATION)
- **Stages**: Deep, REM, Core, Awake (durations + percentages)
- **Quality**: Efficiency, latency, episode counts

---

## Mobile Implementation

### Loading Flow

1. **Screen loads** → Show parent card
2. **User taps "Show More"** → Query sections
3. **Modal opens** → Show default tab first
4. **User swipes** → Load next tab's children

### Code Example (Swift)

```swift
// 1. Load parent
let parent = await fetchParent("DISP_PROTEIN_SERVINGS")

// 2. Show parent card with main chart
renderParentCard(parent)

// 3. User taps "Show More"
func onShowMoreTapped() {
  let sections = await fetchSections(parentId: parent.id)
  let defaultSection = sections.first(where: { $0.isDefaultTab }) ?? sections[0]

  // 4. Load first tab's children
  let children = await fetchChildrenForSection(sectionId: defaultSection.id)

  // 5. Show modal with tabs
  presentModal(sections: sections, selectedSection: defaultSection, children: children)
}

// 6. User swipes to next tab
func onTabChanged(newSection: Section) {
  let children = await fetchChildrenForSection(sectionId: newSection.id)
  renderChildren(children, layout: newSection.layout)
}
```

---

## Key Differences from Previous Design

### Before (Child Categories)
```
Parent
  └─ Children with categories
     ├─ Meals (flat list)
     ├─ Variety (flat list)
     └─ Plant-Based (flat list)
```
**Problem**: All children shown at once, no pagination

### After (Sections/Tabs)
```
Parent Card (on screen)
  └─ Show More → Modal with Sections
     ├─ Tab 1: Timing (paginated)
     ├─ Tab 2: Type (paginated)
     └─ Tab 3: Variety (paginated)
```
**Benefit**: Organized, paginated, Apple Health pattern

---

## About Section on Parent Card

The about section stays on the parent card (NOT in modal):

**Content Structure**:
- **What**: Brief description of the metric
- **Why It Matters**: Health importance
- **Optimal Target**: Goal ranges
- **Quick Tips**: Actionable advice

**Source**: Can be stored in `parent_display_metrics` or separate `parent_about_content` table.

**Example** (Protein):
```markdown
## About Protein

**What**
Protein is a macronutrient essential for building and repairing tissues,
making enzymes and hormones, and supporting immune function.

**Why It Matters**
Adequate protein intake supports muscle maintenance, healthy aging,
satiety, and metabolic health.

**Optimal Target**
0.8-1.2g per kg body weight daily. Athletes may need 1.6-2.2g/kg.

**Quick Tips**
• Spread protein across meals for better absorption
• Include variety: animal and plant sources
• Pair with strength training for muscle growth
```

---

## Next Steps for Mobile

1. ✅ Query parent metrics for screen
2. ✅ Render parent card with main chart
3. ✅ Add "Show More" button
4. ✅ Add About section below chart
5. ⬜ Query sections when "Show More" tapped
6. ⬜ Render modal with horizontal tab pagination
7. ⬜ Query children for active tab
8. ⬜ Render children using section_layout
9. ⬜ Support tab swiping/pagination
10. ⬜ Close modal returns to parent card

---

## Summary

**Parent Card** (Always Visible):
- Main chart
- Toggle
- Summary
- [Show More] button
- About section

**Modal** (On Demand):
- Horizontal tabs (sections)
- Children charts within each tab
- Swipeable pagination
- [X] close button

**Benefits**:
- Cleaner parent screen (one chart + about)
- Organized drill-down (sections/tabs)
- Matches familiar Apple Health pattern
- Scalable (can add sections without cluttering parent)

🎉 **Ready for mobile implementation!**
