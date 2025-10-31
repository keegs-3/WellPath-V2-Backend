// Edge Function: Update Survey Responses from Tracked Data
// SIMPLE VERSION: Just translates aggregation_results_cache → patient_survey_responses
// The existing WellPath scorer will read from patient_survey_responses and calculate scores

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
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
      responsesUpdated: 0,
      responses: [] as any[]
    }

    // Get all survey response option mappings to aggregations
    const { data: mappings, error: mappingsError } = await supabase
      .from('survey_response_options_aggregations')
      .select('*')

    if (mappingsError) {
      throw new Error(`Error fetching mappings: ${mappingsError.message}`)
    }

    // Group mappings by question_number
    const questionMappings = new Map()
    for (const mapping of mappings) {
      if (!questionMappings.has(mapping.question_number)) {
        questionMappings.set(mapping.question_number, [])
      }
      questionMappings.get(mapping.question_number).push(mapping)
    }

    // Process each question that has tracking mappings
    for (const [questionNumber, questionMaps] of questionMappings.entries()) {
      const updated = await updateSurveyResponse(
        supabase,
        userId,
        questionNumber,
        questionMaps
      )

      if (updated) {
        results.responsesUpdated++
        results.responses.push(updated)
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

async function updateSurveyResponse(
  supabase: any,
  userId: string,
  questionNumber: number,
  mappings: any[]
): Promise<any | null> {
  // Get the aggregation metric for this question (should be same for all mappings)
  const aggMetricId = mappings[0].agg_metric_id
  const calculationType = mappings[0].calculation_type_id
  const periodType = mappings[0].period_type
  const minDataPoints = mappings[0].min_data_points || 20

  // 1. Get tracked value from aggregation cache
  const { data: latestAgg, error: aggError } = await supabase
    .from('aggregation_results_cache')
    .select('value, period_end, data_points_count')
    .eq('user_id', userId)
    .eq('agg_metric_id', aggMetricId)
    .eq('calculation_type_id', calculationType)
    .eq('period_type', periodType)
    .order('period_end', { ascending: false })
    .limit(1)
    .maybeSingle()

  if (aggError) {
    console.error(`Error fetching aggregation for Q${questionNumber}:`, aggError)
    return null
  }

  if (!latestAgg) {
    console.log(`No aggregation data for Q${questionNumber} (${aggMetricId})`)
    return null
  }

  // 2. Check if we have enough data points (prove consistent behavior)
  if (latestAgg.data_points_count < minDataPoints) {
    console.log(`Insufficient data for Q${questionNumber}: ${latestAgg.data_points_count} < ${minDataPoints} required`)
    return null
  }

  // 3. Find matching response option based on tracked value
  const matchingMapping = mappings.find(mapping => {
    const value = latestAgg.value
    const low = mapping.threshold_low
    const high = mapping.threshold_high

    // Handle different threshold patterns
    if (low !== null && high !== null) {
      return value >= low && value <= high
    } else if (low !== null && high === null) {
      return value >= low
    } else if (low === null && high !== null) {
      return value <= high
    }
    return false
  })

  if (!matchingMapping) {
    console.log(`No matching response option for Q${questionNumber} value ${latestAgg.value}`)
    return null
  }

  // 4. Get original survey response (if exists)
  const { data: originalResponse } = await supabase
    .from('patient_survey_responses')
    .select('response_option_id, created_at')
    .eq('user_id', userId)
    .eq('question_number', questionNumber)
    .maybeSingle()

  const originalOptionId = originalResponse?.response_option_id || null

  // Don't update if already using the correct response option
  if (originalOptionId === matchingMapping.response_option_id) {
    console.log(`Q${questionNumber} already at correct response option`)
    return null
  }

  // 5. Update or insert patient_survey_responses (where scorer reads from!)
  const { error: upsertError } = await supabase
    .from('patient_survey_responses')
    .upsert({
      user_id: userId,
      question_number: questionNumber,
      response_option_id: matchingMapping.response_option_id,
      response_source: 'auto_updated_from_tracking',
      original_response_option_id: originalOptionId,
      tracking_agg_metric_id: aggMetricId,
      tracking_value: latestAgg.value,
      tracking_data_points: latestAgg.data_points_count,
      updated_at: new Date().toISOString(),
    }, {
      onConflict: 'user_id,question_number',
      ignoreDuplicates: false
    })

  if (upsertError) {
    console.error(`Error upserting survey response for Q${questionNumber}:`, upsertError)
    return null
  }

  console.log(`✅ Updated Q${questionNumber} from ${originalOptionId} to ${matchingMapping.response_option_id} (value: ${latestAgg.value})`)

  return {
    question_number: questionNumber,
    original_option_id: originalOptionId,
    new_option_id: matchingMapping.response_option_id,
    tracked_value: latestAgg.value,
    data_points: latestAgg.data_points_count,
    agg_metric: aggMetricId,
  }
}
