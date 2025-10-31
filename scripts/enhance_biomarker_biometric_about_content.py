#!/usr/bin/env python3
"""
Enhance biomarker and biometric about content with rich, detailed information.
Fills in education content, enhances existing fields, adds missing recommendations.
"""

import psycopg2
import json

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# Enhanced education content for key biomarkers
BIOMARKER_EDUCATION = {
    'LDL': {
        'education': """**Understanding LDL Cholesterol**

LDL (Low-Density Lipoprotein) cholesterol is often called "bad" cholesterol because elevated levels can lead to plaque buildup in your arteries, increasing risk of heart attack and stroke.

**The Longevity Connection:**
Research shows that maintaining LDL below 70 mg/dL throughout life can reduce cardiovascular disease risk by up to 80%. Each 1 mmol/L (39 mg/dL) reduction in LDL reduces cardiovascular events by 22%.

**Beyond the Basics:**
- Particle size matters: small, dense LDL particles are more atherogenic than large, fluffy ones
- Oxidized LDL is particularly damaging - antioxidants help prevent oxidation
- LDL-P (particle number) may be more predictive than LDL-C (cholesterol content)
- Consider advanced testing like NMR LipoProfile for complete picture

**Lifestyle Impact:**
- Diet: Reduce saturated fat, increase soluble fiber (oats, beans, apples)
- Exercise: 30+ minutes daily can reduce LDL by 5-10%
- Weight loss: Every 10 lbs lost can reduce LDL by 5-8 mg/dL
- Sleep: Poor sleep increases LDL and triglycerides

**When to Consider Medication:**
If lifestyle changes don't achieve target after 3-6 months, discuss statins or PCSK9 inhibitors with your doctor. The earlier you optimize LDL, the greater the longevity benefit.""",
        'recommendations_primary': 'Consume 10-25g soluble fiber daily from oats, beans, apples, and psyllium husk',
        'therapeutics_primary': 'Statins (atorvastatin, rosuvastatin) remain first-line therapy for most patients'
    },

    'HbA1c': {
        'education': """**Understanding HbA1c (Hemoglobin A1c)**

HbA1c reflects your average blood glucose over the past 2-3 months by measuring glucose attached to hemoglobin in red blood cells.

**The Longevity Connection:**
Each 1% increase in HbA1c above 5% is associated with:
- 28% increased risk of death from any cause
- 38% increased cardiovascular death risk
- Accelerated biological aging (glycation damage)
- Higher risk of dementia and cognitive decline

**Optimal vs. Normal:**
- "Normal" range: <5.7%
- "Optimal" for longevity: 4.6-5.2%
- Pre-diabetes: 5.7-6.4%
- Diabetes: ≥6.5%

**The Science of Glycation:**
High glucose causes proteins to become "glycated" (sticky), damaging:
- Blood vessels (cardiovascular disease)
- Nerves (neuropathy)
- Kidneys (nephropathy)
- Eyes (retinopathy)
- Brain tissue (cognitive decline)

**Your Action Plan:**
1. **Diet:** Prioritize low glycemic index foods, pair carbs with protein/fat
2. **Exercise:** Both cardio and strength training improve insulin sensitivity
3. **Sleep:** 7-9 hours - poor sleep raises blood sugar
4. **Stress:** Chronic stress elevates cortisol which raises glucose
5. **Fasting:** Time-restricted eating or intermittent fasting can improve HbA1c

**Monitor Progress:**
- Test HbA1c every 3 months when optimizing
- Use continuous glucose monitor (CGM) to identify food triggers
- Track fasting glucose weekly for trends""",
        'recommendations_primary': 'Limit refined carbohydrates and prioritize low glycemic index foods with fiber',
        'therapeutics_primary': 'Metformin first-line; GLP-1 agonists (semaglutide, tirzepatide) highly effective'
    },

    'Vitamin D': {
        'education': """**Understanding Vitamin D**

Vitamin D is actually a hormone, not a vitamin, that regulates over 1,000 genes and plays crucial roles in immune function, bone health, mood, and longevity.

**The Longevity Connection:**
- Optimal levels (40-60 ng/mL) associated with 30% lower all-cause mortality
- Reduces cancer risk, especially colon, breast, prostate
- Essential for immune function - optimal levels reduce respiratory infections by 50%
- Critical for bone health and fall prevention in older adults
- May protect against dementia and cognitive decline

**The Deficiency Epidemic:**
75% of Americans are deficient (<30 ng/mL) due to:
- Indoor lifestyle (sunlight is primary source)
- Sunscreen use (SPF 30 blocks 97% of vitamin D production)
- Northern latitudes (insufficient UVB October-March)
- Darker skin (requires more sun exposure)
- Age (production declines with age)

**Getting Enough Vitamin D:**

**1. Sunlight (Best Source):**
- 10-30 minutes midday sun, 3x per week
- Expose arms and legs without sunscreen
- Earlier in summer, longer in winter
- Darker skin needs 3-6x more sun exposure

**2. Food Sources (Limited):**
- Fatty fish: salmon (450 IU/3oz), sardines (170 IU)
- Egg yolks: 40 IU each
- Fortified foods: milk, orange juice, cereals
- Mushrooms exposed to UV light

**3. Supplementation:**
- Most people need 2,000-4,000 IU daily
- Vitamin D3 (cholecalciferol) superior to D2
- Take with fat for absorption (olive oil, avocado)
- Pair with vitamin K2 for optimal calcium metabolism
- Test every 3-6 months to dial in your dose

**Special Considerations:**
- Obesity requires higher doses (fat-soluble vitamin gets stored)
- Darker skin needs 2-3x more supplementation
- Age >65 needs higher doses due to decreased production
- Certain medications (statins, steroids) lower vitamin D""",
        'recommendations_primary': 'Get 10-30 minutes midday sun 3x weekly or supplement with 2,000-4,000 IU D3 daily with fat',
        'therapeutics_primary': 'Vitamin D3 (cholecalciferol) 2,000-4,000 IU daily; higher doses up to 10,000 IU for deficiency'
    }
}

# Enhanced education content for key biometrics
BIOMETRIC_EDUCATION = {
    'VO2 Max': {
        'education': """**Understanding VO2 Max**

VO2 max is the maximum amount of oxygen your body can use during intense exercise. It's THE single best predictor of longevity and cardiovascular health.

**The Longevity Connection - This is Huge:**
- Every 1 MET increase (3.5 ml/kg/min) reduces all-cause mortality by 13%
- Individuals with VO2 max in the top 20% live 5-8 years longer than bottom 20%
- Low VO2 max is more dangerous than smoking, hypertension, or diabetes
- Improving from low to moderate fitness reduces mortality risk by 50%

**What the Numbers Mean:**

**Males:**
- Excellent: 50+ ml/kg/min (age 20s), 40+ (age 50s)
- Good: 43-50 (20s), 35-40 (50s)
- Average: 35-42 (20s), 28-34 (50s)
- Poor: <35 (20s), <28 (50s)

**Females:**
- Excellent: 45+ ml/kg/min (age 20s), 36+ (age 50s)
- Good: 39-44 (20s), 32-35 (50s)
- Average: 31-38 (20s), 24-31 (50s)
- Poor: <31 (20s), <24 (50s)

**How to Improve VO2 Max:**

**1. Zone 2 Training (Foundation - 80% of training):**
- Easy conversational pace, 60-70% max heart rate
- 3-4 sessions per week, 45-60 minutes each
- Builds mitochondria and aerobic base
- Activities: jogging, cycling, swimming, rowing

**2. High-Intensity Intervals (20% of training):**
- Norwegian 4x4 protocol most effective:
  - Warm up 10 min
  - 4 intervals: 4 min hard (90-95% max HR), 3 min easy recovery
  - Cool down 10 min
- Or Tabata: 20 sec all-out, 10 sec rest, 8 rounds
- 1-2 sessions per week maximum

**3. Progressive Overload:**
- Gradually increase duration before intensity
- Allow recovery - adaptation happens during rest
- Cross-train to prevent overuse injuries

**4. Track Progress:**
- Test VO2 max every 3-6 months
- Apple Watch/Garmin/Whoop provide estimates
- True VO2 max test at exercise physiology lab

**Typical Improvements:**
- Beginners: 15-25% increase in 3-6 months
- Trained athletes: 5-10% increase with focused training
- Older adults can improve as much as younger (may take longer)

**Beyond Exercise:**
- Weight loss improves VO2 max (same oxygen uptake, less body mass)
- Altitude training or hypoxic tents
- Iron supplementation if deficient (hemoglobin carries oxygen)
- Avoid smoking (destroys lung function)""",
        'recommendations_primary': 'Combine 3-4 weekly Zone 2 sessions (45-60 min) with 1-2 high-intensity interval sessions',
        'therapeutics_primary': 'No pharmaceutical interventions; exercise is the medicine'
    },

    'HRV': {
        'education': """**Understanding Heart Rate Variability (HRV)**

HRV measures the variation in time between heartbeats. Higher variability = better stress resilience, recovery, and overall health.

**The Science:**
Your autonomic nervous system has two branches:
- **Sympathetic:** "Fight or flight" - stress, exercise, danger
- **Parasympathetic:** "Rest and digest" - recovery, relaxation

High HRV = flexible nervous system that can adapt to stress
Low HRV = stuck in sympathetic overdrive (stressed, inflamed, overtrained)

**The Longevity Connection:**
- Low HRV predicts all-cause mortality as strongly as traditional risk factors
- Associated with cardiovascular disease, diabetes, depression
- Reflects biological aging - HRV declines ~1% per year naturally
- Athletes with high HRV perform better and recover faster

**What the Numbers Mean:**
- 60-180 ms = generally good (varies by measurement method)
- RMSSD most reliable metric (measures parasympathetic tone)
- Track YOUR baseline and trends vs. comparing to others
- Morning resting HRV most predictive

**Factors That Lower HRV:**
- Poor sleep (biggest impact)
- Overtraining/insufficient recovery
- Stress, anxiety
- Alcohol (even moderate amounts)
- Inflammation, illness
- Dehydration
- Poor nutrition

**How to Improve HRV:**

**1. Sleep Optimization (Most Important):**
- 7-9 hours per night
- Consistent sleep/wake times
- Cool, dark room (65-68°F)
- No screens 1-2 hours before bed
- Limit caffeine after 2pm

**2. Stress Management:**
- Daily meditation or breathwork (5-10 min)
- Spend time in nature
- Social connection
- Therapy for chronic stress

**3. Recovery Practices:**
- Take rest days seriously
- Active recovery (light walk, yoga)
- Sauna (heat stress improves HRV)
- Massage, foam rolling

**4. Breathwork (Immediate Impact):**
- Resonance breathing: 5.5 breaths/min, equal inhale/exhale
- Box breathing: 4-4-4-4 (inhale-hold-exhale-hold)
- 10-20 minutes daily can raise HRV

**5. Avoid HRV Killers:**
- Alcohol (destroys HRV for 2-3 days)
- Late/intense exercise (raises cortisol)
- Stimulants close to bedtime

**Using HRV for Training:**
- High HRV = green light for hard training
- Low HRV = rest day or easy aerobic work
- Trending down = back off volume/intensity
- Ignore day-to-day variation, watch 7-day average

**Measuring HRV:**
- Whoop, Oura Ring, Apple Watch, Garmin
- Measure first thing upon waking
- Track trends over weeks/months
- Don't obsess over daily values""",
        'recommendations_primary': 'Prioritize 7-9 hours quality sleep, practice daily breathwork, and avoid alcohol',
        'therapeutics_primary': 'No pharmaceutical interventions; lifestyle optimization is key'
    }
}

def enhance_biomarker_content():
    """Enhance biomarker about content"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("ENHANCING BIOMARKER ABOUT CONTENT")
        print("="*60)
        print()

        updated_count = 0

        for biomarker_name, content in BIOMARKER_EDUCATION.items():
            # Update with enhanced content
            cur.execute("""
                UPDATE biomarkers_base
                SET
                    education = %s,
                    recommendations_primary = COALESCE(recommendations_primary, %s),
                    therapeutics_primary = COALESCE(therapeutics_primary, %s),
                    updated_at = NOW()
                WHERE biomarker_name = %s
                  AND is_active = true
            """, (
                content.get('education'),
                content.get('recommendations_primary'),
                content.get('therapeutics_primary'),
                biomarker_name
            ))

            if cur.rowcount > 0:
                print(f"  ✓ Enhanced: {biomarker_name}")
                updated_count += 1
            else:
                print(f"  ⚠️  Not found: {biomarker_name}")

        conn.commit()
        print()
        print(f"Updated {updated_count} biomarkers with enhanced education content")
        return updated_count

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

def enhance_biometric_content():
    """Enhance biometric about content"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*60)
        print("ENHANCING BIOMETRIC ABOUT CONTENT")
        print("="*60)
        print()

        updated_count = 0

        for biometric_name, content in BIOMETRIC_EDUCATION.items():
            # Update with enhanced content
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
                content.get('education'),
                content.get('recommendations_primary'),
                content.get('therapeutics_primary'),  # Note: using therapeutics_secondary in table
                biometric_name
            ))

            if cur.rowcount > 0:
                print(f"  ✓ Enhanced: {biometric_name}")
                updated_count += 1
            else:
                print(f"  ⚠️  Not found: {biometric_name}")

        conn.commit()
        print()
        print(f"Updated {updated_count} biometrics with enhanced education content")
        return updated_count

    except Exception as e:
        conn.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        cur.close()
        conn.close()

def show_summary():
    """Show summary of content completeness"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print()
        print("="*60)
        print("CONTENT COMPLETENESS SUMMARY")
        print("="*60)
        print()

        # Biomarkers
        cur.execute("""
            SELECT
                COUNT(*) as total,
                COUNT(education) as has_education,
                COUNT(recommendations_primary) as has_rec_pri,
                COUNT(therapeutics_primary) as has_ther_pri,
                COUNT(evidence) as has_evidence
            FROM biomarkers_base
            WHERE is_active = true
        """)
        bio_stats = cur.fetchone()

        print("BIOMARKERS (60 total):")
        print(f"  Education:                 {bio_stats[1]}/60 ({bio_stats[1]*100//60}%)")
        print(f"  Recommendations (Primary): {bio_stats[2]}/60 ({bio_stats[2]*100//60}%)")
        print(f"  Therapeutics (Primary):    {bio_stats[3]}/60 ({bio_stats[3]*100//60}%)")
        print(f"  Evidence:                  {bio_stats[4]}/60 ({bio_stats[4]*100//60}%)")
        print()

        # Biometrics
        cur.execute("""
            SELECT
                COUNT(*) as total,
                COUNT(education) as has_education,
                COUNT(recommendations_primary) as has_rec_pri,
                COUNT(therapeutics_secondary) as has_ther_sec,
                COUNT(evidence) as has_evidence
            FROM biometrics_base
            WHERE is_active = true
        """)
        met_stats = cur.fetchone()

        print("BIOMETRICS (22 total):")
        print(f"  Education:                   {met_stats[1]}/22 ({met_stats[1]*100//22}%)")
        print(f"  Recommendations (Primary):   {met_stats[2]}/22 ({met_stats[2]*100//22}%)")
        print(f"  Therapeutics (Secondary):    {met_stats[3]}/22 ({met_stats[3]*100//22}%)")
        print(f"  Evidence:                    {met_stats[4]}/22 ({met_stats[4]*100//22}%)")
        print()

    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    print("="*60)
    print("BIOMARKER & BIOMETRIC CONTENT ENHANCEMENT")
    print("="*60)
    print()
    print("This script adds rich, detailed education content")
    print("to biomarkers and biometrics, matching the quality")
    print("of the pillar about sections.")
    print()

    bio_count = enhance_biomarker_content()
    print()
    met_count = enhance_biometric_content()

    show_summary()

    print()
    print("="*60)
    print("✅ ENHANCEMENT COMPLETE!")
    print("="*60)
    print()
    print(f"Enhanced {bio_count} biomarkers and {met_count} biometrics")
    print("with comprehensive education content.")
    print()
    print("Note: This is a sample of enhanced content.")
    print("To enhance all 60 biomarkers and 22 biometrics,")
    print("add entries to the dictionaries above.")
