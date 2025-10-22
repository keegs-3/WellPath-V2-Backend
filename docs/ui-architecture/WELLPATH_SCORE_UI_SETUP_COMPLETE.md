# WellPath Score UI - Setup Complete ✅

## Summary

Successfully created and populated the WellPath Score UI database architecture - a flexible content management system for displaying detailed score breakdowns in the mobile app.

---

## What Was Built

### 1. Database Schema (4 Tables)

#### `wellpath_score_display_sections` - UI Hierarchy
- **Purpose**: Defines the navigation structure (like display_screens for tracking)
- **Features**: Hierarchical sections with parent-child relationships, aggregation rules
- **Rows Created**: 19 sections
  - 7 core pillars (Core Care, Nutrition, Movement, Sleep, Stress, Cognitive, Connection)
  - 1 cross-pillar view (Behaviors)
  - 11 sub-sections (Substances, Movement, Sleep under Behaviors + Core Care components)

#### `wellpath_score_display_items` - Individual Items
- **Purpose**: Defines items within sections (like display_metrics for tracking)
- **Features**: Biomarkers, biometrics, questions, functions
- **Rows Created**: 7 items
  - 3 alcohol survey questions (8.05, 8.06, 8.07)
  - 4 biomarker examples (LDL, HDL, Triglycerides, HbA1c)

#### `wellpath_score_question_content` - Question Details
- **Purpose**: Rich content for survey questions
- **Features**: Explanation, why it matters, alternative responses with tips/impact
- **Rows Created**: 1 question (8.05 - Alcohol consumption)
  - 5 alternative responses (Never, Minimal, Light, Moderate, Heavy)
  - Each with score, longevity impact, tips, severity level

#### `patient_wellpath_score_display` - Patient Data (Query Table)
- **Purpose**: Main table for app queries - combines calculated scores with UI config
- **Features**: Overall score, section scores, item scores with patient data
- **Rows Created**: 0 (will be populated by Edge Function)

### 2. Helper Functions

#### `get_latest_score_display(user_id)`
Returns the complete latest score display for a user

#### `get_section_hierarchy(user_id, parent_section_key)`
Returns all child sections under a parent (for navigation)

#### `get_section_items(user_id, section_key)`
Returns all items within a section with patient scores

---

## Example UI Flow

### Screen 1: Home
```
Your WellPath Score: 90.0%

Core Care: 89.6% →
Healthful Nutrition: 90.0% →
Movement + Exercise: 90.0% →
Restorative Sleep: 89.0% →
Stress Management: 90.0% →
Cognitive Health: 100.0% →
Connection + Purpose: 100.0% →
Behaviors: 58.2% →
```

### Screen 2: Behaviors (user tapped from home)
```sql
SELECT * FROM get_section_hierarchy('user-id', 'behaviors');
```
```
← Back to Home

Behaviors: 58.2%
Your daily habits and lifestyle choices

Substance Use: 45.3% →
Physical Activity: 76.5% →
Sleep Habits: 68.1% →
```

### Screen 3: Substances (user tapped from Behaviors)
```sql
SELECT * FROM get_section_hierarchy('user-id', 'behaviors_substances');
```
```
← Back to Behaviors

Substance Use: 45.3%
Alcohol, tobacco, and other substances

Alcohol: 60.0% →
Tobacco: 100.0% →
Nicotine (Vaping): 80.0% →
Recreational Drugs: 100.0% →
OTC Medications: 90.0% →
```

### Screen 4: Alcohol Detail (user tapped from Substances)
```sql
SELECT * FROM get_section_items('user-id', 'behaviors_substances_alcohol');
SELECT * FROM wellpath_score_question_content WHERE question_number = '8.05';
```
```
← Back to Substances

Alcohol: 60.0%
Your alcohol consumption patterns

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Your Current Pattern:
Current Use: Light (3-6 drinks per week)
Score: 7/10 (70%)

Quick Tips:
• Consider having 2-3 alcohol-free days per week
• Avoid binge drinking episodes
• Stay hydrated when drinking

Longevity Impact:
Light drinking may have neutral to slightly positive cardiovascular
effects, but slightly increases cancer risk.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Compare Alternatives:

→ Never (Score: 10/10)
   "Avoiding alcohol completely eliminates alcohol-related health risks..."

→ Minimal (1-2 drinks/week) (Score: 9/10)
   "Very light drinking has minimal health impact..."

✓ Light (3-6 drinks/week) (Score: 7/10) ← You are here
   "Light drinking may have neutral to slightly positive cardiovascular..."

→ Moderate (7-14 drinks/week) (Score: 4/10)
   "Moderate drinking increases cancer risk..."

→ Heavy (15+ drinks/week) (Score: 0/10) ⚠️ Critical
   "Heavy drinking can reduce lifespan by 5-10 years..."
   Resources: National Helpline: 1-800-662-4357
```

---

## Verification Queries Run

### Check table row counts
```sql
SELECT 'Sections', COUNT(*) FROM wellpath_score_display_sections;
-- Result: 19 rows

SELECT 'Items', COUNT(*) FROM wellpath_score_display_items;
-- Result: 7 rows

SELECT 'Question Content', COUNT(*) FROM wellpath_score_question_content;
-- Result: 1 row
```

### Test hierarchy navigation
```sql
-- Top level
SELECT section_key, display_name FROM get_section_hierarchy('user-id', NULL);
-- Result: 8 sections (7 pillars + Behaviors)

-- Drill into Behaviors
SELECT section_key, display_name FROM get_section_hierarchy('user-id', 'behaviors');
-- Result: 3 sections (Substances, Movement, Sleep)

-- Drill into Substances
SELECT section_key, display_name FROM get_section_hierarchy('user-id', 'behaviors_substances');
-- Result: 5 substances (Alcohol, Tobacco, Nicotine, Recreational Drugs, OTC Meds)
```

### Test item retrieval
```sql
SELECT item_id, display_name FROM get_section_items('user-id', 'behaviors_substances_alcohol');
-- Result: 3 questions (8.05, 8.06, 8.07)
```

### Test question content
```sql
SELECT jsonb_object_keys(response_content) FROM wellpath_score_question_content WHERE question_number = '8.05';
-- Result: 5 alternatives (Never, Minimal, Light, Moderate, Heavy)
```

---

## Next Steps

### Phase 2: Update Edge Function (NEXT)
The Edge Function needs to:

1. **After calculating scores**, build the UI display data
2. **Calculate section scores** based on `aggregation_source` config
   - For pillars: Use existing pillar scores
   - For function_rollup: Sum the specified functions
   - For pillar_component: Filter pillar items by component type
3. **Build item_scores array** with patient data + content
4. **Insert into `patient_wellpath_score_display`**

Example pseudocode:
```typescript
// At end of Edge Function, after calculating pillarScores:

// 1. Load display sections config
const { data: sections } = await supabase
  .from('wellpath_score_display_sections')
  .select('*')

// 2. Calculate section scores based on aggregation rules
const sectionScores = calculateSectionScores(sections, pillarScores, scoredItems)

// 3. Build item scores with content
const { data: displayItems } = await supabase
  .from('wellpath_score_display_items')
  .select('*, content:wellpath_score_question_content(*)')

const itemScores = buildItemScores(scoredItems, displayItems, responses)

// 4. Save to patient_wellpath_score_display
await supabase
  .from('patient_wellpath_score_display')
  .insert({
    user_id: patient_id,
    overall_score: overallScore,
    section_scores: sectionScores,
    item_scores: itemScores,
    calculated_at: new Date()
  })
```

### Phase 3: Populate Content
- [ ] Add question content for all 100+ survey questions
- [ ] Add all biomarkers to display_items (137 biomarkers)
- [ ] Add all biometrics to display_items
- [ ] Populate quick tips for all sections
- [ ] Add longevity impact text for all items

### Phase 4: App Integration
- [ ] Create API endpoints using helper functions
- [ ] Build UI screens for score breakdown
- [ ] Implement drill-down navigation
- [ ] Add tap-through to existing chart screens

---

## Files Created/Modified

### New Migrations
- `supabase/migrations/20251016010000_create_wellpath_score_ui_tables.sql`
- `supabase/migrations/20251016020000_seed_wellpath_score_ui_data.sql`

### Documentation
- `WELLPATH_SCORE_UI_ARCHITECTURE.md` - Full architecture specification
- `WELLPATH_SCORE_UI_IMPLEMENTATION.md` - Implementation guide with examples
- `SCORE_DETAILS_AND_CONDITIONS.md` - Patient conditions and score storage approach

---

## Key Design Decisions

### Why This Architecture?

1. **Mirrors Tracking System** - Same pattern as display_screens/display_metrics
2. **Flexible UI** - Reorganize sections without changing scoring logic
3. **Content-Rich** - Tips, alternatives, impacts all in database
4. **Cross-Pillar Views** - "Behaviors" aggregates items from multiple pillars
5. **Fast Queries** - Pre-calculated scores, not computed on-the-fly
6. **Historical** - Can track how scores change over time

### Aggregation Types

- **pillar_component**: Pull from existing pillar calculation (markers, survey, education)
- **function_rollup**: Sum multiple survey functions (e.g., all substances)
- **custom**: Calculated by Edge Function using custom logic
- **weighted_average**: Weighted average of subsections
- **sum**: Simple sum of items

### JSONB Usage

- **section_scores**: Nested object with score/max/percentage for each section
- **item_scores**: Array of scored items with patient data and content
- **response_content**: Maps response text to detailed content (tips, impact, severity)
- **GIN indexes**: Enable fast querying of JSONB fields

---

## Benefits Achieved

✅ **Flexible** - Reorganize UI without touching scoring logic
✅ **Content-rich** - Tips, impacts, alternatives all in database
✅ **Cross-pillar views** - "Behaviors" pulls from multiple pillars
✅ **Historical** - Can track section changes over time
✅ **Fast** - Pre-calculated, not computed on-the-fly
✅ **Consistent** - Same pattern as tracking display system
✅ **Educational** - Shows alternatives and longevity impact
✅ **Actionable** - Quick tips for every item

---

## Status: Ready for Edge Function Integration

The database foundation is complete. The next step is updating the Edge Function to populate `patient_wellpath_score_display` with calculated scores and patient-specific content.
