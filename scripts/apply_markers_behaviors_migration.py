#!/usr/bin/env python3
"""
Apply the markers and behaviors about content migration
"""

import psycopg2

def apply_migration():
    """Apply the migration file"""
    # Read the migration SQL file
    migration_path = '/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251026_populate_pillars_markers_behaviors_about.sql'

    with open(migration_path, 'r') as f:
        sql = f.read()

    # Connect to the database using connection string from .env
    DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("Applying migration: 20251026_populate_pillars_markers_behaviors_about.sql")
        cur.execute(sql)
        conn.commit()
        print("✅ Migration applied successfully!")

        # Verify data was inserted
        cur.execute("SELECT COUNT(*) FROM wellpath_pillars_markers_about")
        markers_count = cur.fetchone()[0]

        cur.execute("SELECT COUNT(*) FROM wellpath_pillars_behaviors_about")
        behaviors_count = cur.fetchone()[0]

        print(f"✅ Inserted {markers_count} markers about records")
        print(f"✅ Inserted {behaviors_count} behaviors about records")

    except Exception as e:
        conn.rollback()
        print(f"❌ Error applying migration: {e}")
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    apply_migration()
