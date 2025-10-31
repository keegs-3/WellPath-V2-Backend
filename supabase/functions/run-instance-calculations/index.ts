// =====================================================
// Run Instance Calculations
// =====================================================
// Triggers after patient_data_entries insert
// Executes instance calculations to auto-populate related fields
// (e.g., vegetables → fiber, duration calculations)
//
// Created: 2025-10-21
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

    const { patient_id, event_instance_id } = await req.json()

    if (!patient_id || !event_instance_id) {
      throw new Error('patient_id and event_instance_id are required')
    }

    console.log(`\n========== RUNNING INSTANCE CALCULATIONS ==========`)
    console.log(`User: ${patient_id}`)
    console.log(`Event Instance: ${event_instance_id}`)

    // 1. Get all data entries for this event instance to determine event_type_id
    const { data: eventEntries, error: entriesError } = await supabaseClient
      .from('patient_data_entries')
      .select('field_id')
      .eq('patient_id', patient_id)
      .eq('event_instance_id', event_instance_id)
      .limit(1)

    if (entriesError) throw entriesError

    if (!eventEntries || eventEntries.length === 0) {
      console.log('No entries found for this event instance')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No entries found',
          calculations_run: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    // Get event_type_id from event_types_dependencies
    const { data: fieldDep, error: fieldError } = await supabaseClient
      .from('event_types_dependencies')
      .select('event_type_id')
      .eq('data_entry_field_id', eventEntries[0].field_id)
      .eq('dependency_type', 'field')
      .limit(1)
      .single()

    if (fieldError || !fieldDep || !fieldDep.event_type_id) {
      console.log('Could not determine event type from fields')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No event type associated with these fields',
          calculations_run: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    const event_type_id = fieldDep.event_type_id
    console.log(`Event Type: ${event_type_id}`)

    // 2. Get calculation dependencies for this event type (in display_order)
    const { data: calcDeps, error: depsError } = await supabaseClient
      .from('event_types_dependencies')
      .select(`
        instance_calculation_id,
        display_order,
        instance_calculations (
          calc_id,
          calc_name,
          calculation_method,
          calculation_config
        )
      `)
      .eq('event_type_id', event_type_id)
      .eq('dependency_type', 'calculation')
      .order('display_order', { ascending: true })

    if (depsError) throw depsError

    if (!calcDeps || calcDeps.length === 0) {
      console.log('No calculations to run for this event type')
      return new Response(
        JSON.stringify({
          success: true,
          message: 'No calculations needed',
          calculations_run: 0
        }),
        { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
      )
    }

    console.log(`Found ${calcDeps.length} calculations to run`)

    // 3. Get all data entries for this event instance
    const { data: dataEntries, error: dataEntriesError } = await supabaseClient
      .from('patient_data_entries')
      .select('*')
      .eq('patient_id', patient_id)
      .eq('event_instance_id', event_instance_id)

    if (dataEntriesError) throw dataEntriesError

    console.log(`Found ${dataEntries?.length || 0} data entries for this event`)

    // Create lookup map for quick access
    const entriesMap = new Map()
    dataEntries?.forEach(entry => {
      entriesMap.set(entry.field_id, entry)
    })

    // 3. Run each calculation in order
    const createdEntries = []

    for (const calcDep of calcDeps) {
      const calc = calcDep.instance_calculations

      console.log(`\nRunning: ${calc.calc_name} (${calc.calculation_method})`)

      try {
        const result = await executeCalculation(
          supabaseClient,
          calc,
          patient_id,
          event_instance_id,
          entriesMap
        )

        if (result && result.length > 0) {
          // Check if these calculations already exist (prevent duplicates from multiple trigger fires)
          const outputFieldIds = result.map(r => r.field_id)
          const { data: existing } = await supabaseClient
            .from('patient_data_entries')
            .select('field_id')
            .eq('patient_id', patient_id)
            .eq('event_instance_id', event_instance_id)
            .eq('source', 'auto_calculated')
            .in('field_id', outputFieldIds)

          const existingFieldIds = new Set(existing?.map(e => e.field_id) || [])
          const newResults = result.filter(r => !existingFieldIds.has(r.field_id))

          if (newResults.length > 0) {
            // Insert only new auto-calculated entries
            const { error: insertError } = await supabaseClient
              .from('patient_data_entries')
              .insert(newResults)

            if (insertError) {
              console.error(`Error inserting results for ${calc.calc_name}:`, insertError)
            } else {
              console.log(`✅ Created ${newResults.length} auto-calculated entries (skipped ${result.length - newResults.length} duplicates)`)
              createdEntries.push(...newResults)

              // Add to map for subsequent calculations
              newResults.forEach(entry => {
                entriesMap.set(entry.field_id, entry)
              })
            }
          } else {
            console.log(`⏭️  Skipped ${result.length} duplicate entries for ${calc.calc_name}`)
          }
        } else {
          console.log(`No entries created by ${calc.calc_name}`)
        }

      } catch (calcError) {
        console.error(`Error running ${calc.calc_name}:`, calcError)
        // Continue with other calculations
      }
    }

    console.log(`\n========== CALCULATIONS COMPLETE ==========`)
    console.log(`Total entries created: ${createdEntries.length}`)

    // =====================================================
    // STEP 4: Process Aggregations
    // =====================================================
    console.log(`\n========== PROCESSING AGGREGATIONS ==========`)

    let aggregationsProcessed = 0

    // Get the entry date from one of the data entries
    const { data: dateEntry } = await supabaseClient
      .from('patient_data_entries')
      .select('entry_date, field_id')
      .eq('patient_id', patient_id)
      .eq('event_instance_id', event_instance_id)
      .limit(1)
      .single()

    if (dateEntry) {
      // Get all fields that were created/updated in this event
      const { data: allFields } = await supabaseClient
        .from('patient_data_entries')
        .select('field_id')
        .eq('patient_id', patient_id)
        .eq('event_instance_id', event_instance_id)

      const uniqueFields = [...new Set(allFields?.map(f => f.field_id) || [])]

      console.log(`Processing aggregations for ${uniqueFields.length} fields`)

      // Process aggregations for each affected field
      for (const field_id of uniqueFields) {
        try {
          // Call PostgreSQL function to process aggregations for this field
          const { data: result, error: aggError } = await supabaseClient
            .rpc('process_field_aggregations', {
              p_patient_id: patient_id,
              p_field_id: field_id,
              p_entry_date: dateEntry.entry_date
            })

          if (aggError) {
            console.error(`Error processing aggregations for ${field_id}:`, aggError)
          } else {
            aggregationsProcessed += result || 0
            console.log(`  ✅ ${field_id}: ${result || 0} aggregations updated`)
          }
        } catch (aggError) {
          console.error(`Exception processing aggregations for ${field_id}:`, aggError)
        }
      }
    }

    console.log(`\n========== AGGREGATIONS COMPLETE ==========`)
    console.log(`Total aggregations updated: ${aggregationsProcessed}`)

    return new Response(
      JSON.stringify({
        success: true,
        patient_id,
        event_type_id,
        calculations_run: calcDeps.length,
        entries_created: createdEntries.length,
        created_fields: createdEntries.map(e => e.field_id),
        aggregations_processed: aggregationsProcessed
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
// Execute Individual Calculation
// =====================================================
async function executeCalculation(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>
): Promise<any[]> {

  const config = calc.calculation_config || {}
  const results: any[] = []

  switch (calc.calculation_method) {
    case 'lookup_multiply':
      return executeLookupMultiply(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'lookup_divide':
      return executeLookupDivide(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'category_to_macro':
      return executeCategoryToMacro(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'food_lookup':
      return executeFoodLookup(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'calculate_duration':
      return executeCalculateDuration(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'calculate_heart_rate_zones':
      return executeCalculateHeartRateZones(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'calculate_formula':
      return executeCalculateFormula(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    case 'constant':
      return executeConstant(supabase, calc, patient_id, event_instance_id, entriesMap, config)

    default:
      console.warn(`Unknown calculation method: ${calc.calculation_method}`)
      return []
  }
}

// =====================================================
// Calculation: Lookup Multiply (lookup value × quantity)
// =====================================================
async function executeLookupMultiply(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  // Get dependencies for this calculation
  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)
    .order('parameter_order')

  if (!deps || deps.length < 2) {
    console.log('Missing dependencies')
    return []
  }

  // Get lookup key (source type) and quantity (servings)
  const lookupKeyField = deps.find(d => d.parameter_role === 'lookup_key')?.data_entry_field_id
  const multiplierField = deps.find(d => d.parameter_role === 'multiplier')?.data_entry_field_id

  if (!lookupKeyField || !multiplierField) {
    console.log('Missing required fields')
    return []
  }

  const lookupEntry = entriesMap.get(lookupKeyField)
  const quantityEntry = entriesMap.get(multiplierField)

  if (!lookupEntry || !quantityEntry) {
    console.log('Data not available for calculation')
    return []
  }

  const sourceType = lookupEntry.value_reference || lookupEntry.value_text
  const servings = quantityEntry.value_quantity

  if (!sourceType || !servings) return []

  // Lookup in reference table
  const { data: refData } = await supabase
    .from(config.lookup_table)
    .select(config.lookup_value_field)
    .eq(config.lookup_key_field, sourceType)
    .single()

  if (!refData) {
    console.log(`No reference data found for ${sourceType}`)
    return []
  }

  const perServingValue = refData[config.lookup_value_field]
  const calculatedGrams = servings * perServingValue

  console.log(`${servings} servings × ${perServingValue}g/serving = ${calculatedGrams}g`)

  // Get timestamp from source entry
  const entry_date = quantityEntry.entry_date
  const entry_timestamp = quantityEntry.entry_timestamp

  // Create auto-calculated entry
  return [{
    patient_id,
    event_instance_id,
    field_id: config.output_field,
    entry_date,
    entry_timestamp,
    value_quantity: calculatedGrams,
    source: config.output_source || 'auto_calculated',
    metadata: {
      calculated_by: calc.calc_id,
      source_type: sourceType,
      servings: servings,
      per_serving: perServingValue
    }
  }]
}

// =====================================================
// Calculation: Lookup Divide (quantity ÷ lookup value)
// =====================================================
async function executeLookupDivide(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)
    .order('parameter_order')

  if (!deps || deps.length < 2) return []

  const lookupKeyField = deps.find(d => d.parameter_role === 'lookup_key')?.data_entry_field_id
  const dividendField = deps.find(d => d.parameter_role === 'dividend')?.data_entry_field_id

  if (!lookupKeyField || !dividendField) return []

  const lookupEntry = entriesMap.get(lookupKeyField)
  const gramsEntry = entriesMap.get(dividendField)

  if (!lookupEntry || !gramsEntry) return []

  const sourceType = lookupEntry.value_reference || lookupEntry.value_text
  const grams = gramsEntry.value_quantity

  if (!sourceType || !grams) return []

  // Lookup in reference table
  const { data: refData } = await supabase
    .from(config.lookup_table)
    .select(config.lookup_value_field)
    .eq(config.lookup_key_field, sourceType)
    .single()

  if (!refData) return []

  const perServingValue = refData[config.lookup_value_field]
  const calculatedServings = grams / perServingValue

  console.log(`${grams}g ÷ ${perServingValue}g/serving = ${calculatedServings} servings`)

  // Get timestamp from source entry
  const entry_date = gramsEntry.entry_date
  const entry_timestamp = gramsEntry.entry_timestamp

  return [{
    patient_id,
    event_instance_id,
    field_id: config.output_field,
    entry_date,
    entry_timestamp,
    value_quantity: calculatedServings,
    source: config.output_source || 'auto_calculated',
    metadata: {
      calculated_by: calc.calc_id,
      source_type: sourceType,
      grams: grams,
      per_serving: perServingValue
    }
  }]
}

// =====================================================
// Calculation: Category to Macro (e.g., Vegetables → Fiber)
// =====================================================
async function executeCategoryToMacro(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)

  if (!deps || deps.length === 0) return []

  const quantityField = deps.find(d => d.parameter_role === 'multiplier')?.data_entry_field_id
  if (!quantityField) return []

  const quantityEntry = entriesMap.get(quantityField)
  if (!quantityEntry || !quantityEntry.value_quantity) return []

  const servings = quantityEntry.value_quantity
  const gramsPerServing = config.grams_per_serving
  const calculatedGrams = servings * gramsPerServing

  console.log(`${servings} servings × ${gramsPerServing}g/serving = ${calculatedGrams}g`)

  // Get timestamp from source entry
  const entry_date = quantityEntry.entry_date
  const entry_timestamp = quantityEntry.entry_timestamp

  const results = []
  const outputs = config.output_fields

  // Create fiber entries
  if (outputs.source) {
    results.push({
      patient_id,
      event_instance_id,
      field_id: outputs.source,
      entry_date,
      entry_timestamp,
      value_reference: config.fiber_source_value,
      source: config.output_source || 'auto_calculated',
      metadata: { calculated_by: calc.calc_id }
    })
  }

  if (outputs.servings) {
    results.push({
      patient_id,
      event_instance_id,
      field_id: outputs.servings,
      entry_date,
      entry_timestamp,
      value_quantity: servings,
      source: config.output_source || 'auto_calculated',
      metadata: { calculated_by: calc.calc_id }
    })
  }

  if (outputs.grams) {
    results.push({
      patient_id,
      event_instance_id,
      field_id: outputs.grams,
      entry_date,
      entry_timestamp,
      value_quantity: calculatedGrams,
      source: config.output_source || 'auto_calculated',
      metadata: { calculated_by: calc.calc_id }
    })
  }

  return results
}

// =====================================================
// Calculation: Food Lookup (Specific Food → Nutrition)
// =====================================================
async function executeFoodLookup(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  console.log(`[executeFoodLookup] Starting for calc: ${calc.calc_id}`)

  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)
    .order('parameter_order')

  console.log(`[executeFoodLookup] Found ${deps?.length || 0} dependencies`)

  if (!deps || deps.length < 2) {
    console.log('[executeFoodLookup] Not enough dependencies, returning empty')
    return []
  }

  const lookupKeyField = deps.find(d => d.parameter_role === 'lookup_key')?.data_entry_field_id
  const multiplierField = deps.find(d => d.parameter_role === 'multiplier')?.data_entry_field_id

  console.log(`[executeFoodLookup] lookupKeyField=${lookupKeyField}, multiplierField=${multiplierField}`)

  if (!lookupKeyField || !multiplierField) {
    console.log('[executeFoodLookup] Missing required fields, returning empty')
    return []
  }

  const foodEntry = entriesMap.get(lookupKeyField)
  const quantityEntry = entriesMap.get(multiplierField)

  console.log(`[executeFoodLookup] foodEntry=${JSON.stringify(foodEntry)}, quantityEntry=${JSON.stringify(quantityEntry)}`)

  if (!foodEntry || !quantityEntry) {
    console.log('[executeFoodLookup] Missing entries from map, returning empty')
    return []
  }

  const foodType = foodEntry.value_reference || foodEntry.value_text
  const servings = quantityEntry.value_quantity

  console.log(`[executeFoodLookup] foodType=${foodType}, servings=${servings}`)

  if (!foodType || !servings) {
    console.log('[executeFoodLookup] Missing foodType or servings, returning empty')
    return []
  }

  // Lookup food in reference table
  const { data: foodData } = await supabase
    .from(config.lookup_table)
    .select('*')
    .eq(config.lookup_key_field, foodType)
    .eq('category_name', config.category_filter)
    .single()

  if (!foodData) {
    console.log(`Food not found: ${foodType}`)
    return []
  }

  console.log(`Found ${foodType}: fiber=${foodData.fiber_grams_per_serving}g, protein=${foodData.protein_grams_per_serving}g, fat=${foodData.fat_grams_per_serving}g per serving`)

  // Get timestamp from source entry
  const entry_date = quantityEntry.entry_date
  const entry_timestamp = quantityEntry.entry_timestamp

  const results = []
  const mappings = config.output_mappings

  // Create entries for each nutrition component
  for (const [sourceField, targetField] of Object.entries(mappings)) {
    const perServingValue = foodData[sourceField]

    if (perServingValue !== null && perServingValue !== undefined) {
      const calculatedValue = servings * perServingValue

      results.push({
        patient_id,
        event_instance_id,
        field_id: targetField,
        entry_date,
        entry_timestamp,
        value_quantity: calculatedValue,
        source: config.output_source || 'auto_calculated',
        metadata: {
          calculated_by: calc.calc_id,
          food_type: foodType,
          servings: servings,
          per_serving: perServingValue
        }
      })

      console.log(`${targetField}: ${servings} × ${perServingValue} = ${calculatedValue}`)
    }
  }

  return results
}

// =====================================================
// Calculation: Duration (Start + End → Duration)
// =====================================================
async function executeCalculateDuration(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)
    .order('parameter_order')

  if (!deps || deps.length < 2) return []

  const startField = deps.find(d => d.parameter_role === 'start_time')?.data_entry_field_id
  const endField = deps.find(d => d.parameter_role === 'end_time')?.data_entry_field_id

  if (!startField || !endField) return []

  const startEntry = entriesMap.get(startField)
  const endEntry = entriesMap.get(endField)

  if (!startEntry || !endEntry) return []

  const startTime = startEntry.value_timestamp
  const endTime = endEntry.value_timestamp

  if (!startTime || !endTime) return []

  // Calculate duration in minutes
  const startDate = new Date(startTime)
  const endDate = new Date(endTime)
  const durationMs = endDate.getTime() - startDate.getTime()
  const durationMinutes = Math.round(durationMs / 60000)

  console.log(`Duration: ${startTime} to ${endTime} = ${durationMinutes} minutes`)

  // Get timestamp from source entry
  const entry_date = startEntry.entry_date
  const entry_timestamp = startEntry.entry_timestamp

  // Always write the generic output field
  const results = [{
    patient_id,
    event_instance_id,
    field_id: config.output_field,
    entry_date,
    entry_timestamp,
    value_quantity: durationMinutes,
    source: config.output_source || 'auto_calculated',
    metadata: {
      calculated_by: calc.calc_id,
      start_time: startTime,
      end_time: endTime,
      duration_minutes: durationMinutes
    }
  }]

  // Check if type-specific output mapping exists (for sleep periods)
  if (config.type_field && config.type_output_mapping) {
    const typeEntry = entriesMap.get(config.type_field)

    if (typeEntry && typeEntry.value_reference) {
      console.log(`Looking up type from reference: ${typeEntry.value_reference}`)

      // Query reference table to get period name
      const { data: periodType, error } = await supabase
        .from('def_ref_sleep_period_types')
        .select('period_name')
        .eq('id', typeEntry.value_reference)
        .single()

      if (error) {
        console.error(`Error fetching period type: ${error.message}`)
      } else if (periodType) {
        const periodName = periodType.period_name.toLowerCase()
        const typeOutputField = config.type_output_mapping[periodName]

        if (typeOutputField) {
          console.log(`Adding type-specific output: ${periodName} → ${typeOutputField}`)

          results.push({
            patient_id,
            event_instance_id,
            field_id: typeOutputField,
            entry_date,
            entry_timestamp,
            value_quantity: durationMinutes,
            source: config.output_source || 'auto_calculated',
            metadata: {
              calculated_by: calc.calc_id,
              sleep_period_type: periodName,
              start_time: startTime,
              end_time: endTime,
              duration_minutes: durationMinutes
            }
          })
        } else {
          console.warn(`No output mapping found for period type: ${periodName}`)
        }
      }
    }
  }

  return results
}

// =====================================================
// Calculation: Heart Rate Zones
// =====================================================
async function executeCalculateHeartRateZones(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  // TODO: Implement heart rate zone calculation
  // This requires heart rate data points, which may need special handling
  console.log('Heart rate zone calculation not yet implemented')
  return []
}

// =====================================================
// Calculation: Formula (BMI, BMR, etc.)
// =====================================================
async function executeCalculateFormula(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  const { data: deps } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_name')
    .eq('instance_calculation_id', calc.calc_id)
    .order('parameter_order')

  if (!deps || deps.length === 0) return []

  // Collect all input values
  const inputs: any = {}
  for (const dep of deps) {
    const entry = entriesMap.get(dep.data_entry_field_id)
    if (!entry) return [] // Missing required input
    inputs[dep.parameter_name] = entry.value_quantity || entry.value_reference || entry.value_text
  }

  let result: number | null = null

  // Execute formula based on type
  switch (config.formula) {
    case 'weight_kg / (height_m * height_m)': // BMI
      if (inputs.weight_kg && inputs.height_m) {
        result = inputs.weight_kg / (inputs.height_m * inputs.height_m)
      }
      break

    case 'waist_cm / hip_cm': // Hip-to-Waist Ratio
      if (inputs.waist_cm && inputs.hip_cm) {
        result = inputs.waist_cm / inputs.hip_cm
      }
      break

    case 'gender_based_bmr': // BMR (Mifflin-St Jeor)
      if (inputs.weight_kg && inputs.height_cm && inputs.age_years && inputs.gender) {
        const base = (10 * inputs.weight_kg) + (6.25 * inputs.height_cm) - (5 * inputs.age_years)
        result = inputs.gender === 'male' ? base + 5 : base - 161
      }
      break

    case 'gender_based_navy_bodyfat': // Body Fat % (US Navy)
      if (inputs.neck_cm && inputs.waist_cm && inputs.height_cm && inputs.gender) {
        if (inputs.gender === 'male') {
          result = 86.010 * Math.log10(inputs.waist_cm - inputs.neck_cm) - 70.041 * Math.log10(inputs.height_cm) + 36.76
        } else if (inputs.hip_cm) {
          result = 163.205 * Math.log10(inputs.waist_cm + inputs.hip_cm - inputs.neck_cm) - 97.684 * Math.log10(inputs.height_cm) - 78.387
        }
      }
      break

    case 'weight_kg * (1 - (bodyfat_percent / 100))': // Lean Body Mass
      if (inputs.weight_kg && inputs.bodyfat_percent) {
        result = inputs.weight_kg * (1 - (inputs.bodyfat_percent / 100))
      }
      break

    default:
      console.warn(`Unknown formula: ${config.formula}`)
      return []
  }

  if (result === null) {
    console.log('Formula calculation failed - missing or invalid inputs')
    return []
  }

  // Round result
  if (config.rounding !== undefined) {
    result = Number(result.toFixed(config.rounding))
  }

  console.log(`Formula ${config.formula} = ${result}`)

  // Get timestamp from first input entry
  const firstEntry = entriesMap.get(deps[0].data_entry_field_id)
  const entry_date = firstEntry.entry_date
  const entry_timestamp = firstEntry.entry_timestamp

  return [{
    patient_id,
    event_instance_id,
    field_id: config.output_field,
    entry_date,
    entry_timestamp,
    value_quantity: result,
    source: config.output_source || 'auto_calculated',
    metadata: {
      calculated_by: calc.calc_id,
      formula: config.formula,
      inputs: inputs
    }
  }]
}

// =====================================================
// Calculation: Constant (Output fixed value)
// =====================================================
async function executeConstant(
  supabase: any,
  calc: any,
  patient_id: string,
  event_instance_id: string,
  entriesMap: Map<string, any>,
  config: any
): Promise<any[]> {

  console.log(`📊 executeConstant for ${calc.calc_id}`)
  console.log(`  entriesMap size: ${entriesMap.size}`)
  console.log(`  entriesMap keys: ${Array.from(entriesMap.keys()).join(', ')}`)

  // Get the trigger field dependency
  const { data: deps, error: depsError } = await supabase
    .from('instance_calculations_dependencies')
    .select('data_entry_field_id, parameter_role')
    .eq('instance_calculation_id', calc.calc_id)
    .eq('parameter_role', 'trigger')

  if (depsError) {
    console.error('Error fetching dependencies:', depsError)
    return []
  }

  console.log(`  Found ${deps?.length || 0} dependencies`)

  if (!deps || deps.length === 0) {
    console.warn('No trigger field found for constant calculation')
    return []
  }

  const triggerField = deps[0].data_entry_field_id
  console.log(`  Trigger field: ${triggerField}`)

  const triggerEntry = entriesMap.get(triggerField)

  if (!triggerEntry) {
    console.log(`❌ Trigger field ${triggerField} not found in entries`)
    return []
  }

  console.log(`✅ Trigger entry found`)

  const constantValue = config.constant_value || 1

  console.log(`Constant value: ${constantValue}`)

  // Use the trigger entry's timestamp
  const entry_date = triggerEntry.entry_date
  const entry_timestamp = triggerEntry.entry_timestamp

  return [{
    patient_id,
    event_instance_id,
    field_id: config.output_field,
    entry_date,
    entry_timestamp,
    value_quantity: constantValue,
    source: config.output_source || 'auto_calculated',
    metadata: {
      calculated_by: calc.calc_id,
      constant_value: constantValue,
      triggered_by: triggerField
    }
  }]
}
