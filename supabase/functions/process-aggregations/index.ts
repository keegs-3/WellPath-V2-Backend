// =====================================================
// Process Aggregations Edge Function
// =====================================================
// Automatically triggered after patient_data_entries INSERT/UPDATE
// Recalculates affected aggregations and updates cache
//
// Flow:
// 1. Data entry inserted → instance calculations run → aggregations triggered
// 2. Determine which aggregations are affected
// 3. Recalculate aggregations for all configured periods
// 4. Update aggregation_results_cache
//
// Created: 2025-10-23
// =====================================================

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabaseClient = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const { user_id, field_id, entry_date } = await req.json()

    if (!user_id || !field_id || !entry_date) {
      throw new Error('user_id, field_id, and entry_date are required')
    }

    console.log(`\n========== PROCESSING AGGREGATIONS ==========`)
    console.log(`User: ${user_id}`)
    console.log(`Field: ${field_id}`)
    console.log(`Date: ${entry_date}`)

    // 1. Find affected aggregations (directly or via instance calculations)
    const { data: affectedAggs, error: aggsError } = await supabaseClient
      .rpc('get_affected_aggregations', {
        p_field_id: field_id
      })

    if (aggsError) {
      console.error('Error finding affected aggregations:', aggsError)
      throw aggsError
    }

    if (!affectedAggs || affectedAggs.length === 0) {
      console.log('No aggregations affected by this field')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No aggregations to update',
          aggregations_updated: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Found ${affectedAggs.length} affected aggregations`)

    // 2. Process each affected aggregation
    const updatedAggs = []
    const entryDateObj = new Date(entry_date)

    for (const agg of affectedAggs) {
      console.log(`\nProcessing: ${agg.agg_metric_id}`)

      try {
        // Get configured periods for this aggregation
        const { data: periods, error: periodsError } = await supabaseClient
          .from('aggregation_metrics_periods')
          .select('period_id')
          .eq('agg_metric_id', agg.agg_metric_id)

        if (periodsError) {
          console.error(`Error getting periods for ${agg.agg_metric_id}:`, periodsError)
          continue
        }

        // Get calculation types for this aggregation
        const { data: calcTypes, error: calcTypesError } = await supabaseClient
          .from('aggregation_metrics_calculation_types')
          .select('calculation_type_id')
          .eq('aggregation_metric_id', agg.agg_metric_id)

        if (calcTypesError) {
          console.error(`Error getting calc types for ${agg.agg_metric_id}:`, calcTypesError)
          continue
        }

        // Process each period
        for (const periodRow of periods || []) {
          const period_id = periodRow.period_id

          // Get aggregation dependencies (get all, handle multiple dependencies)
          const { data: depsArray, error: depsError } = await supabaseClient
            .from('aggregation_metrics_dependencies')
            .select('*')
            .eq('agg_metric_id', agg.agg_metric_id)

          if (depsError || !depsArray || depsArray.length === 0) {
            console.log(`No dependencies found for ${agg.agg_metric_id}`)
            continue
          }

          // Use the first dependency (should only be one per aggregation now)
          const deps = depsArray[0]

          // Special handling for hourly periods: process all 24 hours
          if (period_id === 'hourly') {
            // For hourly aggregations, we process all 24 hours (0-23) for the entry_date
            // The database function calculate_field_aggregation now handles timezone-aware
            // matching by using entry_date (local calendar date) and calculating local hour
            // from entry_timestamp using patient timezone or inferred offset
            for (let hour = 0; hour < 24; hour++) {
              // Get UTC timestamp boundaries for this hour using database function
              // These represent the local hour boundaries (hour 18 = 6PM local)
              const { data: hourStartData, error: startError } = await supabaseClient
                .rpc('get_period_start', {
                  p_date: entry_date,
                  p_period_type: 'hourly',
                  p_hour: hour
                })
              
              const { data: hourEndData, error: endError } = await supabaseClient
                .rpc('get_period_end', {
                  p_date: entry_date,
                  p_period_type: 'hourly',
                  p_hour: hour
                })
              
              const hourStart = hourStartData
              const hourEnd = hourEndData
              
              if (startError || endError || !hourStart || !hourEnd) {
                console.error(`Error getting hour bounds for hour ${hour}:`, startError || endError)
                continue
              }

              // Calculate aggregation for this hour
              if (deps.dependency_type === 'field' || deps.dependency_type === 'data_field') {
                const { data: calcResult, error: calcError } = await supabaseClient
                  .rpc('calculate_field_aggregation', {
                    p_patient_id: user_id,
                    p_field_id: deps.data_entry_field_id,
                    p_period_start: hourStart,
                    p_period_end: hourEnd,
                    p_calculation_type: calcTypes?.[0]?.calculation_type_id || 'SUM',
                    p_period_type: 'hourly',
                    p_filter_conditions: deps.filter_conditions || null
                  })

                if (!calcError && calcResult !== null) {
                  // Update cache for each calculation type for this hour
                  for (const calcTypeRow of calcTypes || []) {
                    const calc_type = calcTypeRow.calculation_type_id
                    
                    // For AVG, recalculate
                    let finalValue = calcResult
                    if (calc_type === 'AVG') {
                      const { data: avgResult } = await supabaseClient
                        .rpc('calculate_field_aggregation', {
                          p_patient_id: user_id,
                          p_field_id: deps.data_entry_field_id,
                          p_period_start: hourStart,
                          p_period_end: hourEnd,
                          p_calculation_type: 'AVG',
                          p_period_type: 'hourly',
                          p_filter_conditions: deps.filter_conditions || null
                        })
                      if (avgResult !== null) finalValue = avgResult
                    }

                    if (finalValue !== null && finalValue !== 0) {
                      await updateAggregationCache(
                        supabaseClient,
                        user_id,
                        agg.agg_metric_id,
                        period_id,
                        calc_type,
                        hourStart,
                        hourEnd,
                        finalValue
                      )

                      updatedAggs.push({
                        agg_metric_id: agg.agg_metric_id,
                        period_id,
                        calc_type,
                        hour,
                        value: finalValue
                      })
                    }
                  }
                }
              }
            }
            continue // Skip the regular period processing for hourly
          }

          // For non-hourly periods, use regular processing
          // Calculate period bounds containing the entry_date
          const periodBounds = getPeriodBounds(period_id, entryDateObj)

          // Calculate aggregation value based on dependency type
          let aggValue = null

          if (deps.dependency_type === 'field' || deps.dependency_type === 'data_field') {
            // Use database function which properly handles filter_conditions
            const { data: calcResult, error: calcError } = await supabaseClient
              .rpc('calculate_field_aggregation', {
                p_patient_id: user_id,
                p_field_id: deps.data_entry_field_id,
                p_period_start: periodBounds.period_start,
                p_period_end: periodBounds.period_end,
                p_calculation_type: calcTypes?.[0]?.calculation_type_id || 'SUM',
                p_period_type: period_id,
                p_filter_conditions: deps.filter_conditions || null
              })

            if (calcError) {
              console.error(`Error calculating aggregation for ${agg.agg_metric_id}:`, calcError)
              continue
            }

            aggValue = calcResult
          } else if (deps.dependency_type === 'instance_calculation') {
            // Instance calculation aggregation
            aggValue = await calculateInstanceAggregation(
              supabaseClient,
              user_id,
              deps.instance_calculation_id,
              period_id,
              periodBounds,
              calcTypes?.[0]?.calculation_type_id || 'SUM'
            )
          } else if (deps.dependency_type === 'cross_event') {
            // Cross-event aggregation (e.g., variety calculations)
            aggValue = await calculateCrossEventAggregation(
              supabaseClient,
              user_id,
              agg,
              deps,
              period_id,
              periodBounds,
              calcTypes?.[0]?.calculation_type_id || 'COUNT_DISTINCT'
            )
          }

          // Update cache for each calculation type
          for (const calcTypeRow of calcTypes || []) {
            const calc_type = calcTypeRow.calculation_type_id

            // For AVG calculations, recalculate based on the data
            let finalValue = aggValue
            if (calc_type === 'AVG' && aggValue !== null && (deps.dependency_type === 'field' || deps.dependency_type === 'data_field')) {
              const { data: avgResult, error: avgError } = await supabaseClient
                .rpc('calculate_field_aggregation', {
                  p_patient_id: user_id,
                  p_field_id: deps.data_entry_field_id,
                  p_period_start: periodBounds.period_start,
                  p_period_end: periodBounds.period_end,
                  p_calculation_type: 'AVG',
                  p_period_type: period_id,
                  p_filter_conditions: deps.filter_conditions || null
                })
              
              if (!avgError && avgResult !== null) {
                finalValue = avgResult
              }
            }

            if (finalValue !== null) {
              await updateAggregationCache(
                supabaseClient,
                user_id,
                agg.agg_metric_id,
                period_id,
                calc_type,
                periodBounds.period_start,
                periodBounds.period_end,
                finalValue
              )

              updatedAggs.push({
                agg_metric_id: agg.agg_metric_id,
                period_id,
                calc_type,
                value: finalValue
              })

              console.log(`  ✅ ${period_id}/${calc_type}: ${finalValue}`)
            }
          }
        }
      } catch (aggError) {
        console.error(`Error processing ${agg.agg_metric_id}:`, aggError)
        // Continue with other aggregations
      }
    }

    console.log(`\n========== AGGREGATIONS COMPLETE ==========`)
    console.log(`Updated ${updatedAggs.length} aggregation cache entries`)

    return new Response(
      JSON.stringify({
        success: true,
        user_id,
        aggregations_updated: updatedAggs.length,
        updated: updatedAggs
      }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      }
    )

  } catch (error) {
    console.error('ERROR:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      }
    )
  }
})

// =====================================================
// Calculate Field Aggregation
// =====================================================
async function calculateFieldAggregation(
  supabase: any,
  user_id: string,
  field_id: string,
  period_id: string,
  periodBounds: any,
  calc_type: string
): Promise<number | null> {

  let aggregateFunc = 'SUM'
  if (calc_type === 'AVG') aggregateFunc = 'AVG'
  else if (calc_type === 'COUNT') aggregateFunc = 'COUNT'
  else if (calc_type === 'COUNT_DISTINCT') aggregateFunc = 'COUNT'

  const { data, error } = await supabase
    .from('patient_data_entries')
    .select('value_quantity')
    .eq('user_id', user_id)
    .eq('field_id', field_id)
    .gte('entry_date', periodBounds.period_start)
    .lte('entry_date', periodBounds.period_end)
    .not('source', 'eq', 'deleted')

  if (error) {
    console.error('Error querying field data:', error)
    return null
  }

  if (!data || data.length === 0) return null

  const values = data.map(d => d.value_quantity).filter(v => v !== null)

  if (values.length === 0) return null

  switch (calc_type) {
    case 'SUM':
      return values.reduce((sum, val) => sum + val, 0)
    case 'AVG':
      return values.reduce((sum, val) => sum + val, 0) / values.length
    case 'COUNT':
    case 'COUNT_DISTINCT':
      return values.length
    default:
      return values.reduce((sum, val) => sum + val, 0)
  }
}

// =====================================================
// Calculate Instance Calculation Aggregation
// =====================================================
async function calculateInstanceAggregation(
  supabase: any,
  user_id: string,
  instance_calc_id: string,
  period_id: string,
  periodBounds: any,
  calc_type: string
): Promise<number | null> {

  // Get output field from instance calculation
  const { data: calcData, error: calcError } = await supabase
    .from('instance_calculations')
    .select('calculation_config')
    .eq('calc_id', instance_calc_id)
    .single()

  if (calcError || !calcData) return null

  const output_field = calcData.calculation_config?.output_field

  if (!output_field) return null

  // Query the calculated field
  return calculateFieldAggregation(
    supabase,
    user_id,
    output_field,
    period_id,
    periodBounds,
    calc_type
  )
}

// =====================================================
// Calculate Cross-Event Aggregation (Variety, etc.)
// =====================================================
async function calculateCrossEventAggregation(
  supabase: any,
  user_id: string,
  agg: any,
  deps: any,
  period_id: string,
  periodBounds: any,
  calc_type: string
): Promise<number | null> {

  // For variety calculations, count distinct values in the reference field
  if (calc_type === 'COUNT_DISTINCT' && deps.value_reference_field_id) {
    const { data, error } = await supabase
      .from('patient_data_entries')
      .select('value_reference')
      .eq('user_id', user_id)
      .eq('field_id', deps.value_reference_field_id)
      .gte('entry_date', periodBounds.period_start)
      .lte('entry_date', periodBounds.period_end)
      .not('source', 'eq', 'deleted')

    if (error || !data) return null

    const uniqueValues = new Set(
      data
        .map(d => d.value_reference)
        .filter(v => v !== null && v !== '')
    )

    return uniqueValues.size
  }

  return null
}

// =====================================================
// Update Aggregation Cache
// =====================================================
async function updateAggregationCache(
  supabase: any,
  user_id: string,
  agg_metric_id: string,
  period_type: string,
  calculation_type_id: string,
  period_start: string,
  period_end: string,
  value: number
): Promise<void> {

  const { error } = await supabase
    .from('aggregation_results_cache')
    .upsert({
      user_id,
      agg_metric_id,
      period_type,
      calculation_type_id,
      period_start,
      period_end,
      value,
      last_computed_at: new Date().toISOString(),
      is_stale: false,
      data_points_count: 1 // TODO: Track actual count
    }, {
      onConflict: 'user_id,agg_metric_id,period_type,calculation_type_id,period_start'
    })

  if (error) {
    console.error('Error updating cache:', error)
  }
}

// =====================================================
// Get Period Bounds
// =====================================================
function getPeriodBounds(period_id: string, reference_date: Date): any {
  const year = reference_date.getFullYear()
  const month = reference_date.getMonth()
  const date = reference_date.getDate()

  switch (period_id) {
    case 'hourly':
      const hour = reference_date.getHours()
      const period_start_hour = new Date(year, month, date, hour, 0, 0)
      const period_end_hour = new Date(year, month, date, hour, 59, 59)
      return {
        period_start: period_start_hour.toISOString().split('T')[0] + ' ' + period_start_hour.toISOString().split('T')[1].split('.')[0],
        period_end: period_end_hour.toISOString().split('T')[0] + ' ' + period_end_hour.toISOString().split('T')[1].split('.')[0]
      }

    case 'daily':
      return {
        period_start: new Date(year, month, date).toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }

    case 'weekly':
      // Start of week (Monday)
      const dayOfWeek = reference_date.getDay()
      const diff = dayOfWeek === 0 ? 6 : dayOfWeek - 1
      const weekStart = new Date(year, month, date - diff)
      return {
        period_start: weekStart.toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }

    case 'monthly':
      return {
        period_start: new Date(year, month, 1).toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }

    case '6month':
      const sixMonthsAgo = new Date(year, month - 5, 1)
      return {
        period_start: sixMonthsAgo.toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }

    case 'yearly':
      return {
        period_start: new Date(year, 0, 1).toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }

    default:
      return {
        period_start: new Date(year, month, date).toISOString().split('T')[0],
        period_end: new Date(year, month, date).toISOString().split('T')[0]
      }
  }
}
