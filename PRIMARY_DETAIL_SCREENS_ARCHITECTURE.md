# Primary/Detail Screens Architecture

## ✅ Migration Complete

Successfully created a 3-tier navigation structure for the mobile app with primary (summary) and detail (drill-down) screens.

---

## Navigation Flow

```
📊 Pillar (e.g., "Healthful Nutrition")
  └─ 🏠 Display Screen (e.g., "Protein Intake")
      ├─ 📱 Primary Screen (summary view, 1-4 key metrics)
      │   └─ "View More Protein Data" button →
      └─ 📊 Detail Screen (comprehensive breakdowns)
```

---

## Database Structure

### 1. `display_screens_primary` (45 screens)

**Primary/summary view for each screen.** Shows 1-4 key metrics.

```sql
- primary_screen_id (PK): "SCREEN_PROTEIN_PRIMARY"
- display_screen_id (FK): "SCREEN_PROTEIN"
- title: "Protein Intake"
- subtitle: "Track your daily protein"
- layout_type: 'single_metric', 'multi_metric', 'grid', 'featured'
- primary_metric_id: ID of the "hero" metric to feature
- has_detail_screen: true
- detail_button_text: "View More Protein Data"
- quick_tips: [{"tip": "Aim for 25-30g per meal", "icon": "lightbulb"}]
- goal_config: {"type": "daily_target", "value": 100, "unit": "grams"}
- metadata: {} (flexible JSON for future features)
```

**Example Primary Screens:**
- `SCREEN_PROTEIN_PRIMARY`: Shows DISP_PROTEIN_GRAMS (main chart)
- `SCREEN_SLEEP_PRIMARY`: Shows DISP_SLEEP_ANALYSIS (sleep stages)
- `SCREEN_STEPS_PRIMARY`: Shows DISP_STEPS (daily steps)

### 2. `display_screens_detail` (45 screens)

**Detail/drill-down view.** Accessed via "View More" button. Shows comprehensive breakdowns.

```sql
- detail_screen_id (PK): "SCREEN_PROTEIN_DETAIL"
- display_screen_id (FK): "SCREEN_PROTEIN"
- title: "Protein Details"
- layout_type: 'tabs', 'sections', 'list', 'grid'
- section_config: [{"section_id": "by_meal", "title": "By Meal", "metrics": [...]"}]
- tab_config: [{"tab_id": "timing", "title": "Timing", "icon": "clock"}]
- detailed_info: [{"section": "Benefits", "content": "..."}]
- faq: [{"question": "...", "answer": "..."}]
- related_articles: [{"title": "...", "url": "..."}]
- metadata: {}
```

**Example Detail Screens:**
- `SCREEN_PROTEIN_DETAIL`: Shows meal timing, protein types, sources breakdown
- `SCREEN_SLEEP_DETAIL`: Shows efficiency, cycles, consistency trends
- `SCREEN_STEPS_DETAIL`: Shows hourly breakdown, activity patterns

### 3. `display_metrics` (Updated)

Metrics now FK to **either** primary **or** detail (enforced by check constraint).

```sql
- metric_id (PK)
- metric_name
- chart_type_id (FK): Which chart Swift should render
- primary_screen_id (FK): If on primary screen
- detail_screen_id (FK): If on detail screen
```

**Check Constraint:**
```sql
CHECK (
  (primary_screen_id IS NOT NULL AND detail_screen_id IS NULL) OR
  (primary_screen_id IS NULL AND detail_screen_id IS NOT NULL)
)
```

---

## Metrics Distribution

### Assignment Strategy

**PRIMARY SCREENS** (summary metrics):
- Main aggregations: `*_GRAMS`, `*_DURATION`, `*_SESSIONS`
- Key metrics: `DISP_SLEEP_ANALYSIS`, `DISP_PROTEIN_GRAMS`
- Overview metrics: `*_CONSISTENCY`, `*_EFFICIENCY`

**DETAIL SCREENS** (breakdowns):
- Timing breakdowns: `*_MEAL_TIMING`, `*_TIMING`
- Type breakdowns: `*_BY_TYPE`, `*_BY_SOURCE`
- Percentages: `*_PCT`
- Detailed cycles: `*_CYCLES`, `*_EPISODES`

### Example: Protein Screen

**Primary Screen** (`SCREEN_PROTEIN_PRIMARY`):
- DISP_PROTEIN_GRAMS (featured chart)
- DISP_PROTEIN_PER_KG (stat)
- DISP_PLANT_PROTEIN_PCT (stat)

**Detail Screen** (`SCREEN_PROTEIN_DETAIL` with tabs):
- **Tab 1: Timing**
  - DISP_PROTEIN_MEAL_TIMING (breakfast/lunch/dinner breakdown)
- **Tab 2: Sources**
  - DISP_PLANT_PROTEIN_GRAMS
  - DISP_PROTEIN_VARIETY

### Example: Sleep Screen

**Primary Screen** (`SCREEN_SLEEP_PRIMARY`):
- DISP_SLEEP_ANALYSIS (horizontal stacked bar: Deep/Core/REM/Awake)

**Detail Screen** (`SCREEN_SLEEP_DETAIL` with sections):
- **Section 1: Quality**
  - DISP_SLEEP_EFFICIENCY
  - DISP_DEEP_CYCLES
  - DISP_REM_CYCLES
- **Section 2: Consistency**
  - DISP_SLEEP_TIME_CONSISTENCY
  - DISP_WAKE_TIME_CONSISTENCY
- **Section 3: Timing**
  - DISP_TIME_IN_BED
  - DISP_LAST_DRINK_TIME

---

## Swift Implementation

### Primary Screen View

```swift
struct PrimaryScreenView: View {
    let screen: DisplayScreen
    @StateObject var viewModel: PrimaryScreenViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Hero metric
                if let heroMetric = viewModel.primaryMetrics.first {
                    MetricChartView(metric: heroMetric, large: true)
                }

                // Additional metrics
                ForEach(viewModel.primaryMetrics.dropFirst()) { metric in
                    MetricChartView(metric: metric, large: false)
                }

                // Quick tips
                if !viewModel.quickTips.isEmpty {
                    QuickTipsSection(tips: viewModel.quickTips)
                }

                // View more button
                if viewModel.hasDetailScreen {
                    Button(action: { showDetail = true }) {
                        Text(viewModel.detailButtonText)
                        Image(systemName: "chevron.right")
                    }
                }
            }
        }
        .sheet(isPresented: $showDetail) {
            DetailScreenView(screen: screen)
        }
    }
}
```

### Detail Screen View

```swift
struct DetailScreenView: View {
    let screen: DisplayScreen
    @StateObject var viewModel: DetailScreenViewModel

    var body: some View {
        NavigationView {
            Group {
                switch viewModel.layoutType {
                case "tabs":
                    TabView {
                        ForEach(viewModel.tabs) { tab in
                            DetailTabView(tab: tab, metrics: viewModel.metrics(for: tab))
                                .tabItem {
                                    Label(tab.title, systemImage: tab.icon)
                                }
                        }
                    }

                case "sections":
                    ScrollView {
                        ForEach(viewModel.sections) { section in
                            SectionView(section: section, metrics: viewModel.metrics(for: section))
                        }
                    }

                default:
                    MetricListView(metrics: viewModel.detailMetrics)
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
```

### Query Pattern

```swift
// 1. Get primary screen
let primaryScreen = try await supabase
    .from("display_screens_primary")
    .select("*, display_screens(*)")
    .eq("display_screen_id", value: "SCREEN_PROTEIN")
    .single()

// 2. Get metrics for primary screen
let primaryMetrics = try await supabase
    .from("display_metrics")
    .select("*")
    .eq("primary_screen_id", value: primaryScreen.primaryScreenId)

// 3. When user taps "View More"
let detailScreen = try await supabase
    .from("display_screens_detail")
    .select("*")
    .eq("display_screen_id", value: "SCREEN_PROTEIN")
    .single()

// 4. Get metrics for detail screen
let detailMetrics = try await supabase
    .from("display_metrics")
    .select("*")
    .eq("detail_screen_id", value: detailScreen.detailScreenId)
```

---

## Metadata & Education Content

### Quick Tips (Primary Screen)

```json
{
  "quick_tips": [
    {
      "tip": "Aim for 25-30g of protein per meal",
      "icon": "lightbulb",
      "type": "recommendation"
    },
    {
      "tip": "Protein intake is on track for your goals",
      "icon": "checkmark.circle",
      "type": "status"
    }
  ]
}
```

### Detailed Info (Detail Screen)

```json
{
  "detailed_info": [
    {
      "section": "Why It Matters",
      "content": "Protein is essential for muscle repair, immune function, and satiety...",
      "image_url": "https://...",
      "links": [
        {"title": "Learn More", "url": "..."}
      ]
    },
    {
      "section": "Optimal Timing",
      "content": "Distribute protein evenly across meals for better muscle protein synthesis...",
      "chart_type": "bar_comparison"
    }
  ]
}
```

### FAQ

```json
{
  "faq": [
    {
      "question": "How much protein should I eat per day?",
      "answer": "For most adults, aim for 0.8-1.2g per kg of body weight...",
      "tags": ["basics", "goals"]
    },
    {
      "question": "What counts as a protein serving?",
      "answer": "One serving = ~25g protein. Examples: 4oz chicken, 1 cup Greek yogurt...",
      "tags": ["tracking"]
    }
  ]
}
```

### Section Config (Detail Screen)

```json
{
  "section_config": [
    {
      "section_id": "by_meal",
      "title": "Protein by Meal",
      "type": "stacked_chart",
      "metrics": ["DISP_PROTEIN_MEAL_TIMING"],
      "description": "See how your protein is distributed across meals"
    },
    {
      "section_id": "by_source",
      "title": "Protein Sources",
      "type": "breakdown",
      "metrics": ["DISP_PLANT_PROTEIN_GRAMS", "DISP_PROTEIN_VARIETY"],
      "description": "Track the variety and quality of protein sources"
    }
  ]
}
```

---

## Benefits

1. **Clean Navigation**: Clear 3-tier structure (Pillar → Screen → Primary → Detail)
2. **Flexible Layouts**: Swift chooses layout based on `layout_type` hint
3. **Education Integration**: Built-in support for tips, FAQs, articles
4. **Future-Proof**: Metadata fields for custom config, AI insights, etc.
5. **Mobile-Optimized**: Primary screens keep UI simple, detail screens provide depth
6. **Goal Tracking**: Primary screens can show progress towards goals
7. **Personalization**: Tips and insights can be tailored per user

---

## Current Stats

- **45 Display Screens** (entry points)
- **45 Primary Screens** (1 per display screen)
- **45 Detail Screens** (1 per display screen)
- **187 Display Metrics** distributed across primary and detail screens

**Top Screens by Metric Count:**
1. Screening Compliance: 19 primary, 0 detail
2. Daily Activity: 12 primary, 3 detail
3. Meal Quality: 6 primary, 7 detail
4. Meal Timing: 5 primary, 7 detail
5. Biometrics: 7 primary, 1 detail

---

## Next Steps

### Backend
1. ✅ Primary/detail architecture created
2. ⏳ Populate `quick_tips` for key screens (Protein, Sleep, Steps)
3. ⏳ Add `section_config` for detail screens with tabs
4. ⏳ Create `education_content` table and link to screens
5. ⏳ Add goal_config for trackable metrics

### Mobile
1. Create `PrimaryScreenView` and `DetailScreenView` Swift views
2. Implement layout type switching (single_metric, tabs, sections, etc.)
3. Build reusable components: QuickTipsSection, FAQSection, MetricChartView
4. Add "View More" button navigation
5. Query primary screen on initial load, lazy-load detail on button tap

---

**Status:** ✅ COMPLETE
**Date:** 2025-10-25
**Tables Created:** `display_screens_primary`, `display_screens_detail`
**Metrics Migrated:** 187 metrics assigned to primary or detail screens
