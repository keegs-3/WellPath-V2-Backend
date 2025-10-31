// Edge Function: Update Biometric Readings from Tracked Data
// SIMPLE VERSION: Just translates aggregation_results_cache → patient_biometric_readings
// The existing WellPath scorer will read from patient_biometric_readings and calculate scores

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Map aggregation metric IDs to biometric names (from biometrics_base table)
const BIOMETRIC_MAPPINGS = {
  'AGG_BMI': 'BMI',
  'AGG_BODY_FAT_PCT': 'Bodyfat',
  'AGG_BODY_FAT_PERCENTAGE': 'Bodyfat',
  'AGG_HIP_TO_WAIST_RATIO': 'Hip-to-Waist Ratio',
  'AGG_SYSTOLIC_BLOOD_PRESSURE': 'Blood Pressure (Systolic)',
  'AGG_DIASTOLIC_BLOOD_PRESSURE': 'Blood Pressure (Diastolic)',
  'AGG_RESTING_HEART_RATE': 'Resting Heart Rate',
  'AGG_DEEP_SLEEP_DURATION': 'Deep Sleep',
  'AGG_REM_SLEEP_DURATION': 'REM Sleep',
  'AGG_TOTAL_SLEEP_DURATION': 'Total Sleep',
  'AGG_HRV': 'HRV',
  'AGG_WATER_CONSUMPTION': 'Water Intake',
  'AGG_STEPS': 'Steps/Day',
  'AGG_GRIP_STRENGTH': 'Grip Strength',
  'AGG_VO2_MAX': 'VO2 Max',
  'AGG_CURRENT_WEIGHT': 'Weight',
}

// Unit mappings for each biometric
const UNIT_MAPPINGS = {
  'BMI': 'kg/m²',
  'Bodyfat': '%',
  'Hip-to-Waist Ratio': 'ratio',
  'Blood Pressure (Systolic)': 'mmHg',
  'Blood Pressure (Diastolic)': 'mmHg',
  'Resting Heart Rate': 'bpm',
  'Deep Sleep': 'hours',
  'REM Sleep': 'hours',
  'Total Sleep': 'hours',
  'HRV': 'ms',
  'Water Intake': 'fl oz',
  'Steps/Day': 'steps',
  'Grip Strength': 'kg',
  'VO2 Max': 'mL/kg/min',
  'Weight': 'kg',
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    )

    const { userId } = await req.json()

    if (!userId) {
      throw new Error('userId is required')
    }

    const results = {
      biometricsUpdated: 0,
      biometrics: [] as any[]
    }

    // Process each biometric metric
    for (const [aggMetricId, biometricName] of Object.entries(BIOMETRIC_MAPPINGS)) {
      const updated = await updateBiometricReading(
        supabase,
        userId,
        aggMetricId,
        biometricName
      )

      if (updated) {
        results.biometricsUpdated++
        results.biometrics.push(updated)
      }
    }

    return new Response(
      JSON.stringify(results),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 200,
      },
    )
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
        status: 400,
      },
    )
  }
})

async function updateBiometricReading(
  supabase: any,
  userId: string,
  aggMetricId: string,
  biometricName: string
): Promise<any | null> {
  // 1. Get latest aggregation value from cache (use monthly AVG)
  const { data: latestAgg, error: aggError } = await supabase
    .from('aggregation_results_cache')
    .select('value, period_end, data_points_count')
    .eq('user_id', userId)
    .eq('agg_metric_id', aggMetricId)
    .eq('calculation_type_id', 'AVG')
    .eq('period_type', 'monthly')
    .order('period_end', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (aggError) {
    console.error(`Error fetching aggregation for ${aggMetricId}:`, aggError)
    return null
  }

  if (!latestAgg) {
    console.log(`No aggregation data for ${aggMetricId}`)
    return null
  }

  // 2. Check if biometric requires minimum data points (from biometric_aggregations_scoring)
  const { data: scoringConfig } = await supabase
    .from('biometric_aggregations_scoring')
    .select('min_data_points')
    .eq('agg_metric_id', aggMetricId)
    .limit(1)
    .maybeSingle()

  const minDataPoints = scoringConfig?.min_data_points || 1

  if (latestAgg.data_points_count < minDataPoints) {
    console.log(`Insufficient data for ${aggMetricId}: ${latestAgg.data_points_count} < ${minDataPoints} required`)
    return null
  }

  // 3. Write to patient_biometric_readings (where mobile app and scorer read from!)
  const unit = UNIT_MAPPINGS[biometricName] || 'unit'

  // Insert new reading (allows historical tracking)
  const { error: insertError } = await supabase
    .from('patient_biometric_readings')
    .insert({
      user_id: userId,
      biometric_name: biometricName,
      value: latestAgg.value,
      unit: unit,
      recorded_at: latestAgg.period_end,
      source: 'auto_calculated',
      notes: `Auto-calculated from ${latestAgg.data_points_count} data points`,
    })

  if (insertError) {
    console.error(`Error inserting biometric ${biometricName}:`, insertError)
    return null
  }

  console.log(`✅ Updated ${biometricName} to ${latestAgg.value} ${unit}`)

  return {
    biometric_name: biometricName,
    value: latestAgg.value,
    unit: unit,
    data_points: latestAgg.data_points_count,
    recorded_at: latestAgg.period_end,
  }
}
