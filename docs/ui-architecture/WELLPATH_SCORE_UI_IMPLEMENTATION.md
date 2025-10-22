# WellPath Score UI - Implementation Guide

## What We Just Created

### 1. Database Schema (Migration: `20251016010000`)
- `wellpath_score_display_sections` - UI hierarchy (pillars, categories, groups)
- `wellpath_score_display_items` - Individual items within sections
- `wellpath_score_question_content` - Content for questions (tips, alternatives, impact)
- `patient_wellpath_score_display` - Patient-specific calculated data (what the app queries)

### 2. Seed Data (Migration: `20251016020000`)
- 7 core pillars
- "Behaviors" cross-pillar view
- Substances section with 5 substance types (alcohol, tobacco, nicotine, recreational drugs, OTC meds)
- Example biomarkers in Core Care
- Example alcohol question content with alternative responses

---

## Next Steps

### Phase 1: Run Migrations ✅ COMPLETE
```bash
# Migrations have been successfully run!
# Tables created: 19 sections, 7 items, 1 question content entry
# Helper functions: get_latest_score_display, get_section_hierarchy, get_section_items
```

**Verified:**
- ✅ All 4 tables created successfully
- ✅ 19 sections populated (7 pillars + Behaviors hierarchy)
- ✅ 7 display items (3 alcohol questions + 4 biomarker examples)
- ✅ 1 question content (alcohol question 8.05 with 5 alternative responses)
- ✅ Helper functions working correctly
- ✅ Hierarchy navigation tested: Home → Behaviors → Substances → Alcohol

### Phase 2: Update Edge Function
The Edge Function needs to:

1. **After calculating scores**, build the UI display data
2. **Calculate section scores** based on aggregation_source
3. **Build item_scores array** with patient data + content
4. **Insert into `patient_wellpath_score_display`**

Example pseudocode:
```typescript
// At end of Edge Function, after calculating pillarScores:

// 1. Load display sections config
const { data: sections } = await supabase
  .from('wellpath_scoring_display_sections')
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

### Phase 3: App Integration

#### Query Examples

**Home Screen - Show all top-level sections:**
```typescript
const { data, error } = await supabase
  .rpc('get_section_hierarchy', {
    p_user_id: userId,
    p_parent_section_key: null
  })

// Returns: Pillars + Behaviors with scores
// [
//   { section_key: 'pillar_core_care', display_name: 'Core Care', score: {...} },
//   { section_key: 'behaviors', display_name: 'Behaviors', score: {...} },
//   ...
// ]
```

**Drill into "Behaviors":**
```typescript
const { data, error } = await supabase
  .rpc('get_section_hierarchy', {
    p_user_id: userId,
    p_parent_section_key: 'behaviors'
  })

// Returns: Substances, Movement, Sleep subsections with scores
```

**Show items in "Alcohol" section:**
```typescript
const { data, error } = await supabase
  .rpc('get_section_items', {
    p_user_id: userId,
    p_section_key: 'behaviors_substances_alcohol'
  })

// Returns: All questions/functions for alcohol with patient's scores
```

**Get question details with alternatives:**
```typescript
const { data, error } = await supabase
  .from('wellpath_score_question_content')
  .select('*')
  .eq('question_number', '8.05')
  .single()

// Access alternative responses:
const alternatives = data.response_content
// {
//   "Never": { score: 1.0, tips: [...], longevity_impact: "..." },
//   "Heavy (15+ drinks per week)": { score: 0.0, tips: [...], severity: "critical" }
// }
```

---

## UI Flow Example

### Screen 1: Home
```
Your WellPath Score: 89.9%

Core Care: 89.6% →
Healthful Nutrition: 90.0% →
Movement + Exercise: 90.0% →
...
Behaviors: 58.2% →
```

### Screen 2: Behaviors (tapped from home)
```
← Back to Home

Behaviors: 58.2%
Your daily habits and lifestyle choices

Substances: 45.3% →
Physical Activity: 76.5% →
Sleep Habits: 68.1% →
```

### Screen 3: Substances (tapped from Behaviors)
```
← Back to Behaviors

Substances: 45.3%
Alcohol, tobacco, and other substances

Quick Tips:
• Limit alcohol to 1-2 drinks per day
• Quit tobacco - it's the single best thing for your health
• ...

Longevity Impact:
Substance use is one of the most significant modifiable risk factors...

Alcohol: 60.0% →
Tobacco: 100.0% →
Nicotine (Vaping): 80.0% →
Recreational Drugs: 100.0% →
OTC Medications: 90.0% →
```

### Screen 4: Alcohol (tapped from Substances)
```
← Back to Substances

Alcohol: 60.0%
Your alcohol consumption patterns

Your Current Pattern:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Current Use: Light (3-6 drinks per week)
Score: 7/10 (70%)
Your Answer Impact: "Light drinking may have neutral to slightly positive
cardiovascular effects, but slightly increases cancer risk"

Duration: 3-5 years
Trend: Stable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Quick Tips:
• Consider having 2-3 alcohol-free days per week
• Avoid binge drinking episodes
• Stay hydrated when drinking

Longevity Impact:
Light drinking (3-6 drinks/week) has minimal impact...

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

### Screen 5: Core Care Biomarkers
```
← Back to Core Care

Biomarkers: 137/137 (100%)
Lab test results and key health indicators

LDL Cholesterol: 7/7 ✓ [Tap to view chart] →
  85 mg/dL (Optimal)
  Last tested: Sep 15, 2024

HDL Cholesterol: 6/6 ✓ [Tap to view chart] →
  65 mg/dL (Optimal)
  Last tested: Sep 15, 2024

Triglycerides: 6/6 ✓ [Tap to view chart] →
  ...
```

---

## Content Management

### Adding New Sections
```sql
INSERT INTO wellpath_score_display_sections
(section_key, parent_section_key, display_name, section_type, aggregation_type, aggregation_source)
VALUES
('new_section', 'parent_key', 'Display Name', 'category', 'function_rollup',
 '{"source_type": "functions", "function_names": ["func1", "func2"]}'::jsonb);
```

### Adding Content to Questions
```sql
INSERT INTO wellpath_score_question_content
(question_number, explanation, why_it_matters, response_content)
VALUES
('8.05', 'Explanation...', 'Why it matters...',
 '{
   "Response Option 1": {
     "score": 1.0,
     "tips": ["tip1", "tip2"],
     "longevity_impact": "...",
     "severity": "optimal"
   }
 }'::jsonb);
```

### Reorganizing Hierarchy
Just update `parent_section_key` and `display_order`:
```sql
UPDATE wellpath_score_display_sections
SET parent_section_key = 'new_parent', display_order = 3
WHERE section_key = 'section_to_move';
```

---

## Benefits

✅ **Flexible** - Reorganize UI without touching scoring logic
✅ **Content-rich** - Tips, impacts, alternatives all in database
✅ **Cross-pillar views** - "Behaviors" pulls from multiple pillars
✅ **Historical** - Can track how sections change over time
✅ **Fast** - Pre-calculated, not computed on-the-fly
✅ **Consistent** - Same pattern as tracking display system

---

## TODO

- [ ] Run migrations
- [ ] Update Edge Function to populate `patient_wellpath_score_display`
- [ ] Finish populating content for all questions
- [ ] Add all biomarkers/biometrics to display_items
- [ ] Create app screens using the helper functions
- [ ] Add condition filtering (CKD, athlete, etc.) - separate task
