#!/usr/bin/env python3
"""
Add a nap session on 2025-10-28 from 11 AM to 2 PM
to test smart period grouping and nap detection
"""

import os
import uuid
from datetime import datetime, timezone
import psycopg2

# Database connection
conn = psycopg2.connect(
    host="aws-1-us-west-1.pooler.supabase.com",
    port=5432,
    database="postgres",
    user="postgres.csotzmardnvrpdhlogjm",
    password="pd3Wc7ELL20OZYkE"
)

patient_id = "8b79ce33-02b8-4f49-8268-3204130efa82"
entry_date = "2025-10-28"

# Sleep period type IDs
CORE = "d72d03a6-aced-4de2-8f9e-f80f019c9036"
DEEP = "2cce2a0b-3dad-41d7-b52a-3ec5389db3b4"
REM = "3432e9c4-689e-409b-9465-b649053cfe80"
AWAKE = "4ea5ac93-f4c4-4f54-b276-3ef50b7fc431"

# Define nap periods (each with unique event_instance_id)
nap_periods = [
    # 11:00-11:30 CORE (30 min)
    {
        "start": "2025-10-28 11:00:00+00",
        "end": "2025-10-28 11:30:00+00",
        "type": CORE
    },
    # 11:30-12:00 DEEP (30 min)
    {
        "start": "2025-10-28 11:30:00+00",
        "end": "2025-10-28 12:00:00+00",
        "type": DEEP
    },
    # 12:00-12:45 REM (45 min)
    {
        "start": "2025-10-28 12:00:00+00",
        "end": "2025-10-28 12:45:00+00",
        "type": REM
    },
    # 12:45-12:50 AWAKE (5 min)
    {
        "start": "2025-10-28 12:45:00+00",
        "end": "2025-10-28 12:50:00+00",
        "type": AWAKE
    },
    # 12:50-13:30 CORE (40 min)
    {
        "start": "2025-10-28 12:50:00+00",
        "end": "2025-10-28 13:30:00+00",
        "type": CORE
    },
    # 13:30-14:00 REM (30 min)
    {
        "start": "2025-10-28 13:30:00+00",
        "end": "2025-10-28 14:00:00+00",
        "type": REM
    },
]

try:
    cur = conn.cursor()

    print("Adding nap periods...")
    for i, period in enumerate(nap_periods):
        event_id = str(uuid.uuid4())

        # Insert START
        cur.execute("""
            INSERT INTO patient_data_entries
            (patient_id, field_id, entry_date, value_timestamp, event_instance_id, source)
            VALUES (%s, 'DEF_SLEEP_PERIOD_START', %s, %s, %s, 'wellpath_input')
        """, (patient_id, entry_date, period["start"], event_id))

        # Insert END
        cur.execute("""
            INSERT INTO patient_data_entries
            (patient_id, field_id, entry_date, value_timestamp, event_instance_id, source)
            VALUES (%s, 'DEF_SLEEP_PERIOD_END', %s, %s, %s, 'wellpath_input')
        """, (patient_id, entry_date, period["end"], event_id))

        # Insert TYPE
        cur.execute("""
            INSERT INTO patient_data_entries
            (patient_id, field_id, entry_date, value_reference, event_instance_id, source)
            VALUES (%s, 'DEF_SLEEP_PERIOD_TYPE', %s, %s, %s, 'wellpath_input')
        """, (patient_id, entry_date, period["type"], event_id))

        print(f"  Period {i+1}: {period['start']} -> {period['end']}")

    conn.commit()
    print("\n✅ Nap created successfully!")
    print("   Total: 6 adjacent periods (11:00 AM - 2:00 PM)")
    print("   Sleep: 175 min (Core 70 + Deep 30 + REM 75)")
    print("   Awake: 5 min")
    print("   Total duration: 180 min (3 hours)")

except Exception as e:
    conn.rollback()
    print(f"❌ Error: {e}")
finally:
    cur.close()
    conn.close()
