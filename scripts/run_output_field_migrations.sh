#!/bin/bash

# Run migrations for output/calculated fields

PGPASSWORD='pd3Wc7ELL20OZYkE'
DB_URL="postgresql://postgres.csotzmardnvrpdhlogjm@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

migrations=(
  "20251021_add_session_counts_to_field_registry.sql"
  "20251021_create_session_count_calculations.sql"
  "20251021_create_missing_instance_calculations.sql"
  "20251021_create_missing_instance_calculations_part1.sql"
  "20251021_create_missing_instance_calculations_part2.sql"
  "20251021_create_all_duration_calculations.sql"
)

echo "Running output field migrations..."
echo "=================================="

for migration in "${migrations[@]}"; do
  filepath="supabase/migrations/$migration"

  if [ -f "$filepath" ]; then
    echo -e "\n Running $migration..."
    PGPASSWORD=$PGPASSWORD psql "$DB_URL" -f "$filepath" --quiet 2>&1 | head -10
  else
    echo " ⚠️  $migration not found"
  fi
done

echo -e "\n=================================="
echo "✅ Checking field count..."
PGPASSWORD=$PGPASSWORD psql "$DB_URL" -c "SELECT COUNT(*) as total, COUNT(*) FILTER (WHERE is_active = true) as active FROM data_entry_fields"
