// =====================================================
// COMPLEX SURVEY SCORING FUNCTIONS
// Ported from wellpath_score_runner_survey_v2.py
// =====================================================

// =====================================================
// PROTEIN INTAKE SCORING
// =====================================================

function calcProteinTarget(weightLb: number, age: number): number {
  const weightKg = weightLb / 2.205
  let target: number

  if (age < 65) {
    target = 1.2 * weightKg
  } else {
    target = 1.5 * weightKg
  }

  return Math.round(target * 10) / 10
}

export function scoreProteinIntake(proteinG: string | number, weightLb: number, age: number): number {
  try {
    const protein = typeof proteinG === 'string' ? parseFloat(proteinG) : proteinG
    const target = calcProteinTarget(weightLb, age)
    const pct = target > 0 ? protein / target : 0

    if (pct >= 1) return 1.0
    if (pct >= 0.8) return 0.8
    if (pct >= 0.6) return 0.6
    if (pct > 0) return 0.4
    return 0
  } catch {
    return 0
  }
}

// =====================================================
// CALORIE INTAKE SCORING
// =====================================================

function calcCalorieTarget(weightLb: number, age: number, sex: string): number {
  const weightKg = weightLb / 2.205
  let bmr: number

  // Harris-Benedict BMR calculation
  if (sex.toLowerCase().startsWith('m')) {
    // Male: using avg height 175cm
    bmr = 88.362 + (13.397 * weightKg) + (4.799 * 175) - (5.677 * age)
  } else {
    // Female: using avg height 162cm
    bmr = 447.593 + (9.247 * weightKg) + (3.098 * 162) - (4.330 * age)
  }

  const calorieTarget = bmr * 1.2  // Sedentary multiplier
  return Math.round(calorieTarget)
}

export function scoreCalorieIntake(calories: string | number, weightLb: number, age: number, sex: string): number {
  try {
    const cals = typeof calories === 'string' ? parseFloat(calories) : calories
    const target = calcCalorieTarget(weightLb, age, sex)
    const pct = target > 0 ? cals / target : 0

    // Within ±15% of target = 1.0; ±25% = 0.8, ±35% = 0.6, else 0.2
    if (pct >= 0.85 && pct <= 1.15) return 1.0
    if ((pct >= 0.75 && pct < 0.85) || (pct > 1.15 && pct <= 1.25)) return 0.8
    if ((pct >= 0.65 && pct < 0.75) || (pct > 1.25 && pct <= 1.35)) return 0.6
    return 0.2
  } catch {
    return 0
  }
}

// =====================================================
// MOVEMENT SCORING
// =====================================================

const FREQ_SCORES: Record<string, number> = {
  '': 0.0,
  'Rarely (a few times a month)': 0.4,
  'Occasionally (1–2 times per week)': 0.6,
  'Regularly (3–4 times per week)': 0.8,
  'Frequently (5 or more times per week)': 1.0
}

const DUR_SCORES: Record<string, number> = {
  '': 0.0,
  'Less than 30 minutes': 0.6,
  '30–45 minutes': 0.8,
  '45–60 minutes': 0.9,
  'More than 60 minutes': 1.0
}

export function scoreMovementActivity(responses: any, freqQuestion: string, durationQuestion: string): number {
  const freqAns = responses[freqQuestion] || ''
  const durAns = responses[durationQuestion] || ''

  const freqScore = FREQ_SCORES[freqAns] || 0.0
  const durScore = DUR_SCORES[durAns] || 0.0

  if (freqScore === 0 && durScore === 0) {
    return 0
  }

  const total = freqScore + durScore

  // If total >= 1.6, give full credit (1.0)
  // Otherwise, scale proportionally: total * (1 / 2) = total / 2
  return total >= 1.6 ? 1.0 : total / 2.0
}

// =====================================================
// SLEEP ISSUES SCORING
// =====================================================

const SLEEP_ISSUES = [
  { issue: 'Difficulty falling asleep', freqQ: '4.13', weight: 5 },
  { issue: 'Difficulty staying asleep', freqQ: '4.14', weight: 5 },
  { issue: 'Waking up too early', freqQ: '4.15', weight: 5 },
  { issue: 'Frequent nightmares', freqQ: '4.16', weight: 3 },
  { issue: 'Restless legs', freqQ: '4.17', weight: 6 },
  { issue: 'Snoring', freqQ: '4.18', weight: 4 }
]

const SLEEP_FREQ_MAP: Record<string, number> = {
  'Always': 0.2,
  'Frequently': 0.4,
  'Occasionally': 0.6,
  'Rarely': 0.8,
  '': 1.0  // Not selected = full credit
}

export function scoreSleepIssues(responses: any): number {
  const issuesStr = responses['4.12'] || ''
  const issuesReported = issuesStr.split('|').map((s: string) => s.trim()).filter((s: string) => s)

  // Full credit if none reported or "None" selected
  if (issuesReported.length === 0 || issuesReported.some((s: string) => s.toLowerCase().includes('none'))) {
    return 1.0  // Perfect score - no sleep issues
  }

  // Score each issue
  let totalScore = 0

  for (const issue of SLEEP_ISSUES) {
    let multiplier: number

    if (issuesReported.includes(issue.issue)) {
      // Issue was reported, check frequency
      const freqAns = responses[issue.freqQ] || ''
      multiplier = SLEEP_FREQ_MAP[freqAns] || 0.2
    } else {
      // Issue not reported = full credit
      multiplier = 1.0
    }

    totalScore += issue.weight * multiplier
  }

  // Normalize to 0-1 scale
  const maxScore = SLEEP_ISSUES.reduce((sum, issue) => sum + issue.weight, 0)
  return totalScore / maxScore
}

// =====================================================
// SLEEP PROTOCOLS SCORING
// =====================================================

export function scoreSleepProtocols(answer: string): number {
  const protocols = (answer || '').split('|').map(p => p.trim()).filter(p => p)
  const n = protocols.length

  if (n >= 7) return 1.0
  if (n >= 5) return 0.8
  if (n >= 3) return 0.6
  if (n >= 1) return 0.4
  return 0.2
}

// =====================================================
// SLEEP APNEA MANAGEMENT SCORING
// =====================================================

export function scoreSleepApnea(responses: any): number {
  const diagnosis = responses['4.28'] || ''
  const severity = responses['4.30'] || ''
  const timeSince = responses['4.29'] || ''
  const treatments = responses['4.31'] || ''
  const improvement = responses['4.32'] || ''

  // Base cases
  if (diagnosis === 'No') {
    return 1.0  // Full marks - no sleep apnea
  } else if (diagnosis === "I suspect I may have it but haven't been diagnosed") {
    return 0.0  // Zero marks - unmanaged suspected condition
  }

  // Severity-based potential impact
  const severityBase: Record<string, number> = {
    'Severe (AHI 30+ events per hour)': 0.20,
    'Moderate (AHI 15-29 events per hour)': 0.35,
    'Mild (AHI 5-14 events per hour)': 0.50,
    "I don't know/wasn't told the severity": 0.35
  }
  const baseScore = severityBase[severity] || 0.35

  // Time categories
  const timeCategories: Record<string, string> = {
    'Less than 6 months': 'recent',
    '6 months to 1 year': 'recent',
    '1-2 years': 'established',
    '2-5 years': 'established',
    'More than 5 years': 'established'
  }
  const timeCategory = timeCategories[timeSince] || 'established'

  let managementScore = baseScore

  if (timeCategory === 'recent') {
    // Recent diagnosis: Focus on treatment quality
    let treatmentBonus = 0
    const treatmentList = treatments.split('|').map((t: string) => t.trim())

    if (treatmentList.some(t => t.includes('CPAP') || t.includes('BiPAP'))) {
      treatmentBonus += 0.30
    } else if (treatmentList.some(t => t.includes('Oral appliance'))) {
      treatmentBonus += 0.20
    }

    // Comprehensive approach bonus
    const activeTreatments = treatmentList.filter(t => !t.includes('No treatment'))
    if (activeTreatments.length >= 3) treatmentBonus += 0.10
    else if (activeTreatments.length >= 2) treatmentBonus += 0.05

    // Improvement bonus
    const improvementBonus: Record<string, number> = {
      'Significantly improved': 0.10,
      'Moderately improved': 0.05,
      'Slightly improved': 0.02,
      'No improvement': 0.0,
      'Symptoms have worsened': -0.05
    }

    managementScore = baseScore + treatmentBonus + (improvementBonus[improvement] || 0)
  } else {
    // Established diagnosis: Focus on outcomes
    const improvementBonus: Record<string, number> = {
      'Significantly improved': 0.65,
      'Moderately improved': 0.45,
      'Slightly improved': 0.25,
      'No improvement': -0.10,
      'Symptoms have worsened': -0.20
    }

    let treatmentBonus = 0
    const treatmentList = treatments.split('|').map((t: string) => t.trim())

    if (treatmentList.some(t => t.includes('CPAP') || t.includes('BiPAP'))) {
      treatmentBonus += 0.05
    } else if (treatmentList.some(t => t.includes('No treatment currently'))) {
      treatmentBonus -= 0.10
    }

    managementScore = baseScore + (improvementBonus[improvement] || 0) + treatmentBonus
  }

  // Excellence bonus for severe cases that are well managed
  if (severity === 'Severe (AHI 30+ events per hour)' && improvement === 'Significantly improved') {
    managementScore += 0.10
  }

  // Clamp to 0-1 range
  return Math.max(0.0, Math.min(1.0, managementScore))
}

// =====================================================
// COGNITIVE ACTIVITIES SCORING
// =====================================================

export function scoreCognitiveActivities(answer: string): number {
  const activities = (answer || '').split('|').map(a => a.trim()).filter(a => a)
  const n = activities.length

  if (n >= 5) return 1.0
  if (n === 4) return 0.8
  if (n === 3) return 0.6
  if (n === 2) return 0.4
  if (n === 1) return 0.2
  return 0.0
}

// =====================================================
// STRESS SCORING
// =====================================================

export function scoreStress(stressLevel: string, frequency: string): number {
  const levelMap: Record<string, number> = {
    'No stress': 1.0,
    'Low stress': 0.8,
    'Moderate stress': 0.5,
    'High stress': 0.2,
    'Extreme stress': 0.0,
    'Stress levels vary from low to moderate': 0.5,
    'Stress levels vary from moderate to high': 0.5
  }

  const freqMap: Record<string, number> = {
    'Rarely': 1.0,
    'Occasionally': 0.7,
    'Frequently': 0.4,
    'Always': 0.0
  }

  const s = levelMap[stressLevel] || 0.5
  const f = freqMap[frequency] || 0.5
  const rawScore = (s + f) / 2

  // Normalize to 0-1 (Python returns out of 19)
  return rawScore
}

// =====================================================
// COPING SKILLS SCORING
// =====================================================

const COPING_WEIGHTS: Record<string, number> = {
  'Exercise or physical activity': 1.0,
  'Meditation or mindfulness practices': 1.0,
  'Deep breathing exercises': 0.7,
  'Hobbies or recreational activities': 0.7,
  'Talking to friends or family': 0.7,
  'Professional counseling or therapy': 1.0,
  'Journaling or writing': 0.5,
  'Time management strategies': 0.5,
  'Avoiding stressful situations': 0.3,
  'Other (please specify)': 0.3,
  'None': 0.0
}

export function scoreCoping(answer: string, stressLevel: string, frequency: string): number {
  const responses = (answer || '').split('|').map(r => r.trim()).filter(r => r)
  const hasNone = responses.some(r => r.toLowerCase().includes('none'))
  const highStress = ['High stress', 'Extreme stress'].includes(stressLevel) ||
                     ['Frequently', 'Always'].includes(frequency)

  if (hasNone || responses.length === 0) {
    return highStress ? 0.0 : 5.5 / 7.0  // Normalize to 0-1
  }

  // Calculate weighted score
  const totalWeight = responses.reduce((sum, r) => sum + (COPING_WEIGHTS[r] || 0.5), 0)
  const weightedScore = Math.min(totalWeight * 3.5, 7.0)

  // Adjust based on stress level
  if (!highStress) {
    return Math.min(5.5 + totalWeight, 7.0) / 7.0  // Normalize to 0-1
  } else {
    return weightedScore / 7.0  // Normalize to 0-1
  }
}

// =====================================================
// SUBSTANCE USE SCORING
// =====================================================

const USE_BAND_SCORES: Record<string, number> = {
  'Heavy': 0.0,
  'Moderate': 0.25,
  'Light': 0.5,
  'Minimal': 0.75,
  'Occasional': 1.0
}

const DURATION_SCORES: Record<string, number> = {
  'Less than 1 year': 1.0,
  '1-2 years': 0.8,
  '3-5 years': 0.6,
  '6-10 years': 0.4,
  '11-20 years': 0.2,
  'More than 20 years': 0.0
}

const QUIT_TIME_BONUS: Record<string, number> = {
  'Less than 3 years': 0.0,
  '3-5 years': 0.1,
  '6-10 years': 0.2,
  '11-20 years': 0.4,
  'More than 20 years': 0.6
}

const SUBSTANCE_QUESTIONS: Record<string, any> = {
  'substance_tobacco_score': {
    current_band: '8.02',
    current_years: '8.03',
    current_trend: '8.04',
    former_band: '8.22',
    former_years: '8.21',
    time_since_quit: '8.23',
    current_in_which: 'Tobacco (cigarettes, cigars, smokeless tobacco)',
    former_in_which: 'Tobacco (cigarettes, cigars, smokeless tobacco)'
  },
  'substance_nicotine_score': {
    current_band: '8.11',
    current_years: '8.12',
    current_trend: '8.13',
    former_band: '8.31',
    former_years: '8.30',
    time_since_quit: '8.32',
    current_in_which: 'Nicotine',
    former_in_which: 'Nicotine'
  },
  'substance_alcohol_score': {
    current_band: '8.05',
    current_years: '8.06',
    current_trend: '8.07',
    former_band: '8.25',
    former_years: '8.24',
    time_since_quit: '8.26',
    current_in_which: 'Alcohol',
    former_in_which: 'Alcohol'
  },
  'substance_recreational_drugs_score': {
    current_band: '8.08',
    current_years: '8.09',
    current_trend: '8.10',
    former_band: '8.28',
    former_years: '8.27',
    time_since_quit: '8.29',
    current_in_which: 'Recreational drugs (e.g., marijuana)',
    former_in_which: 'Recreational drugs (e.g., marijuana)'
  },
  'substance_otc_meds_score': {
    current_band: '8.14',
    current_years: '8.15',
    current_trend: '8.16',
    former_band: '8.34',
    former_years: '8.33',
    time_since_quit: '8.35',
    current_in_which: 'Over-the-counter medications (e.g., sleep aids)',
    former_in_which: 'Over-the-counter medications (e.g., sleep aids)'
  },
  'substance_other_score': {
    current_band: '8.17',
    current_years: '8.18',
    current_trend: '8.19',
    former_band: '8.37',
    former_years: '8.36',
    time_since_quit: '8.38',
    current_in_which: 'Other',
    former_in_which: 'Other'
  }
}

function scoreSubstanceUseSingle(useBand: string, yearsBand: string, isCurrent: boolean, usageTrend?: string, timeSinceQuit?: string): number {
  // Extract band level (handle "Heavy: ..." format)
  const bandLevel = useBand ? useBand.split(':')[0].trim() : 'Heavy'
  const bandScore = USE_BAND_SCORES[bandLevel] ?? 0.0
  const durationScore = DURATION_SCORES[yearsBand] ?? 0.0
  let baseScore = Math.min(bandScore, durationScore)

  if (!isCurrent) {
    // Add quit bonus based on time since quit
    const quitBonus = timeSinceQuit ? (QUIT_TIME_BONUS[timeSinceQuit] ?? 0.15) : 0.15
    baseScore = Math.min(baseScore + quitBonus, 1.0)
  }

  if (isCurrent && usageTrend) {
    if (usageTrend === 'I currently use more than I used to') {
      baseScore = Math.max(baseScore - 0.1, 0.0)
    } else if (usageTrend === 'I currently use less than I used to') {
      baseScore = Math.min(baseScore + 0.1, 1.0)
    }
  }

  return baseScore
}

export function scoreSubstanceUse(functionName: string, responses: any): number {
  const qmap = SUBSTANCE_QUESTIONS[functionName]
  if (!qmap) return 1.0  // Unknown substance = perfect score

  const currentList = (responses['8.01'] || '').split('|').map((s: string) => s.trim())
  const formerList = (responses['8.20'] || '').split('|').map((s: string) => s.trim())

  const isCurrent = currentList.includes(qmap.current_in_which)
  const isFormer = !isCurrent && formerList.includes(qmap.former_in_which)

  let score = 1.0  // Default: never used = perfect

  if (isCurrent) {
    const useBand = responses[qmap.current_band] || ''
    const yearsBand = responses[qmap.current_years] || ''
    const usageTrend = responses[qmap.current_trend] || ''
    score = scoreSubstanceUseSingle(useBand, yearsBand, true, usageTrend)
  } else if (isFormer) {
    const useBand = responses[qmap.former_band] || ''
    const yearsBand = responses[qmap.former_years] || ''
    const timeSinceQuit = responses[qmap.time_since_quit] || ''
    score = scoreSubstanceUseSingle(useBand, yearsBand, false, undefined, timeSinceQuit)
  }

  return score
}

// =====================================================
// SCREENING COMPLIANCE SCORING
// =====================================================

const SCREENING_GUIDELINES: Record<string, any> = {
  'screening_dental_score': { question: '10.01', window: 6 },
  'screening_skin_check_score': { question: '10.02', window: 12 },
  'screening_vision_score': { question: '10.03', window: 12 },
  'screening_colonoscopy_score': { question: '10.04', window: 120 },
  'screening_mammogram_score': { question: '10.05', window: 12 },
  'screening_pap_score': { question: '10.06', window: 36 },
  'screening_dexa_score': { question: '10.07', window: 36 },
  'screening_psa_score': { question: '10.08', window: 36 },
  'screening_hpv_score': { question: '10.09', window: 60 },  // Placeholder
  'screening_breast_mri_score': { question: '10.10', window: 12 }  // Placeholder
}

function scoreDateResponse(dateStr: string, windowMonths: number): number {
  if (!dateStr) return 0

  try {
    const examDate = new Date(dateStr)
    const today = new Date()

    // Calculate months difference
    const monthsAgo = (today.getFullYear() - examDate.getFullYear()) * 12 +
                      (today.getMonth() - examDate.getMonth())

    if (monthsAgo <= windowMonths) {
      return 1.0
    } else if (monthsAgo <= windowMonths * 1.5) {
      return 0.6
    } else {
      return 0.2
    }
  } catch {
    return 0
  }
}

export function scoreScreeningCompliance(functionName: string, examDate: string, guideline: any): number {
  if (!guideline) return 0.5  // Unknown screening
  return scoreDateResponse(examDate, guideline.window)
}
