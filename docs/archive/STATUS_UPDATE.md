# WellPath V2 Scoring Status Update

## What's Working

✅ **Individual component breakdowns** - API now returns detailed biomarker and survey question data
✅ **Substance use scoring** - All 6 substances scoring correctly (43/49 points = 87.8%)
✅ **Basic survey scoring** - Regular QUESTION_CONFIG questions working
✅ **Sleep apnea complex calculation** - Added handler for `complex_calc` field
✅ **Overall accuracy** - 62.81% vs 59.4% GT (+3.41%, within acceptable range)

## Current Gaps

### Core Care Survey: Still Missing 83 Points

**Current**: 274.40 / 304.00
**Ground Truth**: 357.30 / 385.00
**Gap**: -82.90 raw, -81.00 max

### Analysis of What's Been Added:
- Substance scoring: **+43/49 points** ✅ (working)
- Sleep protocols (4.07): **+9.0 max** (needs verification)
- Movement pillar: **Unknown max** (needs verification)
- Sleep issues (4.12): **+8.0 max** (needs verification)

### What's Likely Missing (81 max points):

The 81-point max gap suggests major scoring components aren't executing. Candidates:

1. **Movement pillar scoring** may have bugs in my implementation
2. **Sleep issues scoring** may have bugs
3. **Sleep protocols scoring** may not be executing
4. **Other complex scoring** not yet identified

## Key Files

**Source of Truth (CSV-based)**:
- `scripts/wellpath_score_runner_survey_v2.py` - Lines 3001-3032 show ALL custom scoring

**Database-Driven (What needs to match)**:
- `scoring_engine/survey_scorer.py` - Lines 701-845 attempt to replicate custom scoring

## Next Steps

1. **Debug the custom scoring sections** - Add print statements to see which ones execute
2. **Compare question counts** - API has 42 Core Care questions, need to verify GT has more
3. **Check if movement/sleep scoring is actually running** - Functions exist but may have errors
4. **Run the CSV-based script** on same data to generate exact output for comparison

## Critical Insight

The database-driven scorer must execute THE EXACT SAME LOGIC as the CSV-based scorer. All 4 custom scoring functions from the original script (lines 3001-3032) need to:
1. Be called with the correct data format
2. Return scores in the same structure
3. Add scores to pillar_totals the same way

Currently substance scoring works perfectly, but movement/sleep scoring may have implementation bugs preventing them from contributing their points.
