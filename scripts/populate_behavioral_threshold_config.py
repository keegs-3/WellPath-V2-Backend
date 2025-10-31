#!/usr/bin/env python3
"""
Populate behavioral_threshold_config with default threshold values for biometrics.
This determines when tracked data should replace questionnaire responses.
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Define threshold configurations for different biometric types
BIOMETRIC_THRESHOLDS = {
    # Immediate updates (1 data point is enough)
    'immediate': {
        'biometrics': [
            'BMI', 'Weight', 'Height', 'Bodyfat',
            'Blood Pressure (Systolic)', 'Blood Pressure (Diastolic)',
            'Resting Heart Rate', 'VO2 Max'
        ],
        'config': {
            'min_weeks_of_data': 1,
            'min_data_points_per_week': 1,
            'min_total_data_points': 1,
            'min_tracking_days': 1,
            'max_gap_days': 30,
            'require_recent_data': True
        }
    },
    # Short-term pattern (1 week of data)
    'weekly': {
        'biometrics': [
            'Steps/Day', 'Water Intake'
        ],
        'config': {
            'min_weeks_of_data': 1,
            'min_data_points_per_week': 4,
            'min_total_data_points': 7,
            'min_tracking_days': 7,
            'max_gap_days': 3,
            'require_recent_data': True
        }
    },
    # Medium-term pattern (2 weeks of data)
    'biweekly': {
        'biometrics': [
            'Deep Sleep', 'REM Sleep', 'Total Sleep', 'HRV', 'Grip Strength'
        ],
        'config': {
            'min_weeks_of_data': 2,
            'min_data_points_per_week': 4,
            'min_total_data_points': 10,
            'min_tracking_days': 14,
            'max_gap_days': 5,
            'require_recent_data': True
        }
    },
    # Long-term stability (3+ weeks for ratios/complex metrics)
    'monthly': {
        'biometrics': [
            'Hip-to-Waist Ratio'
        ],
        'config': {
            'min_weeks_of_data': 3,
            'min_data_points_per_week': 1,
            'min_total_data_points': 3,
            'min_tracking_days': 21,
            'max_gap_days': 14,
            'require_recent_data': True
        }
    }
}

def populate_threshold_config():
    """Populate behavioral_threshold_config table"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("BEHAVIORAL THRESHOLD CONFIG POPULATION")
        print("="*60)
        print()

        total_created = 0

        for threshold_type, config_data in BIOMETRIC_THRESHOLDS.items():
            print(f"Processing {threshold_type} threshold type...")
            print("-"*60)

            for biometric_name in config_data['biometrics']:
                # Get the aggregation metric for this biometric
                cur.execute("""
                    SELECT agg_metric_id
                    FROM biometrics_aggregation_metrics
                    WHERE biometric_name = %s
                    LIMIT 1
                """, (biometric_name,))

                result = cur.fetchone()
                if not result:
                    print(f"  ⚠️  No aggregation metric found for {biometric_name}, skipping...")
                    continue

                agg_metric_id = result[0]
                config = config_data['config']

                # Check if config already exists
                cur.execute("""
                    SELECT 1 FROM behavioral_threshold_config
                    WHERE biometric_name = %s AND agg_metric_id = %s
                """, (biometric_name, agg_metric_id))

                if cur.fetchone():
                    print(f"  - Config already exists for {biometric_name}")
                    continue

                # Insert threshold config
                cur.execute("""
                    INSERT INTO behavioral_threshold_config (
                        agg_metric_id,
                        biometric_name,
                        min_weeks_of_data,
                        min_data_points_per_week,
                        min_total_data_points,
                        min_tracking_days,
                        max_gap_days,
                        require_recent_data,
                        config_type,
                        is_active
                    )
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
                """, (
                    agg_metric_id,
                    biometric_name,
                    config['min_weeks_of_data'],
                    config['min_data_points_per_week'],
                    config['min_total_data_points'],
                    config['min_tracking_days'],
                    config['max_gap_days'],
                    config['require_recent_data'],
                    'biometric_tracking',
                    True
                ))

                print(f"  ✓ Created config for {biometric_name} ({threshold_type})")
                total_created += 1

            print()

        conn.commit()

        # Summary
        cur.execute("SELECT COUNT(*) FROM behavioral_threshold_config")
        total_configs = cur.fetchone()[0]

        print("="*60)
        print("SUMMARY")
        print("="*60)
        print(f"  Created: {total_created} new threshold configs")
        print(f"  Total configs in database: {total_configs}")
        print()
        print("✅ Behavioral threshold config population complete!")
        print("="*60)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error populating threshold config: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_threshold_config()
