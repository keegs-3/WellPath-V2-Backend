# Item Cards Navigation - Swift Implementation Guide

## Overview

This guide shows how to use the `patient_item_cards_with_navigation` view to create item cards in the component drill-down flow:

**User Flow**: WellPath Score → Pillar → Component → **Items** (you are here)

Each item card displays:
- Ring chart showing the patient's score percentage
- Display name (cleaned up using survey groups)
- Subtitle for context (e.g., pillar/section name)
- Navigation target (biomarker detail, display screen, or education content)

## Database View: `patient_item_cards_with_navigation`

### Key Columns

| Column | Type | Description | Example |
|--------|------|-------------|---------|
| `card_display_name` | text | User-friendly name for the card | "Fish Consumption", "HbA1c", "Bodyfat" |
| `card_subtitle` | text | Context label (section name) | "Healthful Nutrition" |
| `component_percentage` | double | Patient's score as % of max (0-100) | 100 |
| `item_weight_in_component` | double | Item's weight as fraction of component | 0.077 (7.7%) |
| `navigation_type` | text | Destination type | "biomarker_detail", "display_screen", "education_content" |
| `navigation_id` | text | Identifier for navigation | "HbA1c", "2.15", "module-123" |
| `pillar_name` | text | Pillar name | "Healthful Nutrition" |
| `component_type` | text | Component type | "markers", "behaviors", "education" |

### Item Types

- **biomarker**: Lab markers (e.g., HbA1c, LDL)
- **biometric**: Body measurements (e.g., BMI, Bodyfat)
- **survey_question**: Individual survey questions (e.g., "How often do you eat fish?")
- **survey_function**: Aggregated survey scores (e.g., cognitive_activities_score)
- **education**: Education modules (currently not in scoring but will be added)

## Swift Implementation

### 1. Data Model

```swift
struct ItemCard: Codable, Identifiable {
    let id: UUID
    let pillarName: String
    let componentType: String
    let itemType: String

    // Display
    let cardDisplayName: String
    let cardSubtitle: String?
    let componentPercentage: Double
    let itemWeightInComponent: Double

    // Navigation
    let navigationType: String
    let navigationId: String?

    // Computed properties
    var percentOfComponent: String {
        String(format: "%.1f%%", itemWeightInComponent * 100)
    }

    var scoreText: String {
        String(format: "%.0f%%", componentPercentage)
    }

    var scoreColor: Color {
        switch componentPercentage {
        case 80...100: return .green
        case 60..<80: return .yellow
        default: return .red
        }
    }
}
```

### 2. Fetching Item Cards

```swift
func fetchItemCards(pillarName: String, componentType: String) async throws -> [ItemCard] {
    let query = supabase
        .from("patient_item_cards_with_navigation")
        .select("""
            id,
            pillar_name,
            component_type,
            item_type,
            card_display_name,
            card_subtitle,
            component_percentage,
            item_weight_in_component,
            navigation_type,
            navigation_id
        """)
        .eq("patient_id", value: userId)
        .eq("pillar_name", value: pillarName)
        .eq("component_type", value: componentType)
        .order("item_weight_in_component", ascending: false)

    let response: [ItemCard] = try await query.execute().value
    return response
}
```

### 3. Card UI Component

```swift
struct ItemCardView: View {
    let card: ItemCard

    var body: some View {
        HStack(spacing: 16) {
            // Ring chart (similar to PillarScoreCardView)
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 8)
                    .frame(width: 60, height: 60)

                Circle()
                    .trim(from: 0, to: card.componentPercentage / 100)
                    .stroke(card.scoreColor, lineWidth: 8)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))

                Text(card.scoreText)
                    .font(.system(size: 14, weight: .semibold))
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(card.cardDisplayName)
                    .font(.headline)
                    .foregroundColor(.primary)

                if let subtitle = card.cardSubtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Text("\(card.percentOfComponent) of component")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}
```

### 4. Component Items List View

```swift
struct ComponentItemsView: View {
    let pillarName: String
    let componentType: String

    @State private var items: [ItemCard] = []
    @State private var isLoading = true
    @State private var error: Error?

    var body: some View {
        List {
            if isLoading {
                ProgressView("Loading items...")
            } else if let error = error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ForEach(items) { card in
                    NavigationLink(destination: destinationView(for: card)) {
                        ItemCardView(card: card)
                    }
                    .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                }
            }
        }
        .navigationTitle("\(pillarName) - \(componentType.capitalized)")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadItems()
        }
    }

    func loadItems() async {
        do {
            items = try await fetchItemCards(pillarName: pillarName, componentType: componentType)
            isLoading = false
        } catch {
            self.error = error
            isLoading = false
        }
    }
}
```

### 5. Navigation Routing

```swift
@ViewBuilder
func destinationView(for card: ItemCard) -> some View {
    switch card.navigationType {
    case "biomarker_detail":
        if let name = card.navigationId {
            BiomarkerDetailView(
                name: name,
                value: nil,  // Can fetch from patient data if needed
                status: nil,
                optimalRange: nil,
                trend: nil,
                isBiometric: false
            )
        }

    case "biometric_detail":
        if let name = card.navigationId {
            BiomarkerDetailView(
                name: name,
                value: nil,
                status: nil,
                optimalRange: nil,
                trend: nil,
                isBiometric: true
            )
        }

    case "display_screen":
        if let screenId = card.navigationId {
            // Navigate to display screen or check-in view
            DisplayScreenView(screenId: screenId)
        }

    case "education_content":
        if let moduleId = card.navigationId {
            EducationContentView(moduleId: moduleId)
        }

    default:
        Text("Unknown navigation type: \(card.navigationType)")
    }
}
```

## Example Queries

### Get all markers for Healthful Nutrition

```sql
SELECT
    card_display_name,
    card_subtitle,
    component_percentage,
    item_weight_in_component,
    navigation_type,
    navigation_id
FROM patient_item_cards_with_navigation
WHERE patient_id = '<uuid>'
  AND pillar_name = 'Healthful Nutrition'
  AND component_type = 'markers'
ORDER BY item_weight_in_component DESC;
```

**Result Example**:
```
card_display_name | component_percentage | item_weight_in_component | navigation_type  | navigation_id
------------------|----------------------|--------------------------|------------------|---------------
ApoB              | 100                  | 0.039                    | biomarker_detail | ApoB
Lp(a)             | 100                  | 0.039                    | biomarker_detail | Lp(a)
HbA1c             | 100                  | 0.031                    | biomarker_detail | HbA1c
```

### Get behavior items (survey questions)

```sql
SELECT
    card_display_name,
    survey_group_name,
    card_subtitle,
    component_percentage,
    navigation_type,
    navigation_id
FROM patient_item_cards_with_navigation
WHERE patient_id = '<uuid>'
  AND pillar_name = 'Healthful Nutrition'
  AND component_type = 'behaviors'
ORDER BY item_weight_in_component DESC
LIMIT 5;
```

**Result Example**:
```
card_display_name     | survey_group_name     | card_subtitle        | component_percentage | navigation_type | navigation_id
----------------------|-----------------------|----------------------|----------------------|-----------------|---------------
Water Consumption     | Water Consumption     | Healthful Nutrition  | 100                  | display_screen  | 2.29
Fish Consumption      | Fish Consumption      | Healthful Nutrition  | 100                  | display_screen  | 2.15
Fruit Consumption     | Fruit Consumption     | Healthful Nutrition  | 100                  | display_screen  | 2.19
```

### Get survey functions with display names

```sql
SELECT
    card_display_name,
    component_percentage,
    item_weight_in_component,
    navigation_type
FROM patient_item_cards_with_navigation
WHERE patient_id = '<uuid>'
  AND item_type = 'survey_function'
ORDER BY pillar_name, item_weight_in_component DESC
LIMIT 5;
```

**Result Example**:
```
card_display_name                 | component_percentage | item_weight_in_component | navigation_type
----------------------------------|----------------------|--------------------------|------------------
Cognitive Activities Engagement   | 100                  | 0.19                     | display_screen
Tobacco Use Assessment            | 100                  | 0.042                    | display_screen
Alcohol Use Assessment            | 100                  | 0.028                    | display_screen
Recreational Drug Use Assessment  | 100                  | 0.022                    | display_screen
OTC Medication Use Assessment     | 100                  | 0.017                    | display_screen
```

## Display Name Sources

The view uses smart display names based on item type:

- **Biomarkers/Biometrics**: Uses the existing name (e.g., "HbA1c", "BMI", "Bodyfat")
- **Survey Questions**: Uses `survey_groups.display_name` (e.g., "Fish Consumption" instead of raw question text)
- **Survey Functions**: Uses `wellpath_scoring_survey_functions.display_name` (e.g., "Cognitive Activities Engagement" instead of "cognitive_activities_score")
- **Education**: Uses `education_base.title`

## Navigation Flow Summary

```
Component View (e.g., Healthful Nutrition - Markers)
    ↓
Query: patient_item_cards_with_navigation
    ↓
Display: List of ItemCardView components
    ↓
User taps card
    ↓
Switch on navigation_type:
    - biomarker_detail → BiomarkerDetailView(name: navigation_id)
    - biometric_detail → BiometricDetailView(name: navigation_id)
    - display_screen → DisplayScreenView(screenId: navigation_id)
    - education_content → EducationContentView(moduleId: navigation_id)
```

## Notes

- The `navigation_id` for survey questions is currently the `question_number` (e.g., "2.15")
- In the future, questions may be mapped to `display_screen` screen_ids through additional joins
- The `card_subtitle` shows the section name for survey questions (provides context)
- All weights are normalized so that items within a component sum to 100%

## Related Documentation

- **Component Drill-Down**: See `COMPONENT_DRILL_DOWN_QUERIES.md`
- **Score History**: See `SCORING_SYSTEM_COMPLETE.md`
- **History Tables**: See `HISTORY_TABLES_SUMMARY.md`
