# WellPath Mobile Database Architecture Guide
**For iOS Swift Development Team**

Last Updated: 2025-10-27

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Dashboard Level](#dashboard-level)
3. [Pillar Level](#pillar-level)
4. [Component Level](#component-level)
5. [Individual Metric Level](#individual-metric-level)
6. [About Sections & Educational Content](#about-sections--educational-content)
7. [Data Entry & Tracking](#data-entry--tracking)
8. [Complete Swift Models](#complete-swift-models)
9. [Query Patterns & Best Practices](#query-patterns--best-practices)

---

## Architecture Overview

### Scoring Hierarchy

```
WellPath Overall Score (100%)
├── Pillar Scores (9 pillars) ~11% each
│   ├── Biomarkers Component (varies by pillar)
│   │   ├── Individual biomarkers (blood tests, imaging)
│   │   └── Individual biometrics (weight, VO2 max, sleep stages)
│   ├── Behaviors Component (varies by pillar)
│   │   ├── Survey responses (questionnaire)
│   │   └── Tracked data (protein, steps, water, etc.)
│   └── Education Component (10% per pillar)
│       └── Articles, quizzes, videos completed
```

### The 9 Pillars

| Pillar | Biomarkers | Behaviors | Education | Description |
|--------|-----------|-----------|-----------|-------------|
| Healthful Nutrition | 72% | 18% | 10% | Nutrition intake, body composition |
| Movement + Exercise | 54% | 36% | 10% | Physical activity, cardio fitness |
| Restorative Sleep | 63% | 27% | 10% | Sleep quality, duration, stages |
| Cognitive Health | 36% | 54% | 10% | Memory, mental clarity, brain health |
| Stress Management | 27% | 63% | 10% | Stress levels, coping mechanisms |
| Connection + Purpose | 18% | 72% | 10% | Social relationships, life purpose |
| Core Care | 49.5% | 40.5% | 10% | Preventive care, screenings, medications |
| Emotional Wellbeing | TBD | TBD | 10% | Emotional health, resilience |
| Environmental Health | TBD | TBD | 10% | Environment, toxin exposure |

---

## Dashboard Level

### Screen Structure

**Dashboard displays:**
1. Overall WellPath Score (large circle/radial chart)
2. Score history line chart (30 days)
3. Grid of 9 pillar cards with individual scores
4. About tab with:
   - What is WellPath Score content
   - Doughnut chart showing pillar allocations
   - Link to methodology

### Database Tables & Queries

#### 1. Overall WellPath Score (Current)

**Table:** `patient_wellpath_score_overall` (view)

**Query:**
```swift
let userId = try await supabase.auth.session.user.id

let response: [WellPathScoreOverall] = try await supabase
    .from("patient_wellpath_score_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .limit(1)
    .execute()
    .value

let currentScore = response.first
```

**Swift Model:**
```swift
struct WellPathScoreOverall: Codable {
    let patientId: UUID
    let patientScore: Double        // e.g., 757.8
    let maxScore: Double            // e.g., 1000
    let scorePercentage: Double     // e.g., 75.78 (already 0-100)
    let itemCount: Int?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case patientScore = "patient_score"
        case maxScore = "max_score"
        case scorePercentage = "score_percentage"
        case itemCount = "item_count"
        case lastUpdated = "last_updated"
    }
}
```

#### 2. WellPath Score History (Line Chart)

**Table:** `patient_wellpath_score_history_overall` (view)

**Query:**
```swift
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
let dateString = ISO8601DateFormatter().string(from: thirtyDaysAgo)

let history: [WellPathScoreHistory] = try await supabase
    .from("patient_wellpath_score_history_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .gte("calculated_at", value: dateString)
    .order("calculated_at", ascending: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct WellPathScoreHistory: Codable {
    let patientId: UUID
    let overallPercentage: Double
    let calculatedAt: String

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case overallPercentage = "overall_percentage"
        case calculatedAt = "calculated_at"
    }
}
```

#### 3. Pillar Scores (Grid Cards)

**Table:** `patient_wellpath_score_by_pillar` (view)

**Query:**
```swift
let pillarScores: [PillarScore] = try await supabase
    .from("patient_wellpath_score_by_pillar")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .order("pillar_name", ascending: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct PillarScore: Codable, Identifiable {
    var id: String { pillarName }
    let patientId: UUID
    let pillarName: String
    let patientScore: Double
    let maxScore: Double
    let scorePercentage: Double
    let itemCount: Int
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarName = "pillar_name"
        case patientScore = "patient_score"
        case maxScore = "max_score"
        case scorePercentage = "score_percentage"
        case itemCount = "item_count"
        case lastUpdated = "last_updated"
    }
}
```

#### 4. About Content (Dashboard)

**Table:** `wellpath_score_about`

**Query:**
```swift
let sections: [WellPathScoreAbout] = try await supabase
    .from("wellpath_score_about")
    .select()
    .eq("is_active", value: true)
    .order("display_order", ascending: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct WellPathScoreAbout: Codable, Identifiable {
    let id: UUID
    let sectionTitle: String
    let sectionContent: String
    let displayOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case sectionTitle = "section_title"
        case sectionContent = "section_content"
        case displayOrder = "display_order"
    }
}
```

#### 5. Pillar Allocation for Doughnut Chart

**Hardcoded Values:** Each pillar contributes ~11.11% to overall score (9 equal pillars).

**For visualization:** Use `pillarScores` array from above and calculate percentages based on pillar weights.

---

## Pillar Level

### Screen Structure

Each pillar has:
1. Pillar score header (e.g., "Healthful Nutrition: 78%")
2. Score history line chart (30 days)
3. Component breakdown cards (Biomarkers, Behaviors, Education)
   - Each card shows: % of pillar, points earned/max, weight
   - Tap navigates to component detail screen
4. About tab with:
   - Pillar description
   - Doughnut chart showing component allocations
   - Related educational content

### Database Tables & Queries

#### 1. Pillar Score History (Line Chart)

**Table:** `patient_wellpath_score_history_by_pillar` (view)

**Query:**
```swift
// Get pillar_id from pillar_name first
let pillarMapping: [PillarBase] = try await supabase
    .from("pillars_base")
    .select("pillar_id, pillar_name")
    .eq("pillar_name", value: "Healthful Nutrition")
    .limit(1)
    .execute()
    .value

let pillarId = pillarMapping.first?.pillarId

// Then fetch history
let history: [PillarScoreHistory] = try await supabase
    .from("patient_wellpath_score_history_by_pillar")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_id", value: pillarId)
    .gte("calculated_at", value: dateString)
    .order("calculated_at", ascending: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct PillarScoreHistory: Codable {
    let patientId: UUID
    let pillarId: String
    let pillarPercentage: Double
    let calculatedAt: String

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarId = "pillar_id"
        case pillarPercentage = "pillar_percentage"
        case calculatedAt = "calculated_at"
    }
}
```

#### 2. Component Breakdown

**Tables:**
- `patient_wellpath_score_by_pillar_component` (view)
- Or calculate from pillar score + weights

**Option A - Query from view:**
```swift
let components: [PillarComponentScore] = try await supabase
    .from("patient_wellpath_score_by_pillar_component")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_id", value: pillarId)
    .execute()
    .value
```

**Option B - Calculate from weights (currently used):**
```swift
// Use hardcoded weights from PillarWeightConfig
let biomarkersWeight = PillarWeightConfig.weight(for: "Healthful Nutrition", component: "biomarkers") // 0.72
let behaviorsWeight = PillarWeightConfig.weight(for: "Healthful Nutrition", component: "behaviors")     // 0.18
let educationWeight = PillarWeightConfig.weight(for: "Healthful Nutrition", component: "education")     // 0.10

let totalScore = pillarScore.patientScore // e.g., 780
let biomarkersScore = totalScore * biomarkersWeight  // 561.6
let behaviorsScore = totalScore * behaviorsWeight    // 140.4
let educationScore = totalScore * educationWeight    // 78.0
```

**Swift Model:**
```swift
struct PillarComponentScore: Codable {
    let pillarName: String
    let componentType: String  // "biomarkers", "behaviors", "education"
    let totalScore: Double
    let biomarkersScore: Double
    let behaviorsScore: Double
    let educationScore: Double
    let biomarkersWeight: Double
    let behaviorsWeight: Double
    let educationWeight: Double
}
```

#### 3. Pillar About Content

**Tables:**
- `wellpath_pillars_about` - main pillar description
- `wellpath_pillars_markers_about` - biomarkers component description
- `wellpath_pillars_behaviors_about` - behaviors component description
- `wellpath_pillars_education_about` - education component description

**Query:**
```swift
// Main pillar about
let pillarAbout: [PillarAbout] = try await supabase
    .from("wellpath_pillars_about")
    .select()
    .eq("pillar_id", value: pillarId)
    .eq("is_active", value: true)
    .execute()
    .value

// Markers about
let markersAbout: [PillarMarkersAbout] = try await supabase
    .from("wellpath_pillars_markers_about")
    .select()
    .eq("pillar_id", value: pillarId)
    .eq("is_active", value: true)
    .execute()
    .value

// Behaviors about
let behaviorsAbout: [PillarBehaviorsAbout] = try await supabase
    .from("wellpath_pillars_behaviors_about")
    .select()
    .eq("pillar_id", value: pillarId)
    .eq("is_active", value: true)
    .execute()
    .value

// Education about
let educationAbout: [PillarEducationAbout] = try await supabase
    .from("wellpath_pillars_education_about")
    .select()
    .eq("pillar_id", value: pillarId)
    .eq("is_active", value: true)
    .execute()
    .value
```

**Swift Models:**
```swift
struct PillarAbout: Codable {
    let pillarId: String
    let title: String
    let description: String
    let whyItMatters: String?
    let howToImprove: String?

    enum CodingKeys: String, CodingKey {
        case pillarId = "pillar_id"
        case title, description
        case whyItMatters = "why_it_matters"
        case howToImprove = "how_to_improve"
    }
}

struct PillarMarkersAbout: Codable {
    let pillarId: String
    let description: String
    let keyMarkers: String?

    enum CodingKeys: String, CodingKey {
        case pillarId = "pillar_id"
        case description
        case keyMarkers = "key_markers"
    }
}
```

---

## Component Level

### Screen Structure

Component detail screens (Biomarkers, Behaviors, or Education within a pillar):
1. Component score header (e.g., "Biomarkers: 561/780 pts")
2. Score history line chart (if available)
3. List of individual metrics with:
   - Metric name
   - Current value/status
   - Points earned/max points
   - Weight within component
   - Navigate to individual metric on tap
4. About tab with:
   - Component description
   - Doughnut chart showing individual metric contributions
   - Related tips/educational content

### Database Tables & Queries

#### 1. Biomarkers & Biometrics List

**For biomarkers (blood tests, imaging):**
**Table:** `patient_biomarker_scores_by_pillar` (view)

**Query:**
```swift
let biomarkers: [BiomarkerScore] = try await supabase
    .from("patient_biomarker_scores_by_pillar")
    .select("""
        biomarker_name,
        current_value,
        reference_unit,
        points_earned,
        max_points,
        weight_in_pillar,
        score_percentage,
        range_classification,
        last_reading_date
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("weight_in_pillar", ascending: false)
    .execute()
    .value
```

**For biometrics (measurements, fitness):**
**Table:** `patient_biometric_scores_by_pillar` (view)

**Query:**
```swift
let biometrics: [BiometricScore] = try await supabase
    .from("patient_biometric_scores_by_pillar")
    .select("""
        biometric_name,
        current_value,
        unit,
        points_earned,
        max_points,
        weight_in_pillar,
        score_percentage,
        range_classification,
        last_reading_date
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Movement + Exercise")
    .order("weight_in_pillar", ascending: false)
    .execute()
    .value
```

**Swift Models:**
```swift
struct BiomarkerScore: Codable, Identifiable {
    var id: String { biomarkerName }
    let biomarkerName: String
    let currentValue: Double?
    let referenceUnit: String?
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let rangeClassification: String?
    let lastReadingDate: String?

    enum CodingKeys: String, CodingKey {
        case biomarkerName = "biomarker_name"
        case currentValue = "current_value"
        case referenceUnit = "reference_unit"
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case rangeClassification = "range_classification"
        case lastReadingDate = "last_reading_date"
    }
}

struct BiometricScore: Codable, Identifiable {
    var id: String { biometricName }
    let biometricName: String
    let currentValue: Double?
    let unit: String?
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let rangeClassification: String?
    let lastReadingDate: String?

    enum CodingKeys: String, CodingKey {
        case biometricName = "biometric_name"
        case currentValue = "current_value"
        case unit
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case rangeClassification = "range_classification"
        case lastReadingDate = "last_reading_date"
    }
}
```

#### 2. Behaviors List

**Table:** `patient_behavior_scores_by_pillar` (view)

**Query:**
```swift
let behaviors: [BehaviorScore] = try await supabase
    .from("patient_behavior_scores_by_pillar")
    .select("""
        question_number,
        question_text,
        response_text,
        response_score,
        points_earned,
        max_points,
        weight_in_pillar,
        score_percentage,
        last_updated,
        data_source
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Cognitive Health")
    .order("weight_in_pillar", ascending: false)
    .execute()
    .value
```

**Swift Model:**
```swift
struct BehaviorScore: Codable, Identifiable {
    var id: Double { questionNumber }
    let questionNumber: Double
    let questionText: String
    let responseText: String?
    let responseScore: Double
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let lastUpdated: String?
    let dataSource: String?  // "questionnaire_initial", "tracked_data_auto_update", "check_in_update"

    enum CodingKeys: String, CodingKey {
        case questionNumber = "question_number"
        case questionText = "question_text"
        case responseText = "response_text"
        case responseScore = "response_score"
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case lastUpdated = "last_updated"
        case dataSource = "data_source"
    }
}
```

#### 3. Education List

**Table:** `patient_education_scores_by_pillar` (view)

**Query:**
```swift
let education: [EducationScore] = try await supabase
    .from("patient_education_scores_by_pillar")
    .select("""
        education_item_id,
        education_item_title,
        completion_status,
        completion_percentage,
        points_earned,
        max_points,
        weight_in_pillar,
        completed_date
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_id", value: pillarId)
    .order("weight_in_pillar", ascending: false)
    .execute()
    .value
```

**Swift Model:**
```swift
struct EducationScore: Codable, Identifiable {
    var id: String { educationItemId }
    let educationItemId: String
    let educationItemTitle: String
    let completionStatus: String  // "started", "in_progress", "completed"
    let completionPercentage: Double?
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let completedDate: String?

    enum CodingKeys: String, CodingKey {
        case educationItemId = "education_item_id"
        case educationItemTitle = "education_item_title"
        case completionStatus = "completion_status"
        case completionPercentage = "completion_percentage"
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case completedDate = "completed_date"
    }
}
```

---

## Individual Metric Level

### Screen Structure

Individual metric screens show detailed view of a single biomarker, biometric, behavior, or education item:

1. Metric header (name, current value, score)
2. **Line chart with historical data** (30-90 days)
3. Below chart: **All related components** grouped by type:
   - **Biomarkers** → Navigate to biomarker detail/metrics page
   - **Biometrics** → Navigate to biometric detail/metrics page
   - **Behaviors** → Navigate to display screen for tracking
   - **Education** → Links to related articles, quizzes, videos
4. About tab with:
   - Metric description
   - Why it matters
   - How to improve
   - Doughnut chart showing sub-components (for parent metrics like "Nutrition")

**Note:** For complex metrics like "Healthful Nutrition" with many biomarkers, consider a separate "Components Overview" page with just the doughnut chart and navigation paths to individual screens.

### Database Tables & Queries

#### 1. Biomarker/Biometric Detail & History

**Tables:**
- `patient_marker_values_history` - unified history for both biomarkers and biometrics
- `patient_marker_values_current` - current/latest values

**Query for history:**
```swift
let history: [MarkerReading] = try await supabase
    .from("patient_marker_values_history")
    .select("""
        marker_value,
        marker_unit,
        reading_date,
        data_source
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("marker_name", value: "LDL Cholesterol")
    .eq("marker_type", value: "biomarker")  // or "biometric"
    .gte("reading_date", value: dateString)
    .order("reading_date", ascending: true)
    .execute()
    .value
```

**Query for current value:**
```swift
let current: [MarkerCurrent] = try await supabase
    .from("patient_marker_values_current")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("marker_name", value: "LDL Cholesterol")
    .eq("marker_type", value: "biomarker")
    .limit(1)
    .execute()
    .value
```

**Swift Models:**
```swift
struct MarkerReading: Codable {
    let markerValue: Double
    let markerUnit: String?
    let readingDate: String
    let dataSource: String  // "clinician_web", "wellpath_app"

    enum CodingKeys: String, CodingKey {
        case markerValue = "marker_value"
        case markerUnit = "marker_unit"
        case readingDate = "reading_date"
        case dataSource = "data_source"
    }
}

struct MarkerCurrent: Codable {
    let patientId: UUID
    let markerType: String
    let markerName: String
    let markerValue: Double
    let markerUnit: String?
    let dataSource: String
    let readingDate: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case markerType = "marker_type"
        case markerName = "marker_name"
        case markerValue = "marker_value"
        case markerUnit = "marker_unit"
        case dataSource = "data_source"
        case readingDate = "reading_date"
        case notes
    }
}
```

#### 2. Behavior Detail & History

**Tables:**
- `patient_behavioral_values_history` - all behavior value history
- `patient_behavioral_values_current` - current/latest values

**Query for history:**
```swift
let history: [BehaviorReading] = try await supabase
    .from("patient_behavioral_values_history")
    .select("""
        response_value,
        response_text,
        effective_date,
        data_source
    """)
    .eq("patient_id", value: userId.uuidString)
    .eq("question_number", value: 5.01)  // Cognitive function rating
    .gte("effective_date", value: dateString)
    .order("effective_date", ascending: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct BehaviorReading: Codable {
    let responseValue: Double
    let responseText: String?
    let effectiveDate: String
    let dataSource: String  // "questionnaire_initial", "tracked_data_auto_update", "check_in_update"

    enum CodingKeys: String, CodingKey {
        case responseValue = "response_value"
        case responseText = "response_text"
        case effectiveDate = "effective_date"
        case dataSource = "data_source"
    }
}
```

#### 3. Related Metrics (For Complex Parent Metrics)

**Example: "Healthful Nutrition" biomarker has dozens of related biomarkers**

**Tables:**
- `biomarkers_biometrics_aggregation_metrics` - parent-child relationships
- `display_metrics` - display configuration

**Query for child biomarkers:**
```swift
// For a parent biomarker like "Nutrition Biomarkers"
let childBiomarkers: [String] = try await supabase
    .from("biomarkers_biometrics_aggregation_metrics")
    .select("biomarker_name")
    .eq("agg_metric_id", value: "AGG_NUTRITION_BIOMARKERS")
    .eq("is_active", value: true)
    .execute()
    .value
    .map { $0.biomarkerName }

// Then query scores for each child
for biomarkerName in childBiomarkers {
    // Query patient_biomarker_scores_by_pillar for each
}
```

#### 4. Navigating to Display Screens (For Tracked Behaviors)

**Tables:**
- `display_screens` - screen configuration
- `display_metrics` - metrics shown on screen
- `display_screens_display_metrics` - junction table

**Query for behavior's display screen:**
```swift
// Find which display screen shows this tracked metric
let screens: [DisplayScreen] = try await supabase
    .from("display_screens_display_metrics")
    .select("display_screens(*)")
    .eq("metric_id", value: "METRIC_PROTEIN_GRAMS")
    .execute()
    .value
```

**Navigate to:** The screen's detail view (e.g., "Protein" screen with grams, timing, sources)

#### 5. Related Education Content

**Tables:**
- `education_content_base` - all educational articles
- `education_content_pillars` - education-to-pillar mapping
- `education_content_biomarkers` - education-to-biomarker mapping
- `education_content_biometrics` - education-to-biometric mapping

**Query for related articles:**
```swift
let articles: [EducationContent] = try await supabase
    .from("education_content_biomarkers")
    .select("education_content_base(*)")
    .eq("biomarker_name", value: "LDL Cholesterol")
    .eq("education_content_base.is_active", value: true)
    .execute()
    .value
```

**Swift Model:**
```swift
struct EducationContent: Codable, Identifiable {
    let id: UUID
    let contentId: String
    let title: String
    let contentType: String  // "article", "quiz", "video"
    let content: String?
    let summary: String?
    let estimatedReadTime: Int?
    let url: String?

    enum CodingKeys: String, CodingKey {
        case id
        case contentId = "content_id"
        case title
        case contentType = "content_type"
        case content, summary
        case estimatedReadTime = "estimated_read_time"
        case url
    }
}
```

---

## About Sections & Educational Content

### Database Tables

#### 1. General About Content

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `wellpath_score_about` | Dashboard about content | section_title, section_content, display_order |
| `wellpath_pillars_about` | Pillar descriptions | pillar_id, title, description, why_it_matters |
| `wellpath_pillars_markers_about` | Biomarkers component about | pillar_id, description, key_markers |
| `wellpath_pillars_behaviors_about` | Behaviors component about | pillar_id, description, key_behaviors |
| `wellpath_pillars_education_about` | Education component about | pillar_id, description, recommended_topics |

#### 2. Biomarker/Biometric About Content

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `biomarkers_base_about` | Biomarker descriptions | biomarker_name, about_content, why_it_matters, optimal_range_description |
| `biometrics_base_about` | Biometric descriptions | biometric_name, about_content, why_it_matters, how_to_improve |

**Query example:**
```swift
let biomarkerAbout: [BiomarkerAbout] = try await supabase
    .from("biomarkers_base_about")
    .select()
    .eq("biomarker_name", value: "LDL Cholesterol")
    .limit(1)
    .execute()
    .value
```

#### 3. Display Screen About Content

**Tables:**
- `primary_screens` - has embedded education fields: about_content, longevity_impact, quick_tips
- `detail_screens` - similar structure with detailed_info

**Query example:**
```swift
let screenInfo: [PrimaryScreen] = try await supabase
    .from("primary_screens")
    .select("""
        about_content,
        longevity_impact,
        quick_tips
    """)
    .eq("primary_screen_id", value: "SCREEN_PROTEIN")
    .limit(1)
    .execute()
    .value
```

---

## Data Entry & Tracking

### How Users Enter Data

#### 1. Biomarkers (Blood Tests, Imaging)

**Entry method:** Clinician enters via web portal

**Tables:**
- `patient_biomarker_results` - original entry (deprecated, migrating away)
- `patient_marker_values_history` - unified storage (NEW)

**When data is entered:**
1. Clinician enters result in web portal
2. Row inserted into `patient_marker_values_history` with `data_source='clinician_web'`
3. Trigger fires to recalculate biomarker scores
4. New score appears in `patient_biomarker_scores_by_pillar` view

#### 2. Biometrics (Measurements)

**Entry methods:**
- Clinician enters via web portal
- Patient enters in mobile app
- Auto-sync from Apple Health / Google Fit

**Tables:**
- `patient_biometric_readings` - original entry (deprecated, migrating away)
- `patient_marker_values_history` - unified storage (NEW)

**Mobile entry flow:**
```swift
// Insert new biometric reading
try await supabase
    .from("patient_marker_values_history")
    .insert([
        "patient_id": userId.uuidString,
        "marker_type": "biometric",
        "marker_name": "Weight",
        "marker_value": 185.5,
        "marker_unit": "lbs",
        "data_source": "wellpath_app",
        "reading_date": ISO8601DateFormatter().string(from: Date())
    ])
    .execute()
```

#### 3. Behaviors (Survey Responses & Tracked Data)

**Entry methods:**
- Initial questionnaire (one-time)
- Check-ins (periodic updates)
- Tracked data (continuous, auto-calculated from aggregations)

**Tables:**
- `patient_survey_responses` - original questionnaire answers (deprecated, migrating away)
- `patient_behavioral_values_history` - unified storage (NEW)

**Data source types:**
- `questionnaire_initial` - First-time questionnaire answer
- `check_in_update` - Updated from periodic check-ins
- `tracked_data_auto_update` - Auto-updated when user tracks data (e.g., protein tracking updates Q2.09)
- `clinician_entry` - Manually entered by clinician

**Example auto-update flow:**
```
User tracks protein intake → AGG_PROTEIN_GRAMS updates →
If > 0 → Q2.09 "Do you track protein?" auto-updates to "Yes" →
New row in patient_behavioral_values_history with data_source='tracked_data_auto_update'
```

#### 4. Tracked Metrics (via Display Screens)

**Tables:**
- `display_screens` - screen configuration
- `display_metrics` - metrics on screen
- `data_entry_fields` - field definitions
- `patient_data_entry_values` - user's entered values

**Example: User enters protein intake**
```swift
// Query available data entry fields for this screen
let fields: [DataEntryField] = try await supabase
    .from("data_entry_fields")
    .select()
    .eq("field_id", value: "FIELD_PROTEIN_GRAMS")
    .execute()
    .value

// Insert user's value
try await supabase
    .from("patient_data_entry_values")
    .insert([
        "patient_id": userId.uuidString,
        "field_id": "FIELD_PROTEIN_GRAMS",
        "field_value": 150,
        "unit": "g",
        "recorded_at": ISO8601DateFormatter().string(from: Date()),
        "data_source": "wellpath_app"
    ])
    .execute()
```

**What happens next:**
1. Aggregation metrics calculate (hourly, daily, weekly based on config)
2. Scores update based on aggregation values
3. Related survey questions may auto-update
4. Patient sees updated score in app

---

## Complete Swift Models

### Core Score Models

```swift
// Overall WellPath Score
struct WellPathScoreOverall: Codable {
    let patientId: UUID
    let patientScore: Double
    let maxScore: Double
    let scorePercentage: Double
    let itemCount: Int?
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case patientScore = "patient_score"
        case maxScore = "max_score"
        case scorePercentage = "score_percentage"
        case itemCount = "item_count"
        case lastUpdated = "last_updated"
    }
}

// Pillar Score
struct PillarScore: Codable, Identifiable {
    var id: String { pillarName }
    let patientId: UUID
    let pillarName: String
    let patientScore: Double
    let maxScore: Double
    let scorePercentage: Double
    let itemCount: Int
    let lastUpdated: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarName = "pillar_name"
        case patientScore = "patient_score"
        case maxScore = "max_score"
        case scorePercentage = "score_percentage"
        case itemCount = "item_count"
        case lastUpdated = "last_updated"
    }
}

// Biomarker Score
struct BiomarkerScore: Codable, Identifiable {
    var id: String { biomarkerName }
    let patientId: UUID
    let pillarName: String
    let biomarkerName: String
    let currentValue: Double?
    let referenceUnit: String?
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let rangeClassification: String?
    let lastReadingDate: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarName = "pillar_name"
        case biomarkerName = "biomarker_name"
        case currentValue = "current_value"
        case referenceUnit = "reference_unit"
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case rangeClassification = "range_classification"
        case lastReadingDate = "last_reading_date"
    }
}

// Biometric Score (same structure as biomarker)
struct BiometricScore: Codable, Identifiable {
    var id: String { biometricName }
    let patientId: UUID
    let pillarName: String
    let biometricName: String
    let currentValue: Double?
    let unit: String?
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let rangeClassification: String?
    let lastReadingDate: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarName = "pillar_name"
        case biometricName = "biometric_name"
        case currentValue = "current_value"
        case unit
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case rangeClassification = "range_classification"
        case lastReadingDate = "last_reading_date"
    }
}

// Behavior Score
struct BehaviorScore: Codable, Identifiable {
    var id: Double { questionNumber }
    let patientId: UUID
    let pillarName: String
    let questionNumber: Double
    let questionText: String
    let responseText: String?
    let responseScore: Double
    let pointsEarned: Double
    let maxPoints: Double
    let weightInPillar: Double
    let scorePercentage: Double
    let lastUpdated: String?
    let dataSource: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarName = "pillar_name"
        case questionNumber = "question_number"
        case questionText = "question_text"
        case responseText = "response_text"
        case responseScore = "response_score"
        case pointsEarned = "points_earned"
        case maxPoints = "max_points"
        case weightInPillar = "weight_in_pillar"
        case scorePercentage = "score_percentage"
        case lastUpdated = "last_updated"
        case dataSource = "data_source"
    }
}
```

### History Models

```swift
// WellPath Score History
struct WellPathScoreHistory: Codable {
    let patientId: UUID
    let overallPercentage: Double
    let calculatedAt: String

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case overallPercentage = "overall_percentage"
        case calculatedAt = "calculated_at"
    }
}

// Pillar Score History
struct PillarScoreHistory: Codable {
    let patientId: UUID
    let pillarId: String
    let pillarPercentage: Double
    let calculatedAt: String

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case pillarId = "pillar_id"
        case pillarPercentage = "pillar_percentage"
        case calculatedAt = "calculated_at"
    }
}

// Marker (Biomarker/Biometric) Reading
struct MarkerReading: Codable {
    let patientId: UUID
    let markerType: String  // "biomarker" or "biometric"
    let markerName: String
    let markerValue: Double
    let markerUnit: String?
    let dataSource: String
    let readingDate: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case markerType = "marker_type"
        case markerName = "marker_name"
        case markerValue = "marker_value"
        case markerUnit = "marker_unit"
        case dataSource = "data_source"
        case readingDate = "reading_date"
        case notes
    }
}

// Behavior Reading
struct BehaviorReading: Codable {
    let patientId: UUID
    let questionNumber: Double
    let responseValue: Double
    let responseText: String?
    let dataSource: String
    let effectiveDate: String

    enum CodingKeys: String, CodingKey {
        case patientId = "patient_id"
        case questionNumber = "question_number"
        case responseValue = "response_value"
        case responseText = "response_text"
        case dataSource = "data_source"
        case effectiveDate = "effective_date"
    }
}
```

### Display Screen Models

```swift
// Display Screen
struct DisplayScreen: Codable, Identifiable {
    let id: String
    let screenId: String
    let name: String
    let overview: String?
    let pillar: String?
    let icon: String?
    let displayOrder: Int?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case screenId = "screen_id"
        case name, overview, pillar, icon
        case displayOrder = "display_order"
        case isActive = "is_active"
    }
}

// Display Metric
struct DisplayMetric: Codable, Identifiable {
    let id: String
    let metricId: String
    let metricName: String
    let description: String?
    let screenId: String?
    let pillar: String?
    let chartTypeId: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case metricId = "metric_id"
        case metricName = "metric_name"
        case description
        case screenId = "screen_id"
        case pillar
        case chartTypeId = "chart_type_id"
        case isActive = "is_active"
    }
}

// Data Entry Field
struct DataEntryField: Codable, Identifiable {
    var id: String { fieldId }
    let fieldId: String
    let fieldName: String
    let category: String?
    let inputType: String?
    let fieldType: String?
    let defaultUnit: String?
    let isActive: Bool?

    enum CodingKeys: String, CodingKey {
        case fieldId = "field_id"
        case fieldName = "field_name"
        case category
        case inputType = "input_type"
        case fieldType = "field_type"
        case defaultUnit = "default_unit"
        case isActive = "is_active"
    }
}
```

---

## Query Patterns & Best Practices

### 1. Always Filter by patient_id

```swift
// ❌ WRONG - fetches all patients
let scores = try await supabase
    .from("patient_wellpath_score_overall")
    .select()
    .execute()
    .value

// ✅ CORRECT - filtered by current user
let userId = try await supabase.auth.session.user.id
let scores: [WellPathScoreOverall] = try await supabase
    .from("patient_wellpath_score_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .execute()
    .value
```

### 2. Use Views for Complex Queries

Instead of complex joins, use pre-built views:

```swift
// ❌ COMPLEX - multiple joins
// Don't do this - use views instead

// ✅ SIMPLE - use pre-built view
let scores: [BiomarkerScore] = try await supabase
    .from("patient_biomarker_scores_by_pillar")  // View handles all joins
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Healthful Nutrition")
    .execute()
    .value
```

### 3. Batch Related Queries

```swift
// Instead of sequential queries:
async func loadPillarData() {
    let pillarScore = try await fetchPillarScore()     // 1st query
    let biomarkers = try await fetchBiomarkers()       // 2nd query
    let behaviors = try await fetchBehaviors()         // 3rd query
}

// Use async/await concurrency:
async func loadPillarData() async throws {
    async let pillarScore = fetchPillarScore()
    async let biomarkers = fetchBiomarkers()
    async let behaviors = fetchBehaviors()

    let (score, markers, behavs) = try await (pillarScore, biomarkers, behaviors)
}
```

### 4. Handle Optional Data Gracefully

```swift
struct BiomarkerScore: Codable {
    let currentValue: Double?  // Might not have a reading yet
    let lastReadingDate: String?

    var displayValue: String {
        guard let value = currentValue else {
            return "No data"
        }
        return String(format: "%.1f", value)
    }
}
```

### 5. Use Limit for Single Record Queries

```swift
// Get current score (should only be 1 row)
let response: [WellPathScoreOverall] = try await supabase
    .from("patient_wellpath_score_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .limit(1)  // ✅ Explicit limit
    .execute()
    .value

let currentScore = response.first
```

### 6. Order Results for Consistency

```swift
// List biomarkers by importance (weight)
let biomarkers: [BiomarkerScore] = try await supabase
    .from("patient_biomarker_scores_by_pillar")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("weight_in_pillar", ascending: false)  // Highest weight first
    .order("biomarker_name", ascending: true)      // Then alphabetically
    .execute()
    .value
```

### 7. Date Range Queries

```swift
// Get last 30 days of history
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
let dateString = ISO8601DateFormatter().string(from: thirtyDaysAgo)

let history: [WellPathScoreHistory] = try await supabase
    .from("patient_wellpath_score_history_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .gte("calculated_at", value: dateString)  // Greater than or equal
    .order("calculated_at", ascending: true)
    .execute()
    .value
```

### 8. Error Handling

```swift
func loadWellPathScore() async {
    do {
        let userId = try await supabase.auth.session.user.id

        let response: [WellPathScoreOverall] = try await supabase
            .from("patient_wellpath_score_overall")
            .select()
            .eq("patient_id", value: userId.uuidString)
            .limit(1)
            .execute()
            .value

        guard let score = response.first else {
            // User hasn't completed questionnaire yet
            self.error = "Complete your health assessment to see your score"
            return
        }

        self.currentScore = score

    } catch {
        // Network error, auth error, etc.
        self.error = "Failed to load score: \(error.localizedDescription)"
        print("Error: \(error)")
    }
}
```

---

## Key Database Views Reference

### Scoring Views (Pre-computed scores)

| View Name | Purpose | Key Columns |
|-----------|---------|-------------|
| `patient_wellpath_score_overall` | Overall WellPath score | patient_score, max_score, score_percentage |
| `patient_wellpath_score_by_pillar` | Score breakdown by pillar | pillar_name, patient_score, score_percentage |
| `patient_wellpath_score_by_pillar_component` | Component scores within pillar | pillar_id, component_type, component_score |
| `patient_biomarker_scores_by_pillar` | Biomarker scores grouped by pillar | biomarker_name, points_earned, weight_in_pillar |
| `patient_biometric_scores_by_pillar` | Biometric scores grouped by pillar | biometric_name, points_earned, weight_in_pillar |
| `patient_behavior_scores_by_pillar` | Behavior scores grouped by pillar | question_number, response_score, weight_in_pillar |
| `patient_education_scores_by_pillar` | Education scores grouped by pillar | education_item_id, completion_status, points_earned |

### History Views (Time-series data)

| View Name | Purpose | Key Columns |
|-----------|---------|-------------|
| `patient_wellpath_score_history_overall` | Overall score over time | overall_percentage, calculated_at |
| `patient_wellpath_score_history_by_pillar` | Pillar scores over time | pillar_id, pillar_percentage, calculated_at |
| `patient_marker_values_current` | Latest biomarker/biometric values | marker_name, marker_value, reading_date |
| `patient_behavioral_values_current` | Latest behavior values | question_number, response_value, effective_date |

### Configuration Views

| View Name | Purpose | Key Columns |
|-----------|---------|-------------|
| `display_screens` | Screen configurations | screen_id, name, pillar |
| `display_metrics` | Metrics shown on screens | metric_id, metric_name, screen_id |
| `data_entry_fields` | Available data entry fields | field_id, field_name, input_type |

---

## Important Notes

### 1. Authentication

All queries must be authenticated. The user's `patient_id` is their auth UUID:

```swift
let userId = try await supabase.auth.session.user.id
// userId is UUID type, convert to string for queries
.eq("patient_id", value: userId.uuidString)
```

### 2. Row Level Security (RLS)

All patient tables have RLS enabled. Users can only see their own data:
- Views automatically filter by `auth.uid()`
- No need to manually filter in most cases
- Use service role key for admin operations (backend only)

### 3. Data Source Tracking

All value history tables track where data came from:

**Biomarkers/Biometrics:**
- `clinician_web` - Entered by provider
- `wellpath_app` - Entered in mobile app

**Behaviors:**
- `questionnaire_initial` - First questionnaire
- `tracked_data_auto_update` - Auto-updated from tracking
- `check_in_update` - Updated from check-ins
- `clinician_entry` - Manually entered

### 4. Refresh Patterns

**Scores update automatically when:**
- User enters new data
- Clinician enters new lab results
- Weekly batch calculation runs (Sunday night)

**Mobile app should:**
- Show last cached data immediately
- Refresh in background on app open
- Allow manual pull-to-refresh
- Subscribe to realtime updates (optional)

### 5. Handling Missing Data

Not all users will have:
- Complete biomarker panels
- All biometric measurements
- Answered all survey questions

**UI should:**
- Show "No data" gracefully
- Encourage data entry
- Explain why metric is important

---

## Quick Reference: Common Queries

### Get Overall Score
```swift
let score: [WellPathScoreOverall] = try await supabase
    .from("patient_wellpath_score_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .limit(1)
    .execute()
    .value
```

### Get All Pillar Scores
```swift
let pillars: [PillarScore] = try await supabase
    .from("patient_wellpath_score_by_pillar")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .order("pillar_name", ascending: true)
    .execute()
    .value
```

### Get Biomarkers for a Pillar
```swift
let biomarkers: [BiomarkerScore] = try await supabase
    .from("patient_biomarker_scores_by_pillar")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .eq("pillar_name", value: "Healthful Nutrition")
    .order("weight_in_pillar", ascending: false)
    .execute()
    .value
```

### Get Score History (30 days)
```swift
let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
let dateString = ISO8601DateFormatter().string(from: thirtyDaysAgo)

let history: [WellPathScoreHistory] = try await supabase
    .from("patient_wellpath_score_history_overall")
    .select()
    .eq("patient_id", value: userId.uuidString)
    .gte("calculated_at", value: dateString)
    .order("calculated_at", ascending: true)
    .execute()
    .value
```

### Insert Biometric Reading
```swift
try await supabase
    .from("patient_marker_values_history")
    .insert([
        "patient_id": userId.uuidString,
        "marker_type": "biometric",
        "marker_name": "Weight",
        "marker_value": 185.5,
        "marker_unit": "lbs",
        "data_source": "wellpath_app",
        "reading_date": ISO8601DateFormatter().string(from: Date())
    ])
    .execute()
```

---

## Questions or Issues?

If you encounter:
- Missing views or tables
- Unexpected null values
- Performance issues
- RLS permission errors

Contact the backend team with:
- The query you're running
- The error message
- Which screen/feature you're building

---

**End of Guide**
