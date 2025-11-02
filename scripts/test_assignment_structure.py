"""
Test assignment structure with MOCK data (no API calls).

Validates the enhanced assignment format works before spending $ on API.
"""

import sys
import os
import json
from uuid import UUID

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

from dotenv import load_dotenv
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from database.postgres_client import get_db_connection


# Mock assignment in enhanced format
MOCK_ASSIGNMENT = {
    "rec_id": "increase_fiber_intake",
    "rationale": "Your LDL is 224 mg/dL (optimal <100). Soluble fiber binds bile acids, forcing liver to use cholesterol. Evidence shows 10g fiber = 5-10% LDL reduction.",

    "biomarker_connection": {
        "primary_targets": [
            {
                "biomarker": "LDL",
                "current": 224,
                "goal": 120,
                "unit": "mg/dL",
                "mechanism": "Soluble fiber binds bile acids in gut, forcing liver to pull cholesterol from blood to synthesize new bile acids",
                "expected_impact": "30-50 mg/dL reduction (15-20%)",
                "timeline_weeks": 12
            },
            {
                "biomarker": "HbA1c",
                "current": 6.35,
                "goal": 5.7,
                "unit": "%",
                "mechanism": "Fiber slows glucose absorption, reducing postprandial glucose spikes",
                "expected_impact": "0.3-0.5% reduction",
                "timeline_weeks": 12
            }
        ],
        "secondary_targets": [
            {
                "biomarker": "Triglycerides",
                "current": 240,
                "expected_impact": "15-25% reduction"
            }
        ]
    },

    "trackable_goal": {
        "display_name": "Fiber Intake",
        "display_metric_id": "DISP_FIBER_SERVINGS",
        "target_value": 35,
        "unit": "grams",
        "period": "daily",
        "current_baseline": "unknown",
        "internal_agg_id": "AGG_FIBER_DAILY",
        "data_entry_field": "DEF_FIBER_GRAMS"
    },

    "progressive_plan": [
        {
            "phase": 1,
            "days": "1-30",
            "goal": "Track all food and establish baseline fiber intake. Aim for 20g daily.",
            "target_value": 20,
            "milestone": "Baseline established, morning oats + lunch beans added"
        },
        {
            "phase": 2,
            "days": "31-60",
            "goal": "Increase to 28g daily by adding consistent dinner vegetables",
            "target_value": 28,
            "milestone": "Consistent 28g with evening vegetables as habit"
        },
        {
            "phase": 3,
            "days": "61-90",
            "goal": "Reach and maintain 35g daily target",
            "target_value": 35,
            "milestone": "Consistent adherence, ready for next biomarker test"
        }
    ],

    "implementation_details": {
        "specific_actions": [
            "Breakfast: 1 cup steel-cut oats with 2 tbsp ground flaxseed (10g fiber)",
            "Lunch: Large salad + 1 cup lentil or black bean soup (12g fiber)",
            "Dinner: 6oz protein + 2-3 cups roasted vegetables (8g fiber)",
            "Snack: Apple with 2 tbsp almond butter (5g fiber)",
            "Total: 35g fiber"
        ],
        "practical_tips": [
            "Batch cook 4 cups beans on Sunday, freeze in 1-cup portions",
            "Buy pre-washed salad greens to reduce friction",
            "Add 1 tbsp chia seeds to smoothies (4g fiber boost)",
            "Choose high-fiber bread (5g per 2 slices vs 2g regular)"
        ],
        "common_mistakes": [
            "Fiber supplements don't provide same benefits as whole food fiber",
            "Increase fiber gradually to avoid GI discomfort",
            "Drink 8oz water with each high-fiber meal (prevents constipation)",
            "Soluble > insoluble fiber for cholesterol (oats, beans, apples)"
        ],
        "shopping_list": [
            "Steel-cut oats (not instant)",
            "Black beans, lentils (dried or canned no-salt)",
            "Flaxseed meal",
            "Broccoli, cauliflower, Brussels sprouts",
            "Apples, berries",
            "Almonds, almond butter"
        ]
    },

    "measurement_strategy": {
        "how_patient_tracks": "Log fiber content of each food in daily food diary",
        "database_field": "DEF_FIBER_GRAMS",
        "aggregation": "Automatically sums to 'Fiber Intake' metric each day",
        "adherence_scoring": "Daily adherence = actual_fiber / 35g * 100%",
        "success_criteria": "Maintain 80%+ adherence (28+ days out of 30 meeting target)"
    },

    "evidence": [
        {
            "finding": "Every 10g fiber intake reduces LDL cholesterol by 5-10%",
            "study_type": "meta-analysis",
            "population": "General adult population",
            "strength": "high"
        },
        {
            "finding": "35g fiber daily associated with 0.3-0.5% HbA1c reduction",
            "study_type": "randomized controlled trial",
            "strength": "moderate"
        },
        {
            "finding": "High fiber intake (30g+) reduces cardiovascular mortality by 20%",
            "study_type": "population cohort",
            "strength": "moderate"
        }
    ],

    "personal_target": {
        "goal": "35g fiber daily",
        "reasoning": "Higher target due to significantly elevated LDL (224) and prediabetic HbA1c (6.35)"
    },

    "priority": "high",
    "difficulty": 2
}


def test_mock_storage():
    """Test storing mock assignment to verify structure works."""
    print("="*70)
    print("Testing Enhanced Assignment Structure (Mock Data)")
    print("="*70)

    patient_id = '11111111-1111-1111-1111-111111111111'
    rec_id = MOCK_ASSIGNMENT['rec_id']

    print(f"\nPatient: {patient_id}")
    print(f"Recommendation: {rec_id}")

    # Get recommendation UUID
    db = get_db_connection()

    with db.cursor() as cursor:
        cursor.execute("SELECT id FROM recommendations_base WHERE rec_id = %s", (rec_id,))
        row = cursor.fetchone()
        if not row:
            print(f"\n❌ Recommendation {rec_id} not found in database")
            return
        rec_uuid = row[0]

    # Build assignment detail
    assignment_detail = {
        "biomarker_connection": MOCK_ASSIGNMENT.get('biomarker_connection', {}),
        "trackable_goal": MOCK_ASSIGNMENT.get('trackable_goal', {}),
        "progressive_plan": MOCK_ASSIGNMENT.get('progressive_plan', []),
        "implementation_details": MOCK_ASSIGNMENT.get('implementation_details', {}),
        "measurement_strategy": MOCK_ASSIGNMENT.get('measurement_strategy', {}),
        "evidence": MOCK_ASSIGNMENT.get('evidence', [])
    }

    print("\n✓ Assignment detail structure:")
    print(f"  - Biomarker targets: {len(assignment_detail['biomarker_connection'].get('primary_targets', []))}")
    print(f"  - Progressive phases: {len(assignment_detail['progressive_plan'])}")
    print(f"  - Implementation actions: {len(assignment_detail['implementation_details'].get('specific_actions', []))}")
    print(f"  - Evidence studies: {len(assignment_detail['evidence'])}")

    # Store in database
    with db.cursor() as cursor:
        cursor.execute("""
            INSERT INTO patient_recommendations (
                patient_id, recommendation_id, status, assigned_date, start_date,
                personal_target, agent_notes, assignment_detail
            ) VALUES (%s, %s, 'active', CURRENT_DATE, CURRENT_DATE, %s, %s, %s)
            ON CONFLICT DO NOTHING
            RETURNING id
        """, (
            patient_id,
            rec_uuid,
            json.dumps(MOCK_ASSIGNMENT.get('personal_target', {})),
            MOCK_ASSIGNMENT.get('rationale', ''),
            json.dumps(assignment_detail)
        ))

        result = cursor.fetchone()
        if result:
            print(f"\n✓ Successfully stored enhanced assignment!")
            patient_rec_id = result[0]
        else:
            print(f"\n⚠ Assignment already exists (using ON CONFLICT)")

        db.commit()

    # Retrieve and verify
    with db.cursor() as cursor:
        cursor.execute("""
            SELECT assignment_detail
            FROM patient_recommendations
            WHERE patient_id = %s AND recommendation_id = %s
        """, (patient_id, rec_uuid))

        row = cursor.fetchone()
        if row and row[0]:
            detail = row[0]
            print("\n✓ Retrieved from database:")
            print(f"  - Trackable metric: {detail['trackable_goal'].get('display_name')}")
            print(f"  - Target: {detail['trackable_goal'].get('target_value')}{detail['trackable_goal'].get('unit')}")
            print(f"  - Phase 1 (Days 1-30): {detail['progressive_plan'][0].get('goal')}")
            print(f"  - Evidence studies: {len(detail['evidence'])}")
            print("\n✅ Structure validated! Ready for real API call.")
        else:
            print("\n❌ Could not retrieve assignment_detail")

    db.close()


if __name__ == "__main__":
    test_mock_storage()
