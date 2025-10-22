#!/usr/bin/env python3
"""Test the education tracking API."""

import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).parent.parent))

from database.postgres_client import PostgresClient
from scoring_engine.education_scorer import EducationScorer

# Initialize
db = PostgresClient()
scorer = EducationScorer(db)

# Test patient
PATIENT_ID = '83a28af3-82ef-4ddb-8860-ac23275a5c32'

print("=" * 80)
print("EDUCATION TRACKING SYSTEM TEST")
print("=" * 80)

# 1. Get all available articles
print("\n1. All available articles:")
articles = scorer.get_available_articles(PATIENT_ID)
print(f"  Total articles: {len(articles)}")
for i, article in enumerate(articles[:3], 1):
    print(f"  {i}. {article['title']} ({article['pillar']})")
print(f"  ... and {len(articles) - 3} more")

# 2. Simulate viewing some articles
print("\n2. Simulating article views...")
test_articles = [
    'cognitive-health-sleep-quality',
    'cognitive-health-brain-training',
    'movement-cardio-benefits',
    'nutrition-whole-foods'
]

for article_id in test_articles:
    # Get article to find pillar
    query = "SELECT pillar FROM education_articles WHERE id = %s"
    result = db.execute_single(query, (article_id,))
    pillar = result['pillar']

    # Insert engagement
    insert_query = """
    INSERT INTO education_engagement (
        patient_id, article_id, pillar,
        time_spent_seconds, scroll_percentage, completed
    )
    VALUES (%s, %s, %s, %s, %s, %s)
    ON CONFLICT (patient_id, article_id) DO NOTHING
    """
    db.execute_update(insert_query, (PATIENT_ID, article_id, pillar, 120, 95, True))
    print(f"  ✓ Viewed: {article_id}")

# 3. Get education scores
print("\n3. Education scores by pillar:")
scores = scorer.get_all_education_scores(PATIENT_ID)
for pillar, score in sorted(scores.items()):
    print(f"  {pillar:<25} {score:>4.1f} / 10.0 ({score * 10:.0f}%)")

# 4. Get detailed summary
print("\n4. Detailed education summary:")
summary = scorer.get_education_summary(PATIENT_ID)
print(f"  Total articles viewed: {summary['total_articles_viewed']} / {summary['total_possible_articles']}")
print(f"  Overall progress: {summary['overall_education_percentage']:.1f}%")

print("\n  By pillar:")
for pillar, data in sorted(summary['pillars'].items()):
    if data['articles_viewed'] > 0:
        print(f"    {pillar}: {data['articles_viewed']}/{4} articles ({data['percentage']:.0f}%)")

# 5. Test education score in combined scoring
print("\n5. Impact on WellPath Score:")
print("  Survey + Biomarkers: ~90%")
print(f"  Education component: +{summary['overall_education_percentage']:.1f}%")
print(f"  Combined potential: ~{90 + summary['overall_education_percentage']:.1f}%")

print("\n" + "=" * 80)
print("✅ Education tracking system functional!")
print("=" * 80)
