"""
Test Instance Calculations Edge Function

Tests the cross-population flow:
1. Insert vegetable intake data
2. Trigger instance calculations
3. Verify auto-calculated fiber/protein entries were created

Usage:
    python scripts/test_instance_calculations.py
"""

import os
import requests
import json
import uuid
from datetime import datetime
from supabase import create_client, Client
from dotenv import load_dotenv

# Load environment
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_ANON_KEY')
EDGE_FUNCTION_URL = f"{SUPABASE_URL}/functions/v1/run-instance-calculations"

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)


def create_test_user():
    """Create a test user for this run."""
    # Use a real user from the database
    test_user_id = "f9c3f236-16b9-4fc8-a682-5dfbbeaef9f7"
    print(f"Using test user: {test_user_id}")
    return test_user_id


def insert_vegetable_intake(user_id: str, vegetable_type: str, quantity: float):
    """
    Insert vegetable intake data entries.

    Simulates user entering: Vegetables → Broccoli → 2 servings
    """
    event_instance_id = str(uuid.uuid4())
    timestamp = datetime.now().isoformat()
    entry_date = datetime.now().date().isoformat()

    print(f"\n=== Inserting Vegetable Intake ===")
    print(f"User: {user_id}")
    print(f"Event Instance ID: {event_instance_id}")
    print(f"Vegetable: {vegetable_type}")
    print(f"Quantity: {quantity} servings")
    print(f"Timestamp: {timestamp}")

    entries = [
        {
            'user_id': user_id,
            'event_instance_id': event_instance_id,
            'field_id': 'DEF_VEGETABLE_TYPE',
            'entry_date': entry_date,
            'entry_timestamp': timestamp,
            'value_reference': vegetable_type,
            'source': 'manual'
        },
        {
            'user_id': user_id,
            'event_instance_id': event_instance_id,
            'field_id': 'DEF_VEGETABLE_QUANTITY',
            'entry_date': entry_date,
            'entry_timestamp': timestamp,
            'value_quantity': quantity,
            'source': 'manual'
        },
        {
            'user_id': user_id,
            'event_instance_id': event_instance_id,
            'field_id': 'DEF_VEGETABLE_TIME',
            'entry_date': entry_date,
            'entry_timestamp': timestamp,
            'value_timestamp': timestamp,
            'source': 'manual'
        }
    ]

    try:
        result = supabase.table('patient_data_entries').insert(entries).execute()
        print(f"✅ Inserted {len(result.data)} manual entries")
        return event_instance_id
    except Exception as e:
        print(f"❌ Error inserting entries: {e}")
        raise


def trigger_instance_calculations(user_id: str, event_instance_id: str):
    """Call the edge function to run instance calculations."""
    print(f"\n=== Triggering Instance Calculations ===")

    payload = {
        'user_id': user_id,
        'event_instance_id': event_instance_id
    }

    headers = {
        'Authorization': f'Bearer {SUPABASE_KEY}',
        'Content-Type': 'application/json'
    }

    print(f"Calling: {EDGE_FUNCTION_URL}")
    print(f"Payload: {json.dumps(payload, indent=2)}")

    try:
        response = requests.post(EDGE_FUNCTION_URL, json=payload, headers=headers)

        if response.status_code == 200:
            result = response.json()
            print(f"✅ Calculations Complete!")
            print(f"Calculations run: {result.get('calculations_run', 0)}")
            print(f"Entries created: {result.get('entries_created', 0)}")
            print(f"Created fields: {result.get('created_fields', [])}")
            return result
        else:
            print(f"❌ Edge function error: {response.status_code}")
            print(response.text)
            return None

    except Exception as e:
        print(f"❌ Error calling edge function: {e}")
        return None


def verify_auto_calculated_entries(user_id: str, event_instance_id: str):
    """Check if the auto-calculated entries were created."""
    print(f"\n=== Verifying Auto-Calculated Entries ===")

    try:
        # Get all entries for this event instance
        result = supabase.table('patient_data_entries')\
            .select('*')\
            .eq('user_id', user_id)\
            .eq('event_instance_id', event_instance_id)\
            .execute()

        entries = result.data

        print(f"\nTotal entries found: {len(entries)}")
        print(f"\n{'Field ID':<35} {'Source':<15} {'Value':<20}")
        print("-" * 70)

        for entry in sorted(entries, key=lambda x: x['field_id']):
            value = entry.get('value_quantity') or entry.get('value_reference') or entry.get('value_text', '')
            source = entry.get('source', 'unknown')
            print(f"{entry['field_id']:<35} {source:<15} {str(value):<20}")

        # Check for expected auto-calculated fields
        auto_fields = [e for e in entries if e.get('source') == 'auto_calculated']
        print(f"\n✅ Auto-calculated entries: {len(auto_fields)}")

        expected_fields = ['DEF_FIBER_SOURCE', 'DEF_FIBER_SERVINGS', 'DEF_FIBER_GRAMS']
        for field_id in expected_fields:
            entry = next((e for e in entries if e['field_id'] == field_id), None)
            if entry:
                print(f"  ✅ {field_id}: {entry.get('value_quantity') or entry.get('value_reference')}")
            else:
                print(f"  ❌ {field_id}: NOT FOUND")

        return len(auto_fields) > 0

    except Exception as e:
        print(f"❌ Error verifying entries: {e}")
        return False


def cleanup_test_data(user_id: str, event_instance_id: str):
    """Delete test data entries."""
    print(f"\n=== Cleaning Up Test Data ===")

    try:
        result = supabase.table('patient_data_entries')\
            .delete()\
            .eq('user_id', user_id)\
            .eq('event_instance_id', event_instance_id)\
            .execute()

        print(f"✅ Deleted test entries")

    except Exception as e:
        print(f"❌ Error cleaning up: {e}")


def main():
    """Run the full test flow."""
    print("=" * 70)
    print("INSTANCE CALCULATIONS TEST")
    print("=" * 70)

    # Create/get test user
    user_id = create_test_user()

    # Test 1: Vegetables → Fiber cross-population
    print("\n\n" + "=" * 70)
    print("TEST 1: Vegetables → Fiber Auto-Population")
    print("=" * 70)

    event_instance_id = insert_vegetable_intake(user_id, 'broccoli', 2.0)

    if event_instance_id:
        # Trigger calculations
        result = trigger_instance_calculations(user_id, event_instance_id)

        # Verify results
        if result:
            success = verify_auto_calculated_entries(user_id, event_instance_id)

            if success:
                print("\n" + "=" * 70)
                print("✅ TEST PASSED!")
                print("=" * 70)
            else:
                print("\n" + "=" * 70)
                print("❌ TEST FAILED - Auto-calculated entries not found")
                print("=" * 70)

        # Cleanup
        input("\nPress Enter to cleanup test data...")
        cleanup_test_data(user_id, event_instance_id)

    print("\n" + "=" * 70)
    print("TEST COMPLETE")
    print("=" * 70)


if __name__ == '__main__':
    main()
