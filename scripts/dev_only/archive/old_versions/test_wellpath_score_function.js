// Test the calculate-wellpath-score Edge Function

const SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcxMjg1MjQ3NCwiZXhwIjoyMDI4NDI4NDc0fQ.UusMW-SjUhIqRWZm8cg5E0CWY0X4XJSn3v8BXc-6n2g'

// Test with a patient ID from the database
const TEST_PATIENT_ID = '527cab3c-8a78-4b8b-91d9-fdeb59f8f257'

async function testScoreFunction() {
  console.log('Testing calculate-wellpath-score Edge Function...')
  console.log(`Patient ID: ${TEST_PATIENT_ID}`)
  console.log('')

  try {
    const response = await fetch(`${SUPABASE_URL}/functions/v1/calculate-wellpath-score`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${SUPABASE_SERVICE_KEY}`
      },
      body: JSON.stringify({
        patient_id: TEST_PATIENT_ID
      })
    })

    if (!response.ok) {
      const error = await response.text()
      console.error('❌ Error:', response.status, error)
      return
    }

    const result = await response.json()
    console.log('✅ Success!')
    console.log('')
    console.log('Overall Score:', result.overall_score)
    console.log('')
    console.log('Pillar Scores:')
    console.log('=' .repeat(80))

    for (const pillar of result.pillar_scores) {
      console.log(`\n${pillar.pillar_name}:`)
      console.log(`  Final Score: ${(pillar.final_score * 100).toFixed(1)}%`)
      console.log(`  Markers: ${pillar.markers_score.toFixed(1)}/${pillar.markers_max} (${pillar.markers_max > 0 ? ((pillar.markers_score/pillar.markers_max)*100).toFixed(1) : 0}%)`)
      console.log(`  Survey: ${pillar.survey_score.toFixed(1)}/${pillar.survey_max} (${pillar.survey_max > 0 ? ((pillar.survey_score/pillar.survey_max)*100).toFixed(1) : 0}%)`)
      console.log(`  Education: ${pillar.education_score}/${pillar.education_max} (${pillar.education_max > 0 ? ((pillar.education_score/pillar.education_max)*100).toFixed(1) : 0}%)`)
      console.log(`  Component Weights: Markers=${(pillar.component_weights.markers*100).toFixed(0)}%, Survey=${(pillar.component_weights.survey*100).toFixed(0)}%, Education=${(pillar.component_weights.education*100).toFixed(0)}%`)
    }

    console.log('')
    console.log('=' .repeat(80))
    console.log('Full response:', JSON.stringify(result, null, 2))

  } catch (error) {
    console.error('❌ Error calling function:', error.message)
  }
}

testScoreFunction()
