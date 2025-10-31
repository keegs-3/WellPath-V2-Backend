# WellPath About Content Tables - Usage Guide

## Table Structure

### 1. `wellpath_score_about`
**Purpose:** Educational content explaining the overall WellPath Score system

**Columns:**
- `section_number` - Section identifier (1-4)
- `section_title` - Title of the section
- `section_content` - Full educational content
- `display_order` - Order to display sections
- `is_active` - Whether this section should be shown

**Mobile Query:**
```sql
SELECT section_title, section_content
FROM wellpath_score_about
WHERE is_active = true
ORDER BY display_order;
```

**Use Case:** Display on the "About WellPath Score" screen

---

### 2. `wellpath_pillars_about`
**Purpose:** General educational content about each pillar

**Columns:**
- `pillar_id` - FK to `pillars_base` (e.g., 'PILLAR_NUTRITION')
- `about_content` - Explanation of what this pillar measures
- `is_active` - Whether to show this content

**Mobile Query:**
```sql
-- Get about content for a specific pillar
SELECT about_content
FROM wellpath_pillars_about
WHERE pillar_id = 'PILLAR_NUTRITION'
AND is_active = true;

-- Get all pillar about content
SELECT p.pillar_name, pa.about_content
FROM wellpath_pillars_about pa
JOIN pillars_base p ON pa.pillar_id = p.pillar_id
WHERE pa.is_active = true
ORDER BY p.display_order;
```

**Use Case:** Display on each pillar detail screen

---

### 3. `wellpath_pillars_markers_about`
**Purpose:** Explains the biomarkers/biometrics component for each pillar

**Columns:**
- `pillar_id` - FK to `pillars_base`
- `section_title` - Optional section title
- `about_content` - Content explaining markers component
- `display_order` - Order to display multiple sections
- `is_active` - Whether to show this content

**Mobile Query:**
```sql
-- Get markers about content for a pillar
SELECT section_title, about_content
FROM wellpath_pillars_markers_about
WHERE pillar_id = 'PILLAR_NUTRITION'
AND is_active = true
ORDER BY display_order;
```

**Use Case:** Display on the "Biomarkers & Biometrics" tab/section of a pillar detail screen

---

### 4. `wellpath_pillars_behaviors_about`
**Purpose:** Explains the behaviors/self-assessment component for each pillar

**Columns:**
- `pillar_id` - FK to `pillars_base`
- `section_title` - Optional section title
- `about_content` - Content explaining behaviors component
- `display_order` - Order to display multiple sections
- `is_active` - Whether to show this content

**Mobile Query:**
```sql
-- Get behaviors about content for a pillar
SELECT section_title, about_content
FROM wellpath_pillars_behaviors_about
WHERE pillar_id = 'PILLAR_SLEEP'
AND is_active = true
ORDER BY display_order;
```

**Use Case:** Display on the "Behaviors & Assessment" tab/section of a pillar detail screen

---

### 5. `wellpath_pillars_education_about`
**Purpose:** Explains the education component for each pillar

**Columns:**
- `pillar_id` - FK to `pillars_base`
- `section_title` - Optional section title
- `about_content` - Content explaining education component
- `display_order` - Order to display multiple sections
- `is_active` - Whether to show this content

**Mobile Query:**
```sql
-- Get education about content for a pillar
SELECT section_title, about_content
FROM wellpath_pillars_education_about
WHERE pillar_id = 'PILLAR_MOVEMENT'
AND is_active = true
ORDER BY display_order;
```

**Use Case:** Display on the "Education" tab/section of a pillar detail screen

---

## Example Mobile Screens

### Screen 1: WellPath Score Overview
```
┌─────────────────────────────┐
│  WellPath Score: 98.6%      │
│  ───────────────────────    │
│  [About This Score]  ← Tap  │
└─────────────────────────────┘

When tapped, shows:
SELECT * FROM wellpath_score_about ORDER BY display_order
```

### Screen 2: Pillar Detail (e.g., Nutrition)
```
┌─────────────────────────────┐
│  Healthful Nutrition: 97.8% │
│  ───────────────────────    │
│  [About] [Markers] [Behaviors] [Education]
│                              │
│  Markers Tab:                │
│  SELECT * FROM               │
│  wellpath_pillars_markers_about
│  WHERE pillar_id = 'PILLAR_NUTRITION'
└─────────────────────────────┘
```

## Data Population

### Current Status
✅ `wellpath_score_about` - Populated with 4 sections
⚠️ `wellpath_pillars_about` - Empty (needs content for each pillar)
⚠️ `wellpath_pillars_markers_about` - Empty (needs content for each pillar)
⚠️ `wellpath_pillars_behaviors_about` - Empty (needs content for each pillar)
⚠️ `wellpath_pillars_education_about` - Empty (needs content for each pillar)

### To Populate Pillar-Specific Content

Example for Healthful Nutrition:

```sql
-- General pillar about
INSERT INTO wellpath_pillars_about (pillar_id, about_content) VALUES
('PILLAR_NUTRITION', 'Healthful Nutrition measures your dietary patterns...');

-- Markers component
INSERT INTO wellpath_pillars_markers_about (pillar_id, about_content, display_order) VALUES
('PILLAR_NUTRITION',
'The markers component uses 67 biomarkers including lipid panels, glucose metrics, vitamins, and minerals. These objective laboratory values make up 72% of your Nutrition pillar score.',
1);

-- Behaviors component
INSERT INTO wellpath_pillars_behaviors_about (pillar_id, about_content, display_order) VALUES
('PILLAR_NUTRITION',
'The behaviors component assesses your dietary habits through survey questions. This includes meal timing, food quality, portion control, and eating patterns. These self-reported behaviors contribute 18% to your Nutrition pillar score.',
1);

-- Education component
INSERT INTO wellpath_pillars_education_about (pillar_id, about_content, display_order) VALUES
('PILLAR_NUTRITION',
'Complete evidence-based learning modules covering nutrition science, meal planning, and dietary optimization. Education engagement contributes 10% to your Nutrition pillar score.',
1);
```

## Hierarchical Content Flow

```
WellPath Score (98.6%)
├── wellpath_score_about (4 sections)
│   └── Explains overall scoring methodology
│
└── 7 Pillars
    ├── Pillar: Healthful Nutrition (97.8%)
    │   ├── wellpath_pillars_about → General pillar explanation
    │   ├── Components:
    │   │   ├── Markers (72%) → wellpath_pillars_markers_about
    │   │   ├── Behaviors (18%) → wellpath_pillars_behaviors_about
    │   │   └── Education (10%) → wellpath_pillars_education_about
    │
    ├── Pillar: Movement + Exercise (97.2%)
    │   └── (same structure)
    ...
```

## Notes

- All tables have `is_active` flag for easy content management
- All component tables support multiple sections via `display_order`
- All pillar-related tables use FK to `pillars_base` for referential integrity
- RLS policies allow all authenticated users to read content
- Only service_role can modify content
