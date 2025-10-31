# Agentic Adherence System - Migration Plan

## Overview
This document outlines the database migration strategy for the new agentic adherence system, including tables to keep, extend, deprecate, and create new.

## Tables to KEEP and EXTEND

### 1. `recommendations_base` - EXTEND
**Status**: Keep and enhance with agent fields
**New Columns**:
- `agent_goal` TEXT - Natural language goal for agent
- `agent_context` JSONB - Optional hints for edge cases
- `agent_enabled` BOOLEAN - Whether to use agent scoring

**Rationale**: This is the core recommendations table with biomarker/biometric mappings. We extend it rather than replace it to preserve all existing relationships and data.

### 2. `patient_recommendations` - EXTEND
**Status**: Keep and enhance
**New Columns**:
- `personal_target` JSONB - User-specific goal adjustments
- `agent_notes` TEXT - Agent observations
- `last_agent_evaluation` TIMESTAMPTZ - Last evaluation timestamp

**Rationale**: Tracks which recommendations are assigned to patients. We add agent-specific fields for personalization.

### 3. `biomarkers_base` - KEEP AS IS
**Status**: No changes needed
**Usage**: Agent uses existing biomarker data and ranges for context

### 4. `biometrics_base` - KEEP AS IS
**Status**: No changes needed
**Usage**: Agent uses existing biometric data for context

### 5. `patient_biomarker_readings` - KEEP AS IS
**Status**: No changes needed
**Usage**: Primary data source for agent evaluations

### 6. `patient_biometric_readings` - KEEP AS IS
**Status**: No changes needed
**Usage**: Primary data source for agent evaluations

### 7. `patient_behavioral_values` - KEEP AS IS
**Status**: No changes needed
**Usage**: Tracked metrics data source

### 8. `patient_survey_responses` - KEEP AS IS
**Status**: No changes needed
**Usage**: Initial assessment data for agent context

### 9. `patients` - KEEP AS IS
**Status**: No changes needed
**Usage**: Patient master table

### 10. `pillars_base` - KEEP AS IS
**Status**: No changes needed
**Usage**: For pillar-level score aggregation

## Tables to DEPRECATE (Eventually)

### 1. `nudge_base` - DEPRECATE AFTER MIGRATION
**Replacement**: `agent_nudges`
**Migration Strategy**:
1. Keep table for 3-6 months during transition
2. Agent can reference old nudges for content inspiration
3. New nudges go to `agent_nudges` table
4. Eventually drop when all content migrated

**Rationale**: Static nudge library is too rigid. Agent generates personalized nudges dynamically.

### 2. `challenges_base` - DEPRECATE AFTER MIGRATION
**Replacement**: `agent_challenges`
**Migration Strategy**:
1. Keep table for reference
2. Agent can learn from successful challenge patterns
3. New challenges go to `agent_challenges`
4. Drop after 6 months

**Rationale**: Agents create challenges dynamically based on patient context (travel, injury, motivation dips).

### 3. `trigger_conditions_base` + related tables - EVALUATE FOR DEPRECATION
**Tables**:
- `trigger_conditions_base`
- `trigger_conditions_nudges`
- `trigger_conditions_challenges`
- `trigger_conditions_checkins`
- `trigger_groups`

**Replacement**: Agent decision-making logic
**Migration Strategy**:
1. Keep for now - has valuable ai_intent data
2. Agent references these for trigger patterns
3. Gradually move to pure agent logic
4. Eventual deprecation TBD (6-12 months)

**Rationale**: Rule-based triggers replaced by intelligent agent decisions. However, the ai_intent fields are valuable.

### 4. `recommendations_nudges` junction - DEPRECATE
**Replacement**: Agent generates nudges per patient recommendation dynamically
**Migration**: Can drop after agent system is stable

### 5. `recommendations_challenges` junction - DEPRECATE
**Replacement**: Agent creates challenges dynamically
**Migration**: Can drop after agent system is stable

### 6. `adherence_scores` - EVALUATE
**Current State**: Existing adherence tracking
**Replacement**: `agent_adherence_scores`
**Migration Strategy**:
1. Keep both temporarily for comparison
2. Run agent and old system in parallel
3. Validate agent scores match or exceed old system quality
4. Deprecate old table after validation period (1-2 months)

## Tables to CREATE (New Agent Infrastructure)

### 1. `agent_adherence_scores` - NEW
**Purpose**: Individual recommendation adherence scores calculated by agent
**Key Features**:
- Hierarchical scoring (recommendation → pillar → overall)
- Transparent reasoning
- Confidence scores
- Data source tracking

### 2. `agent_pillar_scores` - NEW
**Purpose**: Aggregated pillar-level scores
**Key Features**:
- Rolls up recommendation scores
- Tracks component breakdowns

### 3. `agent_overall_scores` - NEW
**Purpose**: Overall daily adherence scores
**Key Features**:
- Top-level patient adherence
- Pillar breakdown
- Mode awareness

### 4. `patient_modes` - NEW
**Purpose**: Track user modes (travel, injury, illness, stress)
**Key Features**:
- Date ranges
- Mode-specific configurations
- Automatic mode adjustments

### 5. `agent_nudges` - NEW
**Purpose**: AI-generated personalized nudges
**Key Features**:
- Dynamic content generation
- Trigger reasoning
- User response tracking

### 6. `agent_challenges` - NEW
**Purpose**: AI-generated contextual challenges
**Key Features**:
- Situation-aware (travel, injury, etc.)
- Bite-sized achievable goals
- Progress tracking

### 7. `agent_user_context` - NEW
**Purpose**: Aggregated user context for agent decisions
**Key Features**:
- Behavioral patterns
- Engagement times
- Capacity assessment

### 8. `agent_research_knowledge` - NEW
**Purpose**: Evidence-based knowledge for agent reasoning
**Key Features**:
- Research paper storage
- Biomarker/biometric mapping
- Quality scoring

### 9. `agent_recommendation_outcomes` - NEW
**Purpose**: Learning system for recommendation effectiveness
**Key Features**:
- Tracks biomarker changes
- Attribution confidence
- Outcome analysis

### 10. `agent_execution_log` - NEW
**Purpose**: Audit log for agent executions
**Key Features**:
- Performance monitoring
- Error tracking
- Cost tracking (token usage)

## Tables to KEEP AS IS (Check-ins)

### `checkin_base`, `checkin_questions`, etc. - KEEP
**Status**: No changes
**Usage**: Agents prompt check-ins but don't create them
**Rationale**: Check-ins require structured questions, charts, and specific formatting. Agents trigger them at appropriate times but don't generate the questions.

## Migration Phases

### Phase 1: Schema Extension (Week 1)
- Run `agentic_adherence_integration.sql` migration
- Extends `recommendations_base` and `patient_recommendations`
- Creates all new agent tables
- Zero impact on existing functionality

### Phase 2: Parallel Operation (Weeks 2-4)
- Run agent system alongside old system
- Compare scores and validate
- Old tables remain active
- Both systems write to respective tables

### Phase 3: Agent Takeover (Month 2)
- Make agent system primary
- Old adherence scoring becomes read-only
- Start deprecation warnings

### Phase 4: Cleanup (Months 3-6)
- Drop deprecated junction tables
- Archive old nudge/challenge content
- Drop old trigger condition tables (if validated)
- Migrate any valuable content to agent knowledge base

## Data Migration

### Valuable Content to Preserve

1. **Nudges** (`nudge_base`):
   - Export all nudge messages to JSON
   - Feed into agent as examples
   - Agent learns tone and messaging patterns

2. **Challenges** (`challenges_base`):
   - Export challenge library
   - Analyze successful challenge patterns
   - Use as training data for agent

3. **Triggers** (`trigger_conditions_base`):
   - Export ai_intent data
   - Use as agent decision patterns
   - Preserve valuable triggering logic

### SQL Export Script
```sql
-- Export nudges for agent learning
COPY (
  SELECT nudge_id, title, message, tone, type, level
  FROM nudge_base
  WHERE is_active = true
) TO '/tmp/nudges_export.json' WITH (FORMAT json);

-- Export challenges for agent learning
COPY (
  SELECT challenge_id, challenge_title, challenge_description, challenge_level
  FROM challenges_base
  WHERE is_active = true
) TO '/tmp/challenges_export.json' WITH (FORMAT json);

-- Export trigger conditions
COPY (
  SELECT condition_id, name, description, ai_context_tags_json
  FROM trigger_conditions_base
  WHERE is_active = true
) TO '/tmp/triggers_export.json' WITH (FORMAT json);
```

## Rollback Plan

If issues arise:

1. **Immediate Rollback** (Weeks 1-4):
   - Disable agent system via feature flag
   - Continue using old adherence_scores table
   - No data loss - all old tables intact

2. **Partial Rollback** (Months 2-3):
   - Can revert to old nudge/challenge system
   - Old tables still available
   - Agent scores preserved for analysis

3. **Full Rollback** (After Month 3):
   - Becomes more difficult
   - Would need to rebuild old trigger logic
   - Agent data would need manual migration back

## Risk Mitigation

1. **Parallel Running**: Both systems active for validation period
2. **Feature Flags**: Can toggle agent system on/off
3. **Data Preservation**: Keep old tables for 6+ months
4. **Gradual Deprecation**: No sudden drops, warnings first
5. **Rollback Plans**: Clear process for each phase

## Success Metrics

Before deprecating old tables:

1. **Scoring Quality**: Agent scores comparable or better
2. **Performance**: Daily scoring completes < 30s per patient
3. **User Satisfaction**: Nudges rated helpful > 60%
4. **Engagement**: Adherence tracking usage increases
5. **Error Rate**: < 5% agent failures
6. **Cost**: Token usage within budget

## Decision Points

### When to drop `adherence_scores`:
- [ ] Agent scores validated for 1 month
- [ ] User feedback positive
- [ ] Performance acceptable
- [ ] Error rate < 5%

### When to drop nudge/challenge tables:
- [ ] Agent-generated content quality exceeds static content
- [ ] All valuable content migrated to knowledge base
- [ ] 3 months of stable operation

### When to drop trigger tables:
- [ ] Agent decision-making proven effective
- [ ] No longer referencing trigger logic
- [ ] 6 months of stable operation

## Next Steps

1. ✅ Schema designed and documented
2. ⏳ Build agent system code
3. ⏳ Create API endpoints
4. ⏳ Test with sample data
5. ⏳ Run migration on staging database
6. ⏳ Parallel testing phase
7. ⏳ Production deployment
8. ⏳ Monitor and validate
9. ⏳ Begin deprecation process

---

## Questions for Team

1. Do we want to preserve ALL historical nudge/challenge content, or just successful ones?
2. What's the minimum validation period before deprecation?
3. Should we keep trigger_conditions tables longer for AI intent learning?
4. Any specific content from old tables that must be preserved?
5. Feature flag strategy - per patient, per practice, or global?
