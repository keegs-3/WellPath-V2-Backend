"""
Simple Recommendation Grouper

Groups recommendations by base ID (REC0001.1, REC0001.2, etc. → REC0001)
Then consolidates each group.
"""

import sys
import os
import re
from collections import defaultdict

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


def extract_base_id(rec_id: str) -> str:
    """Extract base ID from variants like REC0001.1, REC0001.3 (ii), etc."""
    # Remove everything after the first dot or space
    base = re.match(r'^([A-Z]+\d+)', rec_id)
    if base:
        return base.group(1)
    return rec_id


def group_recommendations():
    """Group recommendations by base concept."""
    db = get_db_connection()

    query = """
    SELECT
        rec_id,
        title,
        overview,
        primary_biomarkers,
        secondary_biomarkers,
        tertiary_biomarkers,
        primary_biometrics,
        secondary_biometrics,
        tertiary_biometrics,
        raw_impact,
        recommendation_type,
        level,
        evidence,
        contraindications
    FROM recommendations_base
    WHERE is_active = true
    ORDER BY rec_id
    """

    with db.cursor() as cursor:
        cursor.execute(query)
        rows = cursor.fetchall()

    # Group by base ID
    groups = defaultdict(list)

    for row in rows:
        rec_id = row[0]
        base_id = extract_base_id(rec_id)

        groups[base_id].append({
            'rec_id': rec_id,
            'title': row[1],
            'overview': row[2],
            'primary_biomarkers': row[3],
            'secondary_biomarkers': row[4],
            'tertiary_biomarkers': row[5],
            'primary_biometrics': row[6],
            'secondary_biometrics': row[7],
            'tertiary_biometrics': row[8],
            'raw_impact': row[9],
            'type': row[10],
            'level': row[11],
            'evidence': row[12],
            'contraindications': row[13]
        })

    print(f"📊 Grouped {len(rows)} recommendations into {len(groups)} concepts\n")

    # Show groups
    for base_id in sorted(groups.keys())[:15]:
        recs = groups[base_id]
        print(f"{base_id}: {recs[0]['title']}")
        print(f"  Variants: {len(recs)}")
        print(f"  IDs: {', '.join([r['rec_id'] for r in recs])}")
        print(f"  Raw Impact: {recs[0]['raw_impact']}")
        if recs[0]['primary_biomarkers']:
            print(f"  Primary Biomarkers: {recs[0]['primary_biomarkers'][:80]}")
        print()

    # Save grouped data
    import json
    with open('/tmp/grouped_recommendations.json', 'w') as f:
        json.dump({k: v for k, v in groups.items()}, f, indent=2, default=str)

    print(f"\n✓ Saved groups to /tmp/grouped_recommendations.json")
    print(f"\n📈 Summary:")
    print(f"  Total recommendations: {len(rows)}")
    print(f"  Unique concepts: {len(groups)}")
    print(f"  Avg variants per concept: {len(rows) / len(groups):.1f}")

    return groups


if __name__ == "__main__":
    groups = group_recommendations()
