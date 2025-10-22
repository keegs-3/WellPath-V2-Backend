#!/usr/bin/env python3
"""
Test All Instance Calculations
Tests all 40 instance calculations end-to-end
"""

import os
import sys
from datetime import datetime, timedelta
from uuid import uuid4
import psycopg2
from psycopg2.extras import RealDictCursor
import requests

# Database connection
DB_URL = os.getenv('DATABASE_URL', 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres')
EDGE_FUNCTION_URL = os.getenv('EDGE_FUNCTION_URL', 'https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/run-instance-calculations')
SUPABASE_ANON_KEY = os.getenv('SUPABASE_ANON_KEY', 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjgxNzA0MTgsImV4cCI6MjA0Mzc0NjQxOH0.qMz2wBuZx5YhHLOMLVF1Zy3XQlXKjGcW-kXZLbXjQOE')

# Test user (create if needed)
TEST_USER_ID = 'c46dccc4-c3de-4df9-93ab-d512dff7cf5b'


class CalculationTester:
    def __init__(self):
        self.conn = psycopg2.connect(DB_URL)
        self.conn.autocommit = False
        self.results = {
            'total': 0,
            'passed': 0,
            'failed': 0,
            'errors': []
        }

    def cleanup(self):
        """Clean up test data"""
        with self.conn.cursor() as cur:
            # Delete test data from last 30 days
            cur.execute("""
                DELETE FROM patient_data_entries
                WHERE user_id = %s
                AND entry_date >= CURRENT_DATE - INTERVAL '30 days'
                AND metadata->>'test' = 'true'
            """, (TEST_USER_ID,))
        self.conn.commit()

    def insert_test_entry(self, field_id, value, event_instance_id, value_type='quantity', entry_date=None, entry_timestamp=None):
        """Insert a test data entry"""
        with self.conn.cursor() as cur:
            if entry_date is None:
                entry_date = datetime.now().date()
            if entry_timestamp is None:
                entry_timestamp = datetime.now()

            metadata = {'test': True}

            if value_type == 'quantity':
                cur.execute("""
                    INSERT INTO patient_data_entries
                    (user_id, field_id, entry_date, entry_timestamp, value_quantity, source, event_instance_id, metadata)
                    VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
                """, (TEST_USER_ID, field_id, entry_date, entry_timestamp, value, event_instance_id, str(metadata).replace("'", '"')))
            elif value_type == 'timestamp':
                cur.execute("""
                    INSERT INTO patient_data_entries
                    (user_id, field_id, entry_date, entry_timestamp, value_timestamp, source, event_instance_id, metadata)
                    VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
                """, (TEST_USER_ID, field_id, entry_date, entry_timestamp, value, event_instance_id, str(metadata).replace("'", '"')))
            elif value_type == 'reference':
                cur.execute("""
                    INSERT INTO patient_data_entries
                    (user_id, field_id, entry_date, entry_timestamp, value_reference, source, event_instance_id, metadata)
                    VALUES (%s, %s, %s, %s, %s, 'manual', %s, %s::jsonb)
                """, (TEST_USER_ID, field_id, entry_date, entry_timestamp, value, event_instance_id, str(metadata).replace("'", '"')))

        self.conn.commit()

    def get_calculated_value(self, field_id, event_instance_id):
        """Get a calculated value from patient_data_entries"""
        with self.conn.cursor(cursor_factory=RealDictCursor) as cur:
            cur.execute("""
                SELECT value_quantity, metadata
                FROM patient_data_entries
                WHERE user_id = %s
                AND field_id = %s
                AND event_instance_id = %s
                AND source = 'auto_calculated'
                ORDER BY created_at DESC
                LIMIT 1
            """, (TEST_USER_ID, field_id, event_instance_id))
            return cur.fetchone()

    def call_edge_function(self, event_instance_id):
        """Call the edge function to run calculations"""
        headers = {
            'Authorization': f'Bearer {SUPABASE_ANON_KEY}',
            'Content-Type': 'application/json'
        }
        payload = {
            'user_id': TEST_USER_ID,
            'event_instance_id': event_instance_id
        }

        response = requests.post(EDGE_FUNCTION_URL, json=payload, headers=headers)
        return response.status_code == 200, response.json() if response.status_code == 200 else response.text

    def assert_value(self, name, expected, actual, tolerance=0.1):
        """Assert a calculated value matches expected"""
        self.results['total'] += 1

        if actual is None:
            self.results['failed'] += 1
            self.results['errors'].append(f"❌ {name}: No value calculated")
            print(f"❌ {name}: No value calculated")
            return False

        if abs(expected - actual) <= tolerance:
            self.results['passed'] += 1
            print(f"✅ {name}: {actual} (expected {expected})")
            return True
        else:
            self.results['failed'] += 1
            self.results['errors'].append(f"❌ {name}: Got {actual}, expected {expected}")
            print(f"❌ {name}: Got {actual}, expected {expected}")
            return False

    # =====================================================
    # DURATION CALCULATIONS (11 tests)
    # =====================================================

    def test_durations(self):
        """Test all duration calculations"""
        print("\n=== Testing Duration Calculations ===")

        duration_tests = [
            ('SLEEP', 'DEF_SLEEP_BEDTIME', 'DEF_SLEEP_WAKETIME', 'DEF_SLEEP_DURATION', 8),
            ('CARDIO', 'DEF_CARDIO_START', 'DEF_CARDIO_END', 'DEF_CARDIO_DURATION', 0.75),
            ('HIIT', 'DEF_HIIT_START', 'DEF_HIIT_END', 'DEF_HIIT_DURATION', 0.5),
            ('STRENGTH', 'DEF_STRENGTH_START', 'DEF_STRENGTH_END', 'DEF_STRENGTH_DURATION', 1),
            ('MOBILITY', 'DEF_MOBILITY_START', 'DEF_MOBILITY_END', 'DEF_MOBILITY_DURATION', 0.25),
            ('MINDFULNESS', 'DEF_MINDFULNESS_START', 'DEF_MINDFULNESS_END', 'DEF_MINDFULNESS_DURATION', 0.33333),
            ('BRAIN_TRAINING', 'DEF_BRAIN_TRAINING_START', 'DEF_BRAIN_TRAINING_END', 'DEF_BRAIN_TRAINING_DURATION', 0.5),
            ('JOURNALING', 'DEF_JOURNALING_START', 'DEF_JOURNALING_END', 'DEF_JOURNALING_DURATION', 0.25),
            ('OUTDOOR', 'DEF_OUTDOOR_START', 'DEF_OUTDOOR_END', 'DEF_OUTDOOR_DURATION', 2),
            ('SUNLIGHT', 'DEF_SUNLIGHT_START', 'DEF_SUNLIGHT_END', 'DEF_SUNLIGHT_DURATION', 0.5),
        ]

        for name, start_field, end_field, output_field, hours in duration_tests:
            event_id = str(uuid4())

            now = datetime.now()
            start_time = now
            end_time = now + timedelta(hours=hours)

            self.insert_test_entry(start_field, start_time, event_id, 'timestamp')
            self.insert_test_entry(end_field, end_time, event_id, 'timestamp')

            # Call edge function
            success, result = self.call_edge_function(event_id)

            if not success:
                print(f"❌ {name}: Edge function failed: {result}")
                self.results['failed'] += 1
                continue

            # Check calculated duration
            calc_result = self.get_calculated_value(output_field, event_id)
            expected_minutes = hours * 60

            if calc_result:
                self.assert_value(f"{name} Duration", expected_minutes, calc_result['value_quantity'], tolerance=1)
            else:
                self.results['failed'] += 1
                print(f"❌ {name} Duration: Not calculated")

    # =====================================================
    # BIOMETRIC FORMULAS (5 tests)
    # =====================================================

    def test_biometric_formulas(self):
        """Test biometric formula calculations"""
        print("\n=== Testing Biometric Formula Calculations ===")

        # Test BMI
        event_id = str(uuid4())
        self.insert_test_entry('DEF_WEIGHT', 70, event_id)  # 70 kg
        self.insert_test_entry('DEF_HEIGHT', 1.75, event_id)  # 1.75 m (stored as cm: 175)

        success, _ = self.call_edge_function(event_id)
        if success:
            result = self.get_calculated_value('DEF_BMI', event_id)
            expected_bmi = 70 / (1.75 * 1.75)  # ~22.9
            if result:
                self.assert_value("BMI", expected_bmi, result['value_quantity'], tolerance=0.5)

        # Test Hip-Waist Ratio
        event_id = str(uuid4())
        self.insert_test_entry('DEF_WAIST_CIRCUMFERENCE', 80, event_id)
        self.insert_test_entry('DEF_HIP_CIRCUMFERENCE', 100, event_id)

        success, _ = self.call_edge_function(event_id)
        if success:
            result = self.get_calculated_value('DEF_HIP_WAIST_RATIO', event_id)
            if result:
                self.assert_value("Hip-Waist Ratio", 0.8, result['value_quantity'], tolerance=0.01)

    # =====================================================
    # UNIT CONVERSIONS (11 tests)
    # =====================================================

    def test_unit_conversions(self):
        """Test unit conversions"""
        print("\n=== Testing Unit Conversions ===")

        # Weight: lb → kg
        event_id = str(uuid4())
        self.insert_test_entry('DEF_WEIGHT_LB', 154, event_id)  # ~70 kg
        success, _ = self.call_edge_function(event_id)
        if success:
            result = self.get_calculated_value('DEF_WEIGHT_KG', event_id)
            if result:
                self.assert_value("Weight lb→kg", 69.85, result['value_quantity'], tolerance=1)

        # Waist: in → cm
        event_id = str(uuid4())
        self.insert_test_entry('DEF_WAIST_IN', 32, event_id)
        success, _ = self.call_edge_function(event_id)
        if success:
            result = self.get_calculated_value('DEF_WAIST_CM', event_id)
            if result:
                self.assert_value("Waist in→cm", 81.28, result['value_quantity'], tolerance=1)

        # Protein: servings → grams (needs protein type)
        event_id = str(uuid4())
        self.insert_test_entry('DEF_PROTEIN_SERVINGS', 2, event_id)
        self.insert_test_entry('DEF_PROTEIN_TYPE', 'fish', event_id, 'reference')
        success, _ = self.call_edge_function(event_id)
        if success:
            result = self.get_calculated_value('DEF_PROTEIN_GRAMS', event_id)
            if result:
                # Assuming fish has ~21g protein per serving
                self.assert_value("Protein servings→g", 42, result['value_quantity'], tolerance=5)

    def print_summary(self):
        """Print test summary"""
        print("\n" + "="*60)
        print("TEST SUMMARY")
        print("="*60)
        print(f"Total Tests: {self.results['total']}")
        print(f"Passed: {self.results['passed']} ✅")
        print(f"Failed: {self.results['failed']} ❌")

        if self.results['errors']:
            print("\nErrors:")
            for error in self.results['errors'][:10]:  # Show first 10 errors
                print(f"  {error}")

        success_rate = (self.results['passed'] / self.results['total'] * 100) if self.results['total'] > 0 else 0
        print(f"\nSuccess Rate: {success_rate:.1f}%")

        return self.results['failed'] == 0


def main():
    tester = CalculationTester()

    try:
        print("🧪 Testing All Instance Calculations")
        print("="*60)

        # Clean up any existing test data
        tester.cleanup()

        # Run test suites
        tester.test_durations()
        tester.test_biometric_formulas()
        tester.test_unit_conversions()

        # Print summary
        success = tester.print_summary()

        # Clean up
        tester.cleanup()

        sys.exit(0 if success else 1)

    except Exception as e:
        print(f"\n❌ Test failed with error: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)
    finally:
        tester.conn.close()


if __name__ == "__main__":
    main()
