#!/usr/bin/env python3
"""
Create Test User and Generate Comprehensive Data
1. Creates auth user with specified UUID
2. Generates 30 days of test data across all categories
3. Processes aggregations
"""

import psycopg2
from datetime import datetime, timedelta
import random
import uuid
import sys

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'
USER_ID = '8b79ce33-028b-4f49-8268-32041e3efa82'  # FROM ACTUAL XCODE CONSOLE
USER_EMAIL = 'mobile.app.test@wellpath.dev'

def create_auth_user(conn):
    """Create auth user if doesn't exist"""
    print("\n👤 Step 1: Creating auth user...")
    print("=" * 60)

    with conn.cursor() as cur:
        # Check if user exists
        cur.execute('SELECT id FROM auth.users WHERE id = %s', (USER_ID,))
        if cur.fetchone():
            print(f"✅ User already exists: {USER_EMAIL}")
            return

        # Create user in auth.users
        cur.execute("""
            INSERT INTO auth.users (
                id,
                instance_id,
                email,
                encrypted_password,
                email_confirmed_at,
                created_at,
                updated_at,
                aud,
                role
            ) VALUES (
                %s,
                '00000000-0000-0000-0000-000000000000',
                %s,
                crypt('testpassword123', gen_salt('bf')),
                NOW(),
                NOW(),
                NOW(),
                'authenticated',
                'authenticated'
            )
            ON CONFLICT (id) DO NOTHING
        """, (USER_ID, USER_EMAIL))

        conn.commit()
        print(f"✅ Created user: {USER_EMAIL}")
        print(f"   User ID: {USER_ID}")
        print(f"   Password: testpassword123")

def generate_all_test_data(conn):
    """Generate comprehensive test data"""
    print("\n📊 Step 2: Generating test data...")
    print("=" * 60)

    # Import generation functions from the other script
    sys.path.append('/Users/keegs/Documents/GitHub/WellPath-V2-Backend/scripts')

    entries = []
    end_date = datetime.now().date()
    start_date = end_date - timedelta(days=30)

    for day_offset in range(30):
        current_date = start_date + timedelta(days=day_offset)

        # Generate protein (3 meals/day)
        for hour in [8, 12, 18]:
            event_id = str(uuid.uuid4())
            timestamp = datetime.combine(current_date, datetime.min.time()).replace(hour=hour)
            entries.extend([
                (USER_ID, 'DEF_PROTEIN_GRAMS', current_date, timestamp, random.randint(20, 40), None, None, 'manual', event_id),
                (USER_ID, 'DEF_PROTEIN_TYPE', current_date, timestamp, None, random.choice(['lean_protein', 'plant_based']), None, 'manual', event_id),
            ])

        # Generate sleep stages
        bedtime = datetime.combine(current_date - timedelta(days=1), datetime.min.time()).replace(hour=22, minute=30)
        for _ in range(5):  # 5 cycles
            event_id = str(uuid.uuid4())
            deep_start = bedtime + timedelta(minutes=random.randint(0, 60))
            deep_end = deep_start + timedelta(minutes=random.randint(15, 30))
            entries.extend([
                (USER_ID, 'DEF_DEEP_SLEEP_START', current_date, deep_start, None, None, deep_start, 'healthkit', event_id),
                (USER_ID, 'DEF_DEEP_SLEEP_END', current_date, deep_end, None, None, deep_end, 'healthkit', event_id),
            ])
            bedtime = deep_end + timedelta(minutes=40)

        # Generate water (6 entries/day)
        for _ in range(6):
            event_id = str(uuid.uuid4())
            timestamp = datetime.combine(current_date, datetime.min.time()).replace(hour=random.randint(7, 20))
            entries.append((USER_ID, 'DEF_WATER_QUANTITY', current_date, timestamp, random.randint(240, 480), None, None, 'manual', event_id))

        # Generate steps
        event_id = str(uuid.uuid4())
        timestamp = datetime.combine(current_date, datetime.min.time()).replace(hour=23, minute=59)
        entries.append((USER_ID, 'DEF_STEPS', current_date, timestamp, random.randint(6000, 12000), None, None, 'healthkit', event_id))

    print(f"📝 Inserting {len(entries):,} data entries...")

    with conn.cursor() as cur:
        cur.executemany("""
            INSERT INTO patient_data_entries (
                user_id, field_id, entry_date, entry_timestamp,
                value_quantity, value_reference, value_timestamp,
                source, event_instance_id
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            ON CONFLICT DO NOTHING
        """, entries)

        conn.commit()
        print(f"✅ Inserted {cur.rowcount:,} entries")

def process_aggregations(conn):
    """Process all aggregations for the user"""
    print("\n⚙️  Step 3: Processing aggregations...")
    print("=" * 60)

    with conn.cursor() as cur:
        # Get all dates
        cur.execute("""
            SELECT DISTINCT entry_date
            FROM patient_data_entries
            WHERE user_id = %s
            ORDER BY entry_date
        """, (USER_ID,))

        dates = [row[0] for row in cur.fetchall()]
        print(f"📅 Processing {len(dates)} days...")

        # Get all fields
        cur.execute("""
            SELECT DISTINCT field_id
            FROM patient_data_entries
            WHERE user_id = %s
        """, (USER_ID,))

        fields = [row[0] for row in cur.fetchall()]
        print(f"📊 Processing {len(fields)} fields...")

        total = 0
        for field_id in fields:
            for entry_date in dates:
                cur.execute("""
                    SELECT process_field_aggregations(%s, %s, %s)
                """, (USER_ID, field_id, entry_date))

                result = cur.fetchone()[0]
                if result:
                    total += result

        conn.commit()
        print(f"✅ Created {total:,} aggregations")

def main():
    print("🚀 Creating Test User and Generating Data")
    print(f"User ID: {USER_ID}")
    print(f"Email: {USER_EMAIL}")
    print("=" * 60)

    conn = psycopg2.connect(DB_URL)

    try:
        create_auth_user(conn)
        generate_all_test_data(conn)
        process_aggregations(conn)

        print("\n" + "=" * 60)
        print("✅ COMPLETE!")
        print("=" * 60)
        print(f"\n📱 Your mobile app can now log in with:")
        print(f"   Email: {USER_EMAIL}")
        print(f"   Password: testpassword123")
        print(f"   User ID: {USER_ID}")

    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()

    finally:
        conn.close()

if __name__ == '__main__':
    main()
