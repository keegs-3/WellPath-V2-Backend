"""
Populate junction tables from recommendations_base columns.
"""

import sys
import os

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


def populate_biomarker_mappings():
    """Populate recommendations_biomarkers from primary/secondary/tertiary columns."""
    db = get_db_connection()

    print("Populating biomarker mappings...")

    with db.cursor() as cursor:
        cursor.execute("""
            SELECT rec_id, id, primary_biomarkers, secondary_biomarkers, tertiary_biomarkers
            FROM recommendations_base
            WHERE is_active = true
        """)
        recs = cursor.fetchall()

    inserted = 0
    for rec in recs:
        rec_id = rec[0]
        rec_uuid = rec[1]

        # Process each priority level
        for priority, biomarkers_csv in [('primary', rec[2]), ('secondary', rec[3]), ('tertiary', rec[4])]:
            if not biomarkers_csv:
                continue

            for biomarker in biomarkers_csv.split(','):
                biomarker = biomarker.strip()
                if not biomarker:
                    continue

                try:
                    with db.cursor() as cursor:
                        cursor.execute("""
                            INSERT INTO recommendations_biomarkers (recommendation_id, biomarker_name, priority)
                            VALUES (%s, %s, %s)
                        """, (rec_id, biomarker, priority))
                        inserted += 1
                except Exception as e:
                    # Skip if biomarker doesn't exist or other error
                    pass

    db.commit()
    print(f"✓ Inserted {inserted} biomarker mappings")
    return inserted


def populate_biometric_mappings():
    """Populate recommendations_biometrics from primary/secondary/tertiary columns."""
    db = get_db_connection()

    print("Populating biometric mappings...")

    with db.cursor() as cursor:
        cursor.execute("""
            SELECT rec_id, id, primary_biometrics, secondary_biometrics, tertiary_biometrics
            FROM recommendations_base
            WHERE is_active = true
        """)
        recs = cursor.fetchall()

    inserted = 0
    for rec in recs:
        rec_id = rec[0]
        rec_uuid = rec[1]

        for priority, biometrics_csv in [('primary', rec[2]), ('secondary', rec[3]), ('tertiary', rec[4])]:
            if not biometrics_csv:
                continue

            for biometric in biometrics_csv.split(','):
                biometric = biometric.strip()
                if not biometric:
                    continue

                try:
                    with db.cursor() as cursor:
                        cursor.execute("""
                            INSERT INTO recommendations_biometrics (recommendation_id, biometric_name, priority)
                            VALUES (%s, %s, %s)
                        """, (rec_id, biometric, priority))
                        inserted += 1
                except Exception:
                    pass

    db.commit()
    print(f"✓ Inserted {inserted} biometric mappings")
    return inserted


def main():
    print("="*70)
    print("Populating Junction Tables")
    print("="*70 + "\n")

    bio_count = populate_biomarker_mappings()
    met_count = populate_biometric_mappings()

    print("\n" + "="*70)
    print(f"✓ Complete! Populated {bio_count + met_count} total mappings")
    print("="*70)


if __name__ == "__main__":
    main()
