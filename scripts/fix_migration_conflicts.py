#!/usr/bin/env python3
"""Add ON CONFLICT clauses to all metric INSERT statements"""

import re

migration_file = '/Users/keegs/Documents/GitHub/WellPath-V2-Backend/supabase/migrations/20251025_consolidate_all_metrics.sql'

with open(migration_file, 'r') as f:
    content = f.read()

# Replace INSERT INTO display_metrics statements that end with );
# with INSERT ... ON CONFLICT ...
pattern = r"(INSERT INTO display_metrics[^;]+?)\);"
replacement = r"\1)\nON CONFLICT (metric_id) DO UPDATE SET screen_id = EXCLUDED.screen_id WHERE display_metrics.screen_id IS NULL;"

content = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open(migration_file, 'w') as f:
    f.write(content)

print("✅ Added ON CONFLICT clauses to all metric INSERT statements")
