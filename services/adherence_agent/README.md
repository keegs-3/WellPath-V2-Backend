# WellPath Agentic Adherence System

## Overview

The Agentic Adherence System replaces static, rule-based adherence tracking with intelligent AI agents that:
- **Automatically understand** what to measure from natural language goals
- **Score adherence** daily across all recommendations
- **Generate personalized nudges** dynamically based on context
- **Create adaptive challenges** for different situations (travel, injury, etc.)
- **Learn from outcomes** to improve recommendations over time

## Key Innovation: No Configuration Needed

Traditional adherence systems require extensive configuration mapping goals to metrics. Our agent **automatically understands**:

- "Get 10,000 steps daily" → Searches for step count data
- "Sleep 7-9 hours" → Searches for sleep duration
- "Eat 5 servings of vegetables" → Searches for food logs
- "Limit alcohol to 2 drinks/week" → Searches for alcohol entries

**No manual mapping. No configuration files. Just natural language.**

## Architecture

```
services/adherence_agent/
├── __init__.py                 # Package exports
├── agent.py                    # Core adherence scoring agent
├── context_builder.py          # Aggregates patient context
├── nudge_generator.py          # AI-generated nudges
├── challenge_creator.py        # AI-generated challenges
└── README.md                   # This file
```

## Components

### 1. AdherenceAgent (`agent.py`)

**Purpose**: Daily adherence scoring with AI intelligence

**Key Features**:
- Evaluates each recommendation individually
- Aggregates scores by pillar (movement, nutrition, sleep, etc.)
- Calculates overall adherence percentage
- Applies mode adjustments (travel, injury, illness)
- Stores all scores with transparent reasoning

**Usage**:
```python
from services.adherence_agent.agent import AdherenceAgent

agent = AdherenceAgent()
result = await agent.calculate_daily_scores(
    patient_id=UUID("..."),
    score_date=date.today()
)

# Returns:
# {
#   "overall_score": {"adherence_percentage": 78},
#   "pillar_scores": [...],
#   "recommendation_scores": [...]
# }
```

**How It Works**:
1. Fetches all active recommendations for patient
2. Gathers available patient data (biometrics, behaviors, events)
3. For each recommendation, asks Claude: "Given this goal and this data, what's the adherence score?"
4. Claude automatically identifies relevant metrics and calculates
5. Applies mode adjustments if needed
6. Stores scores hierarchically (recommendation → pillar → overall)

### 2. ContextBuilder (`context_builder.py`)

**Purpose**: Aggregate comprehensive patient context for AI decision-making

**Fetches**:
- Biomarker readings (out of optimal range markers)
- Biometric measurements (vitals, weight, etc.)
- Active recommendations and their history
- Behavioral data from tracked metrics
- Active modes (travel, injury, illness)
- Recent adherence scores and trends
- Engagement patterns

**Usage**:
```python
from services.adherence_agent.context_builder import ContextBuilder

builder = ContextBuilder()
context = await builder.build_full_context(
    patient_id=UUID("..."),
    as_of_date=date.today()
)

# Returns comprehensive context dictionary
```

### 3. NudgeGenerator (`nudge_generator.py`)

**Purpose**: Create personalized, dynamic nudges

**Replaces**: Static `nudge_base` table with AI-generated content

**Creates Nudges For**:
- Celebrating achievements (high adherence streaks)
- Supporting struggles (low adherence)
- Encouraging progress (improving trends)
- Mode-specific support (travel, injury)
- Biomarker concerns

**Usage**:
```python
from services.adherence_agent.nudge_generator import NudgeGenerator

generator = NudgeGenerator()
nudges = await generator.generate_nudges_for_patient(
    patient_id=UUID("..."),
    max_nudges=3
)

# Returns list of generated nudges with:
# - title, message, tone
# - trigger reason
# - personalization factors
```

**Example Nudge**:
```json
{
  "title": "You're Building Momentum!",
  "message": "Your adherence has improved 15% this week! That consistency you're showing with morning walks is making a real difference. Keep it up!",
  "tone": "celebratory",
  "nudge_type": "insight"
}
```

### 4. ChallengeCreator (`challenge_creator.py`)

**Purpose**: Create bite-sized, achievable challenges

**Replaces**: Static `challenges_base` table with AI-generated content

**Creates Challenges When**:
- User is struggling (needs a quick win)
- User is in special mode (travel, injury) - creates adapted challenges
- User is high performer (ready to level up)
- Specific trigger (injury, motivation dip)

**Usage**:
```python
from services.adherence_agent.challenge_creator import ChallengeCreator

creator = ChallengeCreator()
challenge = await creator.create_challenge_for_patient(
    patient_id=UUID("..."),
    trigger_context={"type": "travel", "destination": "Business trip"}
)

# Returns challenge with:
# - title, description, goal
# - difficulty level (1-3)
# - duration (3-14 days)
# - context factors
```

**Example Challenge**:
```json
{
  "title": "Travel Wellness Challenge",
  "description": "Business trips don't have to derail your health. This challenge focuses on hotel-friendly movement.",
  "goal": "Walk 15 minutes after each meal, 3 times during your trip",
  "difficulty_level": 1,
  "duration_days": 5
}
```

## Database Schema

The system adds these new tables:

**Scoring Tables**:
- `agent_adherence_scores` - Individual recommendation scores
- `agent_pillar_scores` - Pillar aggregations
- `agent_overall_scores` - Overall daily scores

**Mode Management**:
- `patient_modes` - Track user modes (travel, injury, etc.)

**Agent-Generated Content**:
- `agent_nudges` - Dynamic nudges
- `agent_challenges` - Dynamic challenges

**Learning & Context**:
- `agent_user_context` - Aggregated patient context
- `agent_research_knowledge` - Evidence base
- `agent_recommendation_outcomes` - Learning from results
- `agent_execution_log` - Monitoring and debugging

**Extended Tables**:
- `recommendations_base` - Added `agent_goal`, `agent_context`, `agent_enabled`
- `patient_recommendations` - Added `personal_target`, `agent_notes`, `last_agent_evaluation`

## API Endpoints

### Scoring
- `POST /api/v1/adherence/calculate-daily` - Calculate daily scores
- `GET /api/v1/adherence/scores/{patient_id}/{date}` - Get scores for date
- `GET /api/v1/adherence/history/{patient_id}` - Get adherence history

### Modes
- `POST /api/v1/adherence/modes/set` - Set patient mode
- `GET /api/v1/adherence/modes/active/{patient_id}` - Get active modes
- `DELETE /api/v1/adherence/modes/{mode_id}` - End mode

### Nudges
- `POST /api/v1/adherence/nudges/generate` - Generate nudges
- `GET /api/v1/adherence/nudges/pending/{patient_id}` - Get pending nudges
- `POST /api/v1/adherence/nudges/{nudge_id}/delivered` - Mark delivered

### Challenges
- `POST /api/v1/adherence/challenges/create` - Create challenge
- `GET /api/v1/adherence/challenges/{patient_id}` - Get challenges
- `PATCH /api/v1/adherence/challenges/{challenge_id}/progress` - Update progress

### Insights
- `GET /api/v1/adherence/insights/{patient_id}` - Get comprehensive insights

## Daily Scoring Flow

```
1. Cron job triggers → POST /api/v1/adherence/calculate-daily
2. Agent fetches patient context
3. Agent scores each recommendation:
   - Parses goal ("10,000 steps daily")
   - Searches patient data for relevant metrics
   - Calculates adherence %
   - Applies mode adjustments
4. Aggregates by pillar
5. Calculates overall score
6. Stores all scores in database
7. Mobile app fetches updated scores
```

## Example Workflow

### Patient Starts Traveling

1. Patient sets travel mode via mobile app:
```
POST /api/v1/adherence/modes/set
{
  "patient_id": "...",
  "mode_type": "travel",
  "start_date": "2025-11-05",
  "notes": "Business trip to NYC"
}
```

2. Daily scoring automatically adjusts expectations

3. Agent generates travel-specific nudge:
```
"Hotel gym or walking meetings? Either works!
Your step goal is reduced to 7,000 while traveling."
```

4. Agent creates travel challenge:
```
"NYC Walking Challenge: Explore one new neighborhood
on foot each day of your trip (3 days)"
```

### Patient Struggling with Adherence

1. Daily scoring detects < 50% adherence for 3 days

2. Agent generates supportive nudge:
```
"It's okay to have tough days. Let's start small:
just 10 minutes of movement today. You've got this."
```

3. Agent creates quick-win challenge:
```
"3-Day Momentum Builder: Complete any form of
movement for 10 minutes, 3 days in a row"
```

## Configuration

### Environment Variables
```bash
ANTHROPIC_API_KEY=sk-ant-...  # Required for agent
SUPABASE_URL=https://...      # Database
DB_PASSWORD=...               # Database password
```

### Recommendation Setup

For agents to work, recommendations need an `agent_goal`:

```sql
UPDATE recommendations_base
SET agent_goal = 'Get 10,000 steps daily',
    agent_enabled = true
WHERE rec_id = 'REC001';
```

Optional `agent_context` for special cases:
```sql
UPDATE recommendations_base
SET agent_context = '{
  "allow_partial_credit": true,
  "special_considerations": ["counts cycling at 2x rate"]
}'
WHERE rec_id = 'REC002';
```

## Testing

### Run Daily Scoring
```bash
curl -X POST http://localhost:8000/api/v1/adherence/calculate-daily \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "00000000-0000-0000-0000-000000000001",
    "score_date": "2025-11-01"
  }'
```

### Generate Nudges
```bash
curl -X POST http://localhost:8000/api/v1/adherence/nudges/generate \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "00000000-0000-0000-0000-000000000001",
    "max_nudges": 3
  }'
```

### Create Challenge
```bash
curl -X POST http://localhost:8000/api/v1/adherence/challenges/create \
  -H "Content-Type: application/json" \
  -d '{
    "patient_id": "00000000-0000-0000-0000-000000000001"
  }'
```

## Performance

- Daily scoring: < 30 seconds per patient
- Individual recommendation scoring: < 2 seconds
- Nudge generation: < 3 seconds per nudge
- Challenge creation: < 5 seconds

## Token Usage & Cost

Average per patient per day:
- Daily scoring: ~15,000 tokens (~$0.03)
- 3 nudges: ~3,000 tokens (~$0.006)
- 1 challenge: ~2,000 tokens (~$0.004)

**Total: ~$0.04/patient/day**

With 1,000 patients: ~$40/day = $1,200/month

## Monitoring

Check agent execution logs:
```sql
SELECT
  agent_type,
  status,
  COUNT(*),
  AVG(duration_ms)
FROM agent_execution_log
WHERE created_at >= CURRENT_DATE
GROUP BY agent_type, status;
```

## Future Enhancements

1. **Knowledge Base**: Integrate research papers for evidence-based nudges
2. **Outcome Learning**: Track which recommendations improve which biomarkers
3. **Vectorization**: Use embeddings for similarity search (requires pgvector)
4. **Clinician Dashboard**: Aggregate patient adherence for providers
5. **Recommendation Auto-assignment**: Agent suggests recommendations based on biomarkers

## Deprecation Plan

These tables will eventually be deprecated:
- `nudge_base` → Replaced by `agent_nudges`
- `challenges_base` → Replaced by `agent_challenges`
- `trigger_conditions_*` → Replaced by agent logic
- `adherence_scores` → Replaced by `agent_adherence_scores`

See `database/migrations/AGENTIC_MIGRATION_PLAN.md` for details.

## Support

For issues or questions:
1. Check `agent_execution_log` for errors
2. Review agent reasoning in score tables
3. Check Claude API limits and usage
4. Validate patient has active recommendations with `agent_goal` set

---

**Built with Claude by Anthropic** 🤖
