// Calculate WellPath scores for all patients and update patient_details

const { createClient } = require('@supabase/supabase-js')

const SUPABASE_URL = 'https://csotzmardnvrpdhlogjm.supabase.co'
const SUPABASE_SERVICE_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk'

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_KEY)

async function calculateAllScores() {
  console.log('Fetching all patients...')

  const { data: patients, error: patientsError } = await supabase
    .from('patient_details')
    .select('user_id')

  if (patientsError) {
    console.error('Error fetching patients:', patientsError)
    return
  }

  console.log('Found ' + patients.length + ' patients')

  let successCount = 0
  let errorCount = 0

  for (const patient of patients) {
    try {
      console.log('Calculating score for patient ' + patient.user_id + '...')

      const { data: scoreData, error: scoreError } = await supabase.functions.invoke(
        'calculate-wellpath-score',
        {
          body: { patient_id: patient.user_id }
        }
      )

      if (scoreError) {
        console.error('  Error:', scoreError.message)
        errorCount++
        continue
      }

      const overallScore = scoreData.overall_score

      const { error: updateError } = await supabase
        .from('patient_details')
        .update({ wellpath_score: overallScore })
        .eq('user_id', patient.user_id)

      if (updateError) {
        console.error('  Error updating score:', updateError.message)
        errorCount++
        continue
      }

      console.log('  Score: ' + (overallScore * 100).toFixed(1) + '%')
      successCount++

    } catch (err) {
      console.error('  Exception:', err.message)
      errorCount++
    }
  }

  console.log('')
  console.log('='.repeat(80))
  console.log('SUMMARY')
  console.log('='.repeat(80))
  console.log('Total patients: ' + patients.length)
  console.log('Successfully calculated: ' + successCount)
  console.log('Errors: ' + errorCount)
}

calculateAllScores()
