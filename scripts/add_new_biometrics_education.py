#!/usr/bin/env python3
"""
Add education content for new biometrics: Total Sleep, Resting Heart Rate, Bodyfat, Blood Pressure (Systolic)
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

NEW_BIOMETRICS = {
    'Total Sleep': {
        'education': """**Understanding Total Sleep Duration**

Total sleep is the amount of actual sleep you get per night, excluding time spent awake in bed. It's one of the most powerful determinants of health, longevity, and cognitive function.

**The Longevity Connection:**
- Both short (<7 hours) and long (>9 hours) sleep associated with increased mortality
- Sweet spot: 7-9 hours for optimal longevity
- Sleep deprivation accelerates biological aging at the cellular level
- Poor sleep increases risk of dementia, cardiovascular disease, diabetes, cancer

**Optimal Sleep Duration:**
- **Adults (18-64)**: 7-9 hours
- **Optimal for most**: 7.5-8.5 hours
- Individual variation based on genetics

**The Bottom Line:**
Target 7-9 hours total sleep nightly for optimal longevity. Establish consistent sleep/wake times, create dark/cool sleep environment (65-68°F), avoid caffeine after 2 PM, and track to ensure you're hitting your target.""",
        'recommendations_primary': 'Target 7-9 hours nightly, consistent sleep/wake schedule, dark cool room (65-68°F), no caffeine after 2 PM, no screens 1 hour before bed',
        'therapeutics_secondary': 'Magnesium glycinate 300-400mg, melatonin 0.5-3mg (lowest effective dose); CBT-I for chronic insomnia'
    },

    'Resting Heart Rate': {
        'education': """**Understanding Resting Heart Rate (RHR)**

Resting heart rate is your heart rate when completely at rest, typically measured first thing in the morning. It's a powerful predictor of cardiovascular fitness and longevity.

**The Longevity Connection:**
- Lower RHR associated with longer lifespan
- Each 10 bpm increase above 60 increases mortality risk 10-20%
- RHR >80 bpm doubles cardiovascular mortality vs. <60 bpm
- Marker of cardiovascular fitness and autonomic nervous system health

**Optimal Ranges:**
- **Elite athletes**: 40-50 bpm
- **Very fit**: 50-60 bpm
- **Fit/optimal**: 60-70 bpm
- **Average**: 70-80 bpm
- **High risk**: >90 bpm

**Target for Longevity:** 50-65 bpm

**The Bottom Line:**
Target RHR 50-65 bpm for optimal longevity. Achieve through consistent aerobic training (150+ min weekly), adequate sleep, stress management, healthy body composition. Monitor daily with wearable device.""",
        'recommendations_primary': 'Aerobic exercise 150+ min weekly (mix of easy/moderate/hard), sleep 7-9 hours, manage stress, stay hydrated, lose excess weight',
        'therapeutics_secondary': 'Beta blockers (metoprolol 25-100mg) if tachycardia with hypertension; treat underlying causes'
    },

    'Bodyfat': {
        'education': """**Understanding Body Fat Percentage**

Body fat percentage is far more informative than weight or BMI for assessing health and longevity.

**The Longevity Connection:**
- Excess body fat (especially visceral) drives inflammation, insulin resistance, cardiovascular disease
- But too little body fat also problematic (hormonal dysfunction, weakened immunity)
- Fat distribution matters: visceral (belly) fat far more dangerous than subcutaneous

**Optimal Ranges:**
- **Men**: 10-15% optimal for longevity
- **Women**: 18-25% optimal for longevity

**The Bottom Line:**
Target 10-15% body fat for men, 18-25% for women. Focus on losing visceral fat through diet, resistance training, cardio, adequate sleep. Measure with DEXA scan or BIA to track progress.""",
        'recommendations_primary': 'Target 10-15% (men) or 18-25% (women) body fat; resistance train 3-4x weekly, adequate protein (1.6-2.0g/kg), manage stress, sleep 7-9 hours',
        'therapeutics_secondary': 'For obesity with metabolic dysfunction: GLP-1 agonists (semaglutide 2.4mg weekly, tirzepatide 15mg weekly)'
    },

    'Blood Pressure (Systolic)': {
        'education': """**Understanding Systolic Blood Pressure**

Systolic blood pressure (top number) is one of the most important cardiovascular risk factors.

**The Longevity Connection:**
- High BP is the #1 modifiable risk factor for cardiovascular disease
- Even "high normal" BP (120-129) increases mortality compared to optimal
- Each 20 mmHg increase doubles cardiovascular mortality
- Treating high BP is one of the most proven longevity interventions

**Optimal Ranges:**
- **Optimal**: <120 mmHg
- **Elevated**: 120-129 mmHg
- **Hypertension Stage 1**: 130-139 mmHg
- **Hypertension Stage 2**: ≥140 mmHg

**Target for Longevity:** <120 mmHg (ideally 110-115)

**The Bottom Line:**
Target systolic BP <120 mmHg. Achieve through: DASH diet (<1500mg sodium daily), weight loss if overweight, exercise 150+ min weekly, stress management, adequate sleep. If lifestyle not sufficient, medication is essential.""",
        'recommendations_primary': 'DASH diet with <1500mg sodium daily, lose weight if overweight, exercise 150+ min weekly, manage stress, sleep 7-9 hours',
        'therapeutics_secondary': 'ACE inhibitors (lisinopril 10-40mg), ARBs (losartan 50-100mg), calcium channel blockers (amlodipine 5-10mg); most need 2-3 medications'
    },
}

def populate_new_biometrics():
    """Add education content for new biometrics"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("ADDING NEW BIOMETRIC EDUCATION CONTENT")
        print("="*80)
        print()

        for biometric_name, content in NEW_BIOMETRICS.items():
            cur.execute("""
                UPDATE biometrics_base
                SET
                    education = %s,
                    recommendations_primary = COALESCE(recommendations_primary, %s),
                    therapeutics_secondary = COALESCE(therapeutics_secondary, %s),
                    updated_at = NOW()
                WHERE biometric_name = %s
                  AND is_active = true
            """, (
                content['education'],
                content.get('recommendations_primary'),
                content.get('therapeutics_secondary'),
                biometric_name
            ))

            if cur.rowcount > 0:
                print(f"✓ Updated: {biometric_name}")
            else:
                print(f"⚠ Not found: {biometric_name}")

        conn.commit()

        print()
        print("="*80)
        print("✅ New biometric education content added!")
        print("="*80)

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    populate_new_biometrics()
