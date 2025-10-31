#!/usr/bin/env python3
"""
Bottom-Up Coverage Audit
Shows complete coverage across the entire system:
- Instance Calculations
- Event Types
- Data Entry Fields
- Aggregation Metrics
- Display Metrics
"""

import psycopg2
from psycopg2.extras import RealDictCursor

DB_URL = 'postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres'

def print_section(title):
    print(f"\n{'='*80}")
    print(f"  {title}")
    print(f"{'='*80}\n")

def main():
    print("🔍 COMPLETE SYSTEM COVERAGE AUDIT")
    print("="*80)

    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor(cursor_factory=RealDictCursor)

    # ========================================
    # 1. INSTANCE CALCULATIONS
    # ========================================
    print_section("1. INSTANCE CALCULATIONS")

    cur.execute("""
        SELECT
            ic.calc_id,
            ic.calc_name,
            ic.description,
            COUNT(DISTINCT icd.data_entry_field_id) as field_count,
            STRING_AGG(DISTINCT icd.data_entry_field_id, ', ' ORDER BY icd.data_entry_field_id) as fields
        FROM instance_calculations ic
        LEFT JOIN instance_calculations_dependencies icd
            ON ic.calc_id = icd.instance_calculation_id
        WHERE ic.is_active = true
        GROUP BY ic.calc_id, ic.calc_name, ic.description
        ORDER BY ic.calc_id
    """)
    instance_calcs = cur.fetchall()

    print(f"📊 Total Instance Calculations: {len(instance_calcs)}")
    for calc in instance_calcs:
        print(f"\n  {calc['calc_id']}")
        print(f"    Name: {calc['calc_name']}")
        print(f"    Fields: {calc['field_count']} ({calc['fields'] or 'NONE'})")

    # ========================================
    # 2. EVENT TYPES
    # ========================================
    print_section("2. EVENT TYPES")

    cur.execute("""
        SELECT
            et.event_type_id,
            et.name,
            et.category,
            et.supports_manual_entry,
            et.supports_api_ingestion,
            COUNT(DISTINCT etd.data_entry_field_id) as field_count,
            STRING_AGG(DISTINCT etd.data_entry_field_id, ', ' ORDER BY etd.data_entry_field_id) as fields
        FROM event_types et
        LEFT JOIN event_types_dependencies etd
            ON et.event_type_id = etd.event_type_id
        WHERE et.is_active = true
        GROUP BY et.event_type_id, et.name, et.category, et.supports_manual_entry, et.supports_api_ingestion
        ORDER BY et.category, et.event_type_id
    """)
    event_types = cur.fetchall()

    # Group by category
    by_category = {}
    for et in event_types:
        cat = et['category'] or 'uncategorized'
        if cat not in by_category:
            by_category[cat] = []
        by_category[cat].append(et)

    print(f"📊 Total Event Types: {len(event_types)}")
    for category, events in sorted(by_category.items()):
        print(f"\n  {category.upper()} ({len(events)} events)")
        for et in events:
            print(f"    {et['event_type_id']}: {et['name']}")
            print(f"      Manual: {et['supports_manual_entry']}, API: {et['supports_api_ingestion']}")
            print(f"      Fields: {et['field_count']} ({et['fields'] or 'NONE'})")

    # ========================================
    # 3. DATA ENTRY FIELDS
    # ========================================
    print_section("3. DATA ENTRY FIELDS")

    cur.execute("""
        SELECT
            def.field_id,
            def.field_name,
            def.field_type,
            def.data_type,
            def.reference_table,
            def.is_active,
            -- Has aggregation dependencies?
            EXISTS(
                SELECT 1 FROM aggregation_metrics_dependencies amd
                WHERE amd.data_entry_field_id = def.field_id
            ) as has_agg_dependency,
            -- Count of aggregations using this field
            (
                SELECT COUNT(DISTINCT agg_metric_id)
                FROM aggregation_metrics_dependencies amd
                WHERE amd.data_entry_field_id = def.field_id
            ) as agg_count,
            -- Used in event dependencies?
            EXISTS(
                SELECT 1 FROM event_types_dependencies etd
                WHERE etd.data_entry_field_id = def.field_id
            ) as used_in_events,
            -- Used in instance calculations?
            EXISTS(
                SELECT 1 FROM instance_calculations_dependencies icd
                WHERE icd.data_entry_field_id = def.field_id
            ) as used_in_calcs
        FROM data_entry_fields def
        WHERE def.is_active = true
        ORDER BY def.field_id
    """)
    fields = cur.fetchall()

    # Categorize fields
    with_aggs = [f for f in fields if f['has_agg_dependency']]
    without_aggs = [f for f in fields if not f['has_agg_dependency']]

    print(f"📊 Total Data Entry Fields: {len(fields)}")
    print(f"  ✅ With Aggregations: {len(with_aggs)} ({len(with_aggs)/len(fields)*100:.1f}%)")
    print(f"  ❌ Without Aggregations: {len(without_aggs)} ({len(without_aggs)/len(fields)*100:.1f}%)")

    print(f"\n  WITHOUT AGGREGATIONS ({len(without_aggs)}):")
    for f in without_aggs:
        usage = []
        if f['used_in_events']:
            usage.append('events')
        if f['used_in_calcs']:
            usage.append('calcs')
        usage_str = f" (used in: {', '.join(usage)})" if usage else " (UNUSED)"
        print(f"    {f['field_id']}: {f['field_name']} [{f['field_type']}]{usage_str}")

    print(f"\n  WITH AGGREGATIONS ({len(with_aggs)}):")
    for f in with_aggs:
        print(f"    {f['field_id']}: {f['field_name']} ({f['agg_count']} aggregations)")

    # ========================================
    # 4. AGGREGATION METRICS
    # ========================================
    print_section("4. AGGREGATION METRICS")

    cur.execute("""
        SELECT
            am.agg_id,
            am.metric_name,
            am.output_unit,
            -- Count dependencies
            COUNT(DISTINCT amd.data_entry_field_id) as field_count,
            STRING_AGG(DISTINCT amd.data_entry_field_id, ', ' ORDER BY amd.data_entry_field_id) as fields,
            -- Has filter conditions?
            COUNT(DISTINCT CASE WHEN amd.filter_conditions IS NOT NULL THEN amd.agg_metric_id END) > 0 as has_filters,
            -- Count periods
            (SELECT COUNT(*) FROM aggregation_metrics_periods amp WHERE amp.agg_metric_id = am.agg_id) as period_count,
            -- Count calc types
            (SELECT COUNT(*) FROM aggregation_metrics_calculation_types amct WHERE amct.aggregation_metric_id = am.agg_id) as calc_type_count,
            -- Used in display metrics?
            EXISTS(
                SELECT 1 FROM display_metrics_aggregations dma
                WHERE dma.agg_metric_id = am.agg_id
            ) as used_in_display
        FROM aggregation_metrics am
        LEFT JOIN aggregation_metrics_dependencies amd
            ON am.agg_id = amd.agg_metric_id AND amd.dependency_type = 'data_field'
        WHERE am.is_active = true
        GROUP BY am.agg_id, am.metric_name, am.output_unit
        ORDER BY am.agg_id
    """)
    agg_metrics = cur.fetchall()

    # Categorize
    no_deps = [a for a in agg_metrics if a['field_count'] == 0]
    no_periods = [a for a in agg_metrics if a['period_count'] == 0]
    no_calc_types = [a for a in agg_metrics if a['calc_type_count'] == 0]
    not_used = [a for a in agg_metrics if not a['used_in_display']]

    print(f"📊 Total Aggregation Metrics: {len(agg_metrics)}")
    print(f"  ✅ Used in Display Metrics: {len([a for a in agg_metrics if a['used_in_display']])}")
    print(f"  ❌ NOT Used in Display: {len(not_used)}")
    print(f"  ⚠️  No Dependencies: {len(no_deps)}")
    print(f"  ⚠️  No Periods: {len(no_periods)}")
    print(f"  ⚠️  No Calc Types: {len(no_calc_types)}")

    if no_deps:
        print(f"\n  AGGREGATIONS WITHOUT DEPENDENCIES ({len(no_deps)}):")
        for a in no_deps[:20]:  # Limit to first 20
            print(f"    {a['agg_id']}: {a['metric_name']}")
        if len(no_deps) > 20:
            print(f"    ... and {len(no_deps) - 20} more")

    # ========================================
    # 5. DISPLAY METRICS
    # ========================================
    print_section("5. DISPLAY METRICS")

    cur.execute("""
        SELECT
            dm.metric_id,
            dm.metric_name,
            dm.chart_type_id,
            COUNT(DISTINCT dma.agg_metric_id) as agg_count,
            STRING_AGG(DISTINCT dma.agg_metric_id, ', ' ORDER BY dma.agg_metric_id) as agg_ids
        FROM display_metrics dm
        LEFT JOIN display_metrics_aggregations dma
            ON dm.metric_id = dma.metric_id
        WHERE dm.is_active = true
        GROUP BY dm.metric_id, dm.metric_name, dm.chart_type_id
        ORDER BY dm.metric_id
    """)
    display_metrics = cur.fetchall()

    no_aggs = [d for d in display_metrics if d['agg_count'] == 0]

    print(f"📊 Total Display Metrics: {len(display_metrics)}")
    print(f"  ✅ With Aggregations: {len([d for d in display_metrics if d['agg_count'] > 0])}")
    print(f"  ❌ Without Aggregations: {len(no_aggs)}")

    if no_aggs:
        print(f"\n  DISPLAY METRICS WITHOUT AGGREGATIONS ({len(no_aggs)}):")
        for d in no_aggs[:20]:
            print(f"    {d['metric_id']}: {d['metric_name']} [{d['chart_type_id']}]")
        if len(no_aggs) > 20:
            print(f"    ... and {len(no_aggs) - 20} more")

    # ========================================
    # 6. SUMMARY
    # ========================================
    print_section("SUMMARY")

    print(f"Instance Calculations:  {len(instance_calcs)}")
    print(f"Event Types:            {len(event_types)}")
    print(f"Data Entry Fields:      {len(fields)}")
    print(f"  - With Aggregations:  {len(with_aggs)} ({len(with_aggs)/len(fields)*100:.1f}%)")
    print(f"  - Without:            {len(without_aggs)} ({len(without_aggs)/len(fields)*100:.1f}%)")
    print(f"Aggregation Metrics:    {len(agg_metrics)}")
    print(f"  - No Dependencies:    {len(no_deps)}")
    print(f"  - No Periods:         {len(no_periods)}")
    print(f"  - No Calc Types:      {len(no_calc_types)}")
    print(f"  - Not in Display:     {len(not_used)}")
    print(f"Display Metrics:        {len(display_metrics)}")
    print(f"  - Without Aggs:       {len(no_aggs)}")

    print(f"\n{'='*80}")
    print("✅ AUDIT COMPLETE")
    print(f"{'='*80}\n")

    conn.close()

if __name__ == "__main__":
    main()
