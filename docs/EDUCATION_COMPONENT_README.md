# WellPath Education Component

## Overview

The education component is the final piece of the WellPath scoring system, allowing patients to earn up to **10% per pillar** by engaging with educational content. This brings the total possible score to **100%** per pillar.

## Scoring Breakdown

| Component | Contribution |
|-----------|--------------|
| **Survey** | Variable (based on responses) |
| **Biomarkers** | Variable (based on lab results) |
| **Education** | Up to 10% (4 articles × 2.5%) |
| **Total Max** | **100%** |

## Database Schema

### Tables Created

**`education_articles`** - Catalog of 28 educational articles (4 per pillar)
```sql
- id (TEXT): Article identifier (e.g., "cognitive-health-sleep-quality")
- pillar (TEXT): Associated pillar
- title (TEXT): Article title
- description (TEXT): Brief description
- content_url (TEXT): Path/URL to article content
- min_engagement_seconds (INTEGER): Minimum time to count as viewed (default: 30s)
```

**`education_engagement`** - Tracks patient article views
```sql
- patient_id (UUID): References patient_details(id)
- article_id (TEXT): References education_articles(id)
- pillar (TEXT): Denormalized for faster queries
- viewed_at (TIMESTAMP): When article was first viewed
- time_spent_seconds (INTEGER): Total time spent reading
- scroll_percentage (INTEGER): 0-100, how far they scrolled
- completed (BOOLEAN): True if scroll >= 80% or time >= min_engagement
```

## Article Catalog

### Cognitive Health (4 articles)
1. How Sleep Impacts Cognitive Function
2. Brain Training Exercises That Work
3. Foods That Boost Brain Power
4. The Power of Lifelong Learning

### Connection + Purpose (4 articles)
1. Building Meaningful Social Connections
2. Finding Your Life Purpose
3. The Power of Community Engagement
4. Nurturing Deep Relationships

### Core Care (4 articles)
1. The Importance of Preventive Care
2. Managing Medications Safely
3. Understanding Substance Use and Health
4. Age-Appropriate Health Screenings

### Healthful Nutrition (4 articles)
1. The Power of Whole Foods
2. Plant-Based Eating Benefits
3. Effective Meal Planning Strategies
4. Mindful Eating Practices

### Movement + Exercise (4 articles)
1. Cardiovascular Exercise Essentials
2. Strength Training for All Ages
3. Flexibility and Mobility Work
4. The Power of Daily Movement

### Restorative Sleep (4 articles)
1. Sleep Hygiene Fundamentals
2. Understanding Your Circadian Rhythm
3. Common Sleep Disorders and Solutions
4. Sleep and Physical Recovery

### Stress Management (4 articles)
1. Mindfulness and Meditation Basics
2. Breathwork for Stress Relief
3. Building Stress Resilience
4. Effective Time and Energy Management

## API Endpoints

All endpoints are under `/api/v1/education/`

### GET `/articles`
Get all available articles, optionally filtered by pillar.

**Query Parameters:**
- `patient_id` (required): Patient UUID
- `pillar` (optional): Filter by pillar name

**Response:**
```json
[
  {
    "id": "cognitive-health-sleep-quality",
    "pillar": "Cognitive Health",
    "title": "How Sleep Impacts Cognitive Function",
    "description": "Learn about the crucial connection between quality sleep and brain health",
    "content_url": null,
    "viewed": false
  }
]
```

### GET `/articles/viewed`
Get articles the patient has already viewed.

**Query Parameters:**
- `patient_id` (required): Patient UUID
- `pillar` (optional): Filter by pillar name

**Response:**
```json
[
  {
    "id": "cognitive-health-sleep-quality",
    "pillar": "Cognitive Health",
    "title": "How Sleep Impacts Cognitive Function",
    "viewed_at": "2025-10-08T10:30:00Z",
    "time_spent_seconds": 120,
    "scroll_percentage": 95,
    "completed": true
  }
]
```

### POST `/engage`
Track patient engagement with an article.

**Request Body:**
```json
{
  "patient_id": "83a28af3-82ef-4ddb-8860-ac23275a5c32",
  "article_id": "cognitive-health-sleep-quality",
  "time_spent_seconds": 120,
  "scroll_percentage": 95,
  "completed": true
}
```

**Response:**
```json
{
  "message": "Engagement tracked successfully",
  "article_id": "cognitive-health-sleep-quality",
  "pillar": "Cognitive Health",
  "education_score": 5.0,
  "education_percentage": 50.0,
  "completed": true
}
```

### GET `/score/{patient_id}`
Get education scores for all pillars.

**Response:**
```json
{
  "Cognitive Health": 5.0,
  "Connection + Purpose": 0.0,
  "Core Care": 0.0,
  "Healthful Nutrition": 2.5,
  "Movement + Exercise": 2.5,
  "Restorative Sleep": 0.0,
  "Stress Management": 0.0
}
```

### GET `/score/{patient_id}/{pillar}`
Get detailed education score for a specific pillar.

**Response:**
```json
{
  "pillar": "Cognitive Health",
  "score": 5.0,
  "percentage": 50.0,
  "articles_viewed": 2,
  "articles_remaining": 2
}
```

### GET `/summary/{patient_id}`
Get comprehensive education engagement summary.

**Response:**
```json
{
  "total_articles_viewed": 4,
  "total_possible_articles": 28,
  "overall_education_percentage": 14.3,
  "pillars": {
    "Cognitive Health": {
      "score": 5.0,
      "max_score": 10.0,
      "percentage": 50.0,
      "articles_viewed": 2,
      "articles_remaining": 2
    }
    // ... other pillars
  }
}
```

## Python SDK Usage

```python
from database.postgres_client import PostgresClient
from scoring_engine.education_scorer import EducationScorer

# Initialize
db = PostgresClient()
scorer = EducationScorer(db)

# Get available articles
articles = scorer.get_available_articles(patient_id, pillar="Cognitive Health")

# Track engagement
db.execute_update("""
    INSERT INTO education_engagement (patient_id, article_id, pillar, time_spent_seconds, scroll_percentage, completed)
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (patient_id, article_id) DO UPDATE
    SET time_spent_seconds = GREATEST(education_engagement.time_spent_seconds, EXCLUDED.time_spent_seconds),
        scroll_percentage = GREATEST(education_engagement.scroll_percentage, EXCLUDED.scroll_percentage)
""", (patient_id, article_id, pillar, 120, 95, True))

# Get scores
all_scores = scorer.get_all_education_scores(patient_id)
pillar_score = scorer.get_education_score(patient_id, "Cognitive Health")
summary = scorer.get_education_summary(patient_id)
```

## Scoring Logic

### Requirements for "Viewed"
An article counts toward the education score if ANY of these conditions are met:
1. `time_spent_seconds` >= `min_engagement_seconds` (default 30s)
2. `scroll_percentage` >= 80%
3. `completed` = TRUE

### Points Calculation
- Each article viewed = **2.5 points** (2.5% of pillar score)
- Maximum 4 articles per pillar = **10 points** (10% of pillar score)
- Total maximum education score across all 7 pillars = 70 points

### Example Calculation
```
Patient views:
  - 2 Cognitive Health articles = 2 × 2.5 = 5.0 points (50% of max)
  - 1 Movement + Exercise article = 1 × 2.5 = 2.5 points (25% of max)
  - 1 Healthful Nutrition article = 1 × 2.5 = 2.5 points (25% of max)

Total education contribution: 10.0 points
Overall education percentage: 10.0 / 70.0 = 14.3%
```

## Frontend Integration

### When User Opens Article
```typescript
// Track initial view
await fetch('/api/v1/education/engage', {
  method: 'POST',
  body: JSON.stringify({
    patient_id: patientId,
    article_id: articleId,
    time_spent_seconds: 0,
    scroll_percentage: 0,
    completed: false
  })
});
```

### While User Reads (Every 30 seconds)
```typescript
// Update time spent
await fetch('/api/v1/education/engage', {
  method: 'POST',
  body: JSON.stringify({
    patient_id: patientId,
    article_id: articleId,
    time_spent_seconds: elapsedSeconds,
    scroll_percentage: currentScrollPercent,
    completed: currentScrollPercent >= 80
  })
});
```

### On Scroll
```typescript
// Update scroll progress
const scrollPercent = (scrollY / (documentHeight - windowHeight)) * 100;
```

## Next Steps (For Production)

1. **Create Article Content**
   - Write or source 28 educational articles
   - Add content to `content_url` field or store in separate content management system

2. **Add Content Management**
   - Admin interface to manage articles
   - Rich text editor for article content
   - Image/media upload

3. **Analytics**
   - Track most viewed articles
   - Measure average time spent
   - A/B test article effectiveness

4. **Gamification**
   - Badges for completing pillar articles
   - Streaks for consistent engagement
   - Leaderboards (optional)

## Migration

The database schema is already created and seeded with 28 article placeholders. Run:
```bash
PGPASSWORD='...' psql -h ... -d postgres -f supabase/migrations/create_education_tracking.sql
```

## Testing

Run the test script:
```bash
python scripts/test_education_api.py
```

Expected output shows:
- 28 articles available
- Simulated views tracked
- Scores calculated correctly
- Summary generated

## Complete Scoring Example

For a patient with:
- **Survey score**: 60%
- **Biomarker score**: 25%
- **Education score**: 10% (4 articles viewed)

**Total WellPath Score**: 60% + 25% + 10% = **95%**

The education component bridges the gap to help patients reach 100%!
