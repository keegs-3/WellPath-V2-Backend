// Version: 3.0 - Writes to patient_wellpath_score_items table
// Uses normalized weight views and simplified scoring architecture
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import {
  scoreProteinIntake,
  scoreCalorieIntake,
  scoreMovementActivity,
  scoreSleepIssues,
  scoreSleepProtocols,
  scoreSleepApnea,
  scoreCognitiveActivities,
  scoreStress,
  scoreCoping,
  scoreSubstanceUse,
  scoreScreeningCompliance
} from './scoring-functions.ts'

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

    const { patient_id } = await req.json()
    if (!patient_id) {
      throw new Error('patient_id is required')
    }

    console.log(`\n========== SCORING PATIENT ${patient_id} ==========`)

    // 1. Get patient demographics
    const { data: patientDetails, error: patientError } = await supabaseClient
      .from('patient_details')
      .select('biological_sex, date_of_birth, weight_kg')
      .eq('user_id', patient_id)
      .single()

    if (patientError) throw patientError

    const dob = new Date(patientDetails.date_of_birth)
    const age = Math.abs(new Date(Date.now() - dob.getTime()).getUTCFullYear() - 1970)
    const patient = {
      age,
      gender: patientDetails.biological_sex,
      weight_lb: (patientDetails.weight_kg || 70) * 2.20462
    }

    console.log(`Patient: ${patient.gender}, age ${patient.age}`)

    // 2. Delete existing score items for this patient (fresh calculation)
    await supabaseClient
      .from('patient_wellpath_score_items')
      .delete()
      .eq('user_id', patient_id)

    console.log('Deleted old score items')

    // 3. Score biomarkers and biometrics
    const markerItems = await scoreBiomarkersAndBiometrics(supabaseClient, patient_id, patient)
    console.log(`Scored ${markerItems.length} biomarkers/biometrics`)

    // 4. Score survey questions
    console.log('🔍🔍🔍 ABOUT TO SCORE SURVEY QUESTIONS 🔍🔍🔍')
    const questionResult = await scoreSurveyQuestions(supabaseClient, patient_id, patient)
    const questionItems = questionResult.items
    const scoreMapKeys = questionResult.scoreMapKeys
    console.log(`🔍🔍🔍 SCORED ${questionItems.length} SURVEY QUESTIONS 🔍🔍🔍`)

    // Debug: Show which questions scored 0
    const zeroScorers = questionItems.filter(q => q.raw_score === 0)
    console.log(`Questions scoring 0: ${zeroScorers.map(q => q.question_number).join(', ')}`)

    // 5. Score survey functions
    const functionItems = await scoreSurveyFunctions(supabaseClient, patient_id, patient)
    console.log(`Scored ${functionItems.length} survey functions`)

    // 6. Insert all scored items into database
    const allItems = [...markerItems, ...questionItems, ...functionItems]

    if (allItems.length > 0) {
      const { error: insertError } = await supabaseClient
        .from('patient_wellpath_score_items')
        .insert(allItems)

      if (insertError) {
        console.error('Insert error:', insertError)
        throw insertError
      }

      console.log(`✅ Inserted ${allItems.length} scored items`)
    }

    // 7. Calculate summary scores by pillar
    const pillarSummary = await calculatePillarSummary(supabaseClient, patient_id, patient.gender)

    console.log('========== SCORING COMPLETE ==========\n')

    // Debug: Check multiple questions - both working and failing
    const debugQuestions = [10.13, 10.14, 9.01, 9.04]  // Use numeric values since question_number is numeric
    const debugItems = debugQuestions.map(qnum => {
      const item = allItems.find(i => i.question_number === qnum)
      return {
        question_number: qnum.toString(),  // Convert to string for display
        found: !!item,
        patient_value: item?.patient_value,
        raw_score: item?.raw_score,
        normalized_score: item?.normalized_score,
        patient_normalized_score_male: item?.patient_normalized_score_male
      }
    })

    return new Response(
      JSON.stringify({
        success: true,
        patient_id,
        items_scored: allItems.length,
        pillars: pillarSummary,
        _version: '3.0',
        _debug: {
          questions: debugItems,
          survey_question_count: questionItems.length,
          zero_scoring: questionItems.filter(q => q.raw_score === 0).length,
          scoreMapKeys: scoreMapKeys
        }
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
// BIOMARKERS & BIOMETRICS SCORING
// =====================================================
async function scoreBiomarkersAndBiometrics(supabase: any, patient_id: string, patient: any) {
  const items: any[] = []

  // Get normalized weights (gender-specific)
  const { data: weights, error: weightsError } = await supabase
    .from('wellpath_scoring_marker_pillar_weights_normalized')
    .select('*')
    .eq('is_active', true)
    .limit(5000)

  if (weightsError) {
    console.error('Error loading weights:', weightsError)
    return items
  }

  console.log(`Found ${weights?.length || 0} active marker weights`)
  if (!weights) return items

  // Get patient readings
  const { data: biomarkerReadings } = await supabase
    .from('patient_biomarker_readings')
    .select('biomarker_name, value, test_date')
    .eq('user_id', patient_id)
    .order('test_date', { ascending: false })
    .limit(100)

  const { data: biometricReadings } = await supabase
    .from('patient_biometric_readings')
    .select('biometric_name, value, recorded_at')
    .eq('user_id', patient_id)
    .order('recorded_at', { ascending: false })
    .limit(100)

  console.log(`Patient has ${biomarkerReadings?.length || 0} biomarker readings, ${biometricReadings?.length || 0} biometric readings`)

  // Get scoring ranges
  const { data: biomarkerRanges } = await supabase
    .from('biomarkers_detail')
    .select('biomarker, range_name, range_low, range_high, score_at_low, score_at_high, is_linear, age_low, age_high, gender')
    .limit(5000)

  const { data: biometricRanges } = await supabase
    .from('biometrics_detail')
    .select('biometric, range_name, range_low, range_high, score_at_low, score_at_high, is_linear, age_low, age_high, gender')
    .limit(5000)

  // Create lookup maps
  const biomarkerMap = new Map(biomarkerReadings?.map(r => [r.biomarker_name, r]) || [])
  const biometricMap = new Map(biometricReadings?.map(r => [r.biometric_name, r]) || [])

  // Process each weight
  let skippedAge = 0, skippedGender = 0, processedCount = 0
  for (const w of weights) {
    // Skip if doesn't apply to this patient's age/gender
    if (w.age_min && patient.age < w.age_min) { skippedAge++; continue }
    if (w.age_max && patient.age > w.age_max) { skippedAge++; continue }
    // If gender is 'male' or 'female', must match patient; otherwise defaults to 'all'
    if (w.gender === 'male' || w.gender === 'female') {
      if (w.gender !== patient.gender) { skippedGender++; continue }
    }

    processedCount++
    const isBiomarker = w.biomarker_name !== null
    const markerName = w.biomarker_name || w.biometric_name
    const reading = biomarkerMap.get(markerName) || biometricMap.get(markerName)

    // Get applicable ranges
    const allRanges = isBiomarker
      ? biomarkerRanges?.filter(r => r.biomarker === markerName) || []
      : biometricRanges?.filter(r => r.biometric === markerName) || []

    // Calculate score
    let rawScore = 0
    let scoreBand = null
    let normalizedScore = 0

    if (reading && reading.value !== null) {
      // Filter applicable ranges
      const applicableRanges = allRanges.filter(r => {
        if (r.gender && r.gender !== 'all' && r.gender !== patient.gender) return false
        if (r.age_low && patient.age < r.age_low) return false
        if (r.age_high && patient.age > r.age_high) return false
        return true
      })

      if (applicableRanges.length > 0) {
        const result = calculateMarkerScore(reading.value, applicableRanges)
        rawScore = result.rawScore
        scoreBand = result.band
        normalizedScore = result.normalized  // Already 0-1
      }
    }

    // Calculate patient's normalized score (weighted)
    const patientNormalizedScore = normalizedScore * (
      patient.gender === 'male' ? w.max_normalized_score_male : w.max_normalized_score_female
    )

    console.log(`Adding item: ${markerName} -> ${w.pillar_name}, score=${normalizedScore}, weighted=${patientNormalizedScore}`)

    items.push({
      user_id: patient_id,
      patient_gender: patient.gender,
      patient_age: patient.age,
      item_type: isBiomarker ? 'biomarker' : 'biometric',
      biomarker_name: w.biomarker_name,
      biometric_name: w.biometric_name,
      pillar_name: w.pillar_name,
      patient_value: reading?.value?.toString() || null,
      patient_value_numeric: reading?.value || null,
      score_band: scoreBand,
      raw_score: rawScore,
      normalized_score: normalizedScore,
      raw_weight: w.weight,
      patient_normalized_score_male: patient.gender === 'male' ? patientNormalizedScore : null,
      patient_normalized_score_female: patient.gender === 'female' ? patientNormalizedScore : null,
      max_normalized_score_male: w.max_normalized_score_male,
      max_normalized_score_female: w.max_normalized_score_female,
      max_grouping: w.max_grouping,
      data_collected_at: reading?.test_date || reading?.recorded_at || null
    })
  }

  console.log(`Processed ${processedCount} weights (skipped ${skippedAge} age, ${skippedGender} gender), added ${items.length} items`)
  return items
}

// =====================================================
// SURVEY QUESTIONS SCORING
// =====================================================
async function scoreSurveyQuestions(supabase: any, patient_id: string, patient: any) {
  console.error('🔍 scoreSurveyQuestions: STARTING')
  const items: any[] = []

  // Get patient responses
  console.error('🔍 scoreSurveyQuestions: Fetching patient responses')
  const { data: responses, error: responsesError } = await supabase
    .from('patient_survey_responses')
    .select('question_number, response_text, created_at')
    .eq('user_id', patient_id)

  if (responsesError) {
    console.error('❌ scoreSurveyQuestions: Error fetching responses:', responsesError)
    return items
  }

  console.error(`🔍 scoreSurveyQuestions: Found ${responses?.length || 0} patient responses`)
  if (!responses || responses.length === 0) {
    console.error('⚠️ scoreSurveyQuestions: No responses, returning empty')
    return items
  }

  // Force numeric conversion then to string for consistent formatting
  const responseMap = new Map(responses.map(r => [
    String(Number(r.question_number)), r
  ]))

  console.log(`Loaded ${responses.length} patient responses`)

  // Get normalized weights
  console.log('scoreSurveyQuestions: Fetching question weights...')
  const { data: weights, error: weightsError } = await supabase
    .from('wellpath_scoring_question_pillar_weights_normalized')
    .select('*')
    .eq('is_active', true)
    .not('question_number', 'is', null)
    .limit(5000)

  if (weightsError) {
    console.error('scoreSurveyQuestions: Error fetching weights:', weightsError)
    return items
  }

  console.log(`Found ${weights?.length || 0} question weights`)
  if (!weights || weights.length === 0) {
    console.log('scoreSurveyQuestions: No weights, returning empty')
    return items
  }

  // Get response scores - use range() to bypass PostgREST's default 1000-row limit
  // Fetch all non-NULL scores with pagination
  const { data: responseScores, error: scoresError } = await supabase
    .from('survey_response_options')
    .select('question_number, option_text, score')
    .not('score', 'is', null)  // Only get rows with scores (exclude custom_calc questions)
    .range(0, 9999)  // Use range() instead of limit() to bypass max-rows setting

  if (scoresError) {
    console.error('Error loading response scores:', scoresError)
    return items
  }

  console.log(`Raw responseScores count: ${responseScores?.length || 0}`)

  const scoreMap = new Map()
  const scoreMapDiagnostics: any[] = []  // Track scoreMap lookups for debugging
  let skippedNull = 0

  responseScores?.forEach(rs => {
    // Skip if score is NULL (means custom_calc)
    if (rs.score === null || rs.score === undefined) {
      skippedNull++
      return
    }

    // Force numeric conversion then to string for consistent formatting
    const questionNum = String(Number(rs.question_number))
    const optionText = String(rs.option_text || '').trim().toLowerCase()
    const key = `${questionNum}::${optionText}`
    scoreMap.set(key, rs.score)  // rs.score is now numeric
  })

  console.log(`Loaded ${scoreMap.size} response options into scoreMap (skipped ${skippedNull} NULL scores out of ${responseScores?.length || 0} total)`)

  // Debug: Collect scoreMap keys for diagnostics
  const allKeys = Array.from(scoreMap.keys())
  const allKeysStrings = allKeys.map(k => String(k))
  const q9Keys = allKeysStrings.filter(k => k.includes('9.'))
  const q10Keys = allKeysStrings.filter(k => k.includes('10.'))
  const scoreMapKeys = {
    all_q9_keys: q9Keys,
    all_q10_keys: q10Keys.slice(0, 20),
    total_keys: allKeys.length,
    raw_rows_fetched: responseScores?.length || 0,
    null_scores_skipped: skippedNull
  }

  // Process each weight
  for (const w of weights) {
    // Skip if doesn't apply to this patient
    // If gender is 'male' or 'female', must match patient; otherwise defaults to 'all'
    if (w.gender === 'male' || w.gender === 'female') {
      if (w.gender !== patient.gender) continue
    }
    if (w.age_min && patient.age < w.age_min) continue
    if (w.age_max && patient.age > w.age_max) continue

    // Force numeric conversion then to string for consistent formatting
    const response = responseMap.get(String(Number(w.question_number)))

    let rawScore = 0
    let normalizedScore = 0
    let lookupKey = null
    let scoreStr = null

    if (response && response.response_text) {
      // Force numeric conversion then to string for consistent formatting
      const questionNum = String(Number(w.question_number))
      const responseText = String(response.response_text || '').trim().toLowerCase()
      lookupKey = `${questionNum}::${responseText}`
      scoreStr = scoreMap.get(lookupKey)

      // Debug logging for specific questions
      const qnumStr = w.question_number.toString()
      if (['10.13', '10.14', '9.01', '9.04'].includes(qnumStr)) {
        console.log(`Looking up: "${lookupKey}" => ${scoreStr}`)
        scoreMapDiagnostics.push({
          question_number: qnumStr,
          response_text_original: response.response_text,
          response_text_normalized: responseText,
          lookup_key: lookupKey,
          scoreStr_value: scoreStr,
          scoreStr_type: typeof scoreStr,
          found: scoreStr !== undefined && scoreStr !== null
        })
      }

      // Handle score lookup - scoreStr can be 0 which is falsy but valid
      // Now that score is numeric, NULL means custom_calc
      if (scoreStr !== undefined && scoreStr !== null) {
        rawScore = scoreStr  // Already a number from database
        // Survey scores are already 0-1 scale, no need to divide by 10
        normalizedScore = rawScore
      }
    }

    // Calculate patient's normalized score (weighted)
    const patientNormalizedScore = normalizedScore * (
      patient.gender === 'male' ? w.max_normalized_score_male : w.max_normalized_score_female
    )

    items.push({
      user_id: patient_id,
      patient_gender: patient.gender,
      patient_age: patient.age,
      item_type: 'survey_question',
      question_number: w.question_number,
      pillar_name: w.pillar_name,
      patient_value: response?.response_text || null,
      raw_score: rawScore,
      normalized_score: normalizedScore,
      raw_weight: w.weight,
      patient_normalized_score_male: patient.gender === 'male' ? patientNormalizedScore : null,
      patient_normalized_score_female: patient.gender === 'female' ? patientNormalizedScore : null,
      max_normalized_score_male: w.max_normalized_score_male,
      max_normalized_score_female: w.max_normalized_score_female,
      max_grouping: w.max_grouping,
      data_collected_at: response?.created_at || null
    })
  }

  // Return items and scoreMapKeys for debugging
  return { items, scoreMapKeys }
}

// =====================================================
// SURVEY FUNCTIONS SCORING
// =====================================================
async function scoreSurveyFunctions(supabase: any, patient_id: string, patient: any) {
  const items: any[] = []

  // Get patient responses
  const { data: responseRows } = await supabase
    .from('patient_survey_responses')
    .select('question_number, response_text')
    .eq('user_id', patient_id)

  if (!responseRows || responseRows.length === 0) return items

  const responses: Record<string, string> = {}
  responseRows.forEach(r => { responses[r.question_number] = r.response_text })

  // Get normalized weights
  const { data: weights } = await supabase
    .from('wellpath_scoring_question_pillar_weights_normalized')
    .select('*')
    .eq('is_active', true)
    .not('function_name', 'is', null)
    .limit(5000)

  if (!weights) return items

  // Get function metadata for demographic filtering
  const { data: functionMetadata } = await supabase
    .from('wellpath_scoring_survey_functions')
    .select('function_name, gender_filter, age_min, age_max')
    .limit(5000)

  const metadataMap = new Map(
    functionMetadata?.map(f => [f.function_name, f]) || []
  )

  // Process each function
  for (const w of weights) {
    const metadata = metadataMap.get(w.function_name)

    // Check demographic filters
    if (metadata) {
      // If gender_filter is 'male' or 'female', must match patient; otherwise defaults to 'all'
      if (metadata.gender_filter === 'male' || metadata.gender_filter === 'female') {
        if (metadata.gender_filter !== patient.gender) continue
      }
      if (metadata.age_min && patient.age < metadata.age_min) continue
      if (metadata.age_max && patient.age > metadata.age_max) continue
    }

    // Get question mappings for this function
    const { data: questionMappings } = await supabase
      .from('wellpath_scoring_survey_function_questions')
      .select('question_number, parameter_name')
      .eq('function_name', w.function_name)
      .order('question_number')

    // Build params and track which questions are used
    const params: Record<string, string> = {}
    const questionNumbers: Record<string, string> = {}  // Map parameter names to question numbers
    const functionQuestionResponses: any[] = []

    if (questionMappings) {
      for (const mapping of questionMappings) {
        const response = responses[mapping.question_number] || ''
        params[mapping.parameter_name] = response
        questionNumbers[mapping.parameter_name] = mapping.question_number  // Store the reverse mapping
        functionQuestionResponses.push({
          question_number: mapping.question_number,
          parameter_name: mapping.parameter_name,
          response: response
        })
      }
    }

    // Calculate function score
    const normalizedScore = await executeSurveyFunction(w.function_name, params, questionNumbers, responses, patient)

    // Calculate patient's normalized score (weighted)
    const patientNormalizedScore = normalizedScore * (
      patient.gender === 'male' ? w.max_normalized_score_male : w.max_normalized_score_female
    )

    items.push({
      user_id: patient_id,
      patient_gender: patient.gender,
      patient_age: patient.age,
      item_type: 'survey_function',
      function_name: w.function_name,
      pillar_name: w.pillar_name,
      normalized_score: normalizedScore,
      raw_weight: w.weight,
      patient_normalized_score_male: patient.gender === 'male' ? patientNormalizedScore : null,
      patient_normalized_score_female: patient.gender === 'female' ? patientNormalizedScore : null,
      max_normalized_score_male: w.max_normalized_score_male,
      max_normalized_score_female: w.max_normalized_score_female,
      max_grouping: w.max_grouping,
      function_question_responses: functionQuestionResponses
    })
  }

  return items
}

// =====================================================
// HELPER: Calculate Marker Score
// =====================================================
function calculateMarkerScore(value: number, ranges: any[]): { rawScore: number, normalized: number, band: string } {
  const matchingRanges = ranges.filter(range => {
    const low = range.range_low ?? -Infinity
    const high = range.range_high ?? Infinity
    return value >= low && value <= high
  })

  if (matchingRanges.length === 0) {
    return { rawScore: 0, normalized: 0, band: 'Unknown' }
  }

  // Pick best matching range
  const bestRange = matchingRanges.sort((a, b) => {
    const aScore = Math.max(a.score_at_low ?? 0, a.score_at_high ?? 0)
    const bScore = Math.max(b.score_at_low ?? 0, b.score_at_high ?? 0)
    if (aScore !== bScore) return bScore - aScore
    const aWidth = (a.range_high ?? Infinity) - (a.range_low ?? -Infinity)
    const bWidth = (b.range_high ?? Infinity) - (b.range_low ?? -Infinity)
    return aWidth - bWidth
  })[0]

  const low = bestRange.range_low ?? -Infinity
  const high = bestRange.range_high ?? Infinity
  const scoreAtLow = bestRange.score_at_low ?? 0
  const scoreAtHigh = bestRange.score_at_high ?? 0
  const isLinear = bestRange.is_linear ?? false

  let rawScore = scoreAtLow

  if (isLinear) {
    const rangeSize = high - low
    const valuePosition = value - low
    const fraction = rangeSize > 0 ? valuePosition / rangeSize : 0
    rawScore = scoreAtLow + (scoreAtHigh - scoreAtLow) * fraction
  }

  // Normalize to 0-1 (raw scores are 0-10 scale)
  const normalized = rawScore / 10

  return {
    rawScore,
    normalized,
    band: bestRange.range_name || 'Unknown'
  }
}

// =====================================================
// HELPER: Execute Survey Function
// =====================================================
async function executeSurveyFunction(function_name: string, params: Record<string, string>, questionNumbers: Record<string, string>, responses: Record<string, string>, patient: any): Promise<number> {
  switch (function_name) {
    case 'protein_intake_score':
      return scoreProteinIntake(params['protein_grams'], patient.weight_lb, patient.age)
    case 'calorie_intake_score':
      return scoreCalorieIntake(params['calories'], patient.weight_lb, patient.age, patient.gender)
    case 'movement_cardio_score':
    case 'movement_strength_score':
    case 'movement_flexibility_score':
    case 'movement_hiit_score':
      return scoreMovementActivity(responses, questionNumbers['frequency'], questionNumbers['duration'])
    case 'sleep_issues_score':
      return scoreSleepIssues(responses)
    case 'sleep_protocols_score':
      return scoreSleepProtocols(params['protocols_list'])
    case 'sleep_apnea_management_score':
      return scoreSleepApnea(responses)
    case 'cognitive_activities_score':
      return scoreCognitiveActivities(params['activities_list'])
    case 'stress_level_score':
      return scoreStress(params['stress_level'], params['stress_frequency'])
    case 'coping_skills_score':
      return scoreCoping(params['coping_strategies_list'], params['stress_level'], params['stress_frequency'])
    case 'substance_tobacco_score':
    case 'substance_nicotine_score':
    case 'substance_alcohol_score':
    case 'substance_recreational_drugs_score':
    case 'substance_otc_meds_score':
    case 'substance_other_score':
      return scoreSubstanceUse(function_name, responses)
    case 'screening_dental_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 6 })
    case 'screening_skin_check_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 12 })
    case 'screening_vision_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 12 })
    case 'screening_colonoscopy_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 120 })
    case 'screening_mammogram_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 12 })
    case 'screening_pap_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 36 })
    case 'screening_dexa_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 36 })
    case 'screening_psa_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 36 })
    case 'screening_hpv_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 60 })
    case 'screening_breast_mri_score':
      return scoreScreeningCompliance(function_name, params['exam_date'], { window: 12 })
    default:
      console.warn(`Function ${function_name} not implemented`)
      return 0
  }
}

// =====================================================
// HELPER: Calculate Pillar Summary
// =====================================================
async function calculatePillarSummary(supabase: any, patient_id: string, gender: string) {
  // Get all scored items
  const { data: items } = await supabase
    .from('patient_wellpath_score_items')
    .select('pillar_name, item_type, patient_normalized_score_male, patient_normalized_score_female, max_normalized_score_male, max_normalized_score_female, max_grouping')
    .eq('user_id', patient_id)

  if (!items) return []

  // Group items by pillar
  // NOTE: The scores in patient_normalized_score are ALREADY weighted by component weights
  // (e.g., markers are multiplied by 0.72, survey by 0.18, education by 0.10)
  // So we just need to sum them up to get the final pillar score
  const pillars = new Map()

  for (const item of items) {
    const pillar = item.pillar_name
    if (!pillars.has(pillar)) {
      pillars.set(pillar, {
        score: 0,
        max: 0,
        item_count: 0
      })
    }

    const data = pillars.get(pillar)
    const patientScore = gender === 'male' ? item.patient_normalized_score_male : item.patient_normalized_score_female
    const maxScore = gender === 'male' ? item.max_normalized_score_male : item.max_normalized_score_female

    data.score += patientScore || 0
    data.max += maxScore || 0
    data.item_count++
  }

  // Calculate percentages
  const summary = []
  for (const [pillarName, data] of pillars.entries()) {
    // Percentage of max possible score
    const percentage = data.max > 0 ? (data.score / data.max) * 100 : 0

    summary.push({
      pillar_name: pillarName,
      score: data.score,
      max: data.max,
      percentage: percentage.toFixed(2),
      item_count: data.item_count
    })
  }

  return summary
}
