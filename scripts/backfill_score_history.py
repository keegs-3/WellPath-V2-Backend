#!/usr/bin/env python3
"""
Backfill normalized score history tables from patient_wellpath_score_items

This populates:
- patient_pillar_scores_history (pillar scores over time)
- patient_component_scores_history (markers/behaviors/education within each pillar)
"""

import psycopg2
from datetime import datetime

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def backfill_history():
    """Backfill score history from patient_wellpath_score_items"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("Backfilling score history tables from patient_wellpath_score_items...\n")

        # Get distinct patients and their latest score calculation
        cur.execute("""
            SELECT DISTINCT
                patient_id,
                patient_gender,
                patient_age,
                MAX(scored_at) as latest_scored_at
            FROM patient_wellpath_score_items
            GROUP BY patient_id, patient_gender, patient_age
        """)

        patients = cur.fetchall()
        print(f"Found {len(patients)} patients with score data\n")

        for patient_id, gender, age, scored_at in patients:
            print(f"Processing patient {patient_id}...")

            # ==================================================
            # 1. Populate Pillar Scores History
            # ==================================================

            cur.execute("""
                INSERT INTO patient_pillar_scores_history (
                    patient_id,
                    pillar_id,
                    pillar_score,
                    pillar_max_score,
                    pillar_percentage,
                    item_count,
                    biomarker_count,
                    biometric_count,
                    survey_question_count,
                    survey_function_count,
                    education_count,
                    calculated_at,
                    calculation_version
                )
                SELECT
                    patient_id,
                    pb.pillar_id,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN patient_normalized_score_male
                        ELSE patient_normalized_score_female
                    END) as pillar_score,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN max_normalized_score_male
                        ELSE max_normalized_score_female
                    END) as pillar_max_score,
                    CASE
                        WHEN SUM(CASE
                            WHEN patient_gender = 'male' THEN max_normalized_score_male
                            ELSE max_normalized_score_female
                        END) > 0 THEN
                            (SUM(CASE
                                WHEN patient_gender = 'male' THEN patient_normalized_score_male
                                ELSE patient_normalized_score_female
                            END) / SUM(CASE
                                WHEN patient_gender = 'male' THEN max_normalized_score_male
                                ELSE max_normalized_score_female
                            END) * 100)
                        ELSE 0
                    END as pillar_percentage,
                    COUNT(*) as item_count,
                    SUM(CASE WHEN item_type = 'biomarker' THEN 1 ELSE 0 END) as biomarker_count,
                    SUM(CASE WHEN item_type = 'biometric' THEN 1 ELSE 0 END) as biometric_count,
                    SUM(CASE WHEN item_type = 'survey_question' THEN 1 ELSE 0 END) as survey_question_count,
                    SUM(CASE WHEN item_type = 'survey_function' THEN 1 ELSE 0 END) as survey_function_count,
                    SUM(CASE WHEN item_type = 'education' THEN 1 ELSE 0 END) as education_count,
                    MAX(scored_at) as calculated_at,
                    MAX(calculation_version) as calculation_version
                FROM patient_wellpath_score_items psi
                JOIN pillars_base pb ON psi.pillar_name = pb.pillar_name
                WHERE patient_id = %s
                GROUP BY patient_id, pb.pillar_id, patient_gender
            """, (patient_id,))

            pillar_count = cur.rowcount
            print(f"  ✓ Inserted {pillar_count} pillar score records")

            # ==================================================
            # 2. Populate Component Scores History
            # ==================================================

            # Markers component (biomarkers + biometrics)
            cur.execute("""
                INSERT INTO patient_component_scores_history (
                    patient_id,
                    pillar_id,
                    component_type,
                    component_score,
                    component_max_score,
                    component_percentage,
                    item_count,
                    biomarker_count,
                    biometric_count,
                    calculated_at,
                    calculation_version
                )
                SELECT
                    patient_id,
                    pb.pillar_id,
                    'markers' as component_type,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN patient_normalized_score_male
                        ELSE patient_normalized_score_female
                    END) as component_score,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN max_normalized_score_male
                        ELSE max_normalized_score_female
                    END) as component_max_score,
                    CASE
                        WHEN SUM(CASE
                            WHEN patient_gender = 'male' THEN max_normalized_score_male
                            ELSE max_normalized_score_female
                        END) > 0 THEN
                            (SUM(CASE
                                WHEN patient_gender = 'male' THEN patient_normalized_score_male
                                ELSE patient_normalized_score_female
                            END) / SUM(CASE
                                WHEN patient_gender = 'male' THEN max_normalized_score_male
                                ELSE max_normalized_score_female
                            END) * 100)
                        ELSE 0
                    END as component_percentage,
                    COUNT(*) as item_count,
                    SUM(CASE WHEN item_type = 'biomarker' THEN 1 ELSE 0 END) as biomarker_count,
                    SUM(CASE WHEN item_type = 'biometric' THEN 1 ELSE 0 END) as biometric_count,
                    MAX(scored_at) as calculated_at,
                    MAX(calculation_version) as calculation_version
                FROM patient_wellpath_score_items psi
                JOIN pillars_base pb ON psi.pillar_name = pb.pillar_name
                WHERE patient_id = %s
                AND item_type IN ('biomarker', 'biometric')
                GROUP BY patient_id, pb.pillar_id, patient_gender
                HAVING COUNT(*) > 0
            """, (patient_id,))

            markers_count = cur.rowcount

            # Behaviors component (survey questions + functions)
            cur.execute("""
                INSERT INTO patient_component_scores_history (
                    patient_id,
                    pillar_id,
                    component_type,
                    component_score,
                    component_max_score,
                    component_percentage,
                    item_count,
                    survey_question_count,
                    survey_function_count,
                    calculated_at,
                    calculation_version
                )
                SELECT
                    patient_id,
                    pb.pillar_id,
                    'behaviors' as component_type,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN patient_normalized_score_male
                        ELSE patient_normalized_score_female
                    END) as component_score,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN max_normalized_score_male
                        ELSE max_normalized_score_female
                    END) as component_max_score,
                    CASE
                        WHEN SUM(CASE
                            WHEN patient_gender = 'male' THEN max_normalized_score_male
                            ELSE max_normalized_score_female
                        END) > 0 THEN
                            (SUM(CASE
                                WHEN patient_gender = 'male' THEN patient_normalized_score_male
                                ELSE patient_normalized_score_female
                            END) / SUM(CASE
                                WHEN patient_gender = 'male' THEN max_normalized_score_male
                                ELSE max_normalized_score_female
                            END) * 100)
                        ELSE 0
                    END as component_percentage,
                    COUNT(*) as item_count,
                    SUM(CASE WHEN item_type = 'survey_question' THEN 1 ELSE 0 END) as survey_question_count,
                    SUM(CASE WHEN item_type = 'survey_function' THEN 1 ELSE 0 END) as survey_function_count,
                    MAX(scored_at) as calculated_at,
                    MAX(calculation_version) as calculation_version
                FROM patient_wellpath_score_items psi
                JOIN pillars_base pb ON psi.pillar_name = pb.pillar_name
                WHERE patient_id = %s
                AND item_type IN ('survey_question', 'survey_function')
                GROUP BY patient_id, pb.pillar_id, patient_gender
                HAVING COUNT(*) > 0
            """, (patient_id,))

            behaviors_count = cur.rowcount

            # Education component
            cur.execute("""
                INSERT INTO patient_component_scores_history (
                    patient_id,
                    pillar_id,
                    component_type,
                    component_score,
                    component_max_score,
                    component_percentage,
                    item_count,
                    education_count,
                    calculated_at,
                    calculation_version
                )
                SELECT
                    patient_id,
                    pb.pillar_id,
                    'education' as component_type,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN patient_normalized_score_male
                        ELSE patient_normalized_score_female
                    END) as component_score,
                    SUM(CASE
                        WHEN patient_gender = 'male' THEN max_normalized_score_male
                        ELSE max_normalized_score_female
                    END) as component_max_score,
                    CASE
                        WHEN SUM(CASE
                            WHEN patient_gender = 'male' THEN max_normalized_score_male
                            ELSE max_normalized_score_female
                        END) > 0 THEN
                            (SUM(CASE
                                WHEN patient_gender = 'male' THEN patient_normalized_score_male
                                ELSE patient_normalized_score_female
                            END) / SUM(CASE
                                WHEN patient_gender = 'male' THEN max_normalized_score_male
                                ELSE max_normalized_score_female
                            END) * 100)
                        ELSE 0
                    END as component_percentage,
                    COUNT(*) as item_count,
                    COUNT(*) as education_count,
                    MAX(scored_at) as calculated_at,
                    MAX(calculation_version) as calculation_version
                FROM patient_wellpath_score_items psi
                JOIN pillars_base pb ON psi.pillar_name = pb.pillar_name
                WHERE patient_id = %s
                AND item_type = 'education'
                GROUP BY patient_id, pb.pillar_id, patient_gender
                HAVING COUNT(*) > 0
            """, (patient_id,))

            education_count = cur.rowcount

            print(f"  ✓ Inserted {markers_count + behaviors_count + education_count} component score records")
            print()

        conn.commit()

        # Summary
        cur.execute("SELECT COUNT(*) FROM patient_pillar_scores_history")
        total_pillar = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM patient_component_scores_history")
        total_component = cur.fetchone()[0]

        print("="*60)
        print(f"✅ Backfill complete!")
        print(f"   Total pillar score records: {total_pillar}")
        print(f"   Total component score records: {total_component}")
        print("="*60)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error backfilling history: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    backfill_history()
