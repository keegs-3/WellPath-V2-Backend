#!/usr/bin/env python3
"""
Add Batch 4: Inflammation markers education with standardized 7 sections
WBC, Neutrophils, Lymphocytes, Eosinophils
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

def add_wbc_education(cur):
    """Add WBC (White Blood Cell Count) education"""
    print("\nAdding WBC education...")

    # Get biomarker ID
    cur.execute("SELECT id FROM biomarkers_base WHERE biomarker_name = 'WBC (White Blood Cell Count)'")
    result = cur.fetchone()
    if not result:
        print("  ⚠️  WBC biomarker not found in biomarkers_base")
        return
    biomarker_id = result[0]

    sections = [
        {
            'title': 'Overview',
            'content': '''White blood cells (WBCs), or leukocytes, are the foundation of your immune system—your body's first responders to infection, inflammation, and tissue damage. Unlike red blood cells that carry oxygen, WBCs defend your body against bacteria, viruses, parasites, and other foreign invaders.

Your total WBC count reflects the combined number of all five types of white blood cells in your bloodstream: neutrophils, lymphocytes, monocytes, eosinophils, and basophils. Each type has specialized functions, from fighting bacterial infections to coordinating immune responses to managing allergic reactions.

A normal WBC count indicates your immune system is functioning properly—neither underactive (leaving you vulnerable to infections) nor overactive (causing chronic inflammation that accelerates aging). For longevity optimization, maintaining WBC count in the optimal range supports immune resilience while minimizing the inflammatory burden that drives age-related diseases.''',
            'order': 1
        },
        {
            'title': 'The Longevity Connection',
            'content': '''**Why WBC Count Matters for Healthy Aging:**

Your WBC count provides crucial insight into immune function and inflammatory status—two key determinants of healthspan and lifespan. Research consistently shows that both elevated and low WBC counts predict increased mortality risk, though through different mechanisms.

**The Inflammation-Aging Link:**
Elevated WBC counts, even within the "normal" clinical range, reflect chronic low-grade inflammation (inflammaging)—a hallmark of biological aging. Studies show that higher WBC counts (particularly above 7,000 cells/μL) associate with:
- Increased cardiovascular disease risk
- Higher rates of type 2 diabetes
- Greater cancer incidence
- Accelerated cognitive decline
- Shorter telomeres (cellular aging markers)

Large population studies demonstrate that individuals with WBC counts in the higher end of the normal range have significantly increased all-cause mortality compared to those in the optimal range.

**The Immune Resilience Factor:**
Conversely, low WBC counts can indicate compromised immune function, leaving you vulnerable to infections and potentially reflecting underlying nutritional deficiencies, bone marrow issues, or chronic disease. While less common, persistently low WBC counts (below 4,000 cells/μL) also associate with increased mortality.

**Optimal Range for Longevity:**
The "sweet spot" for longevity appears to be WBC counts in the 4,000-6,500 cells/μL range—high enough to maintain robust immune function but low enough to minimize chronic inflammation. This range supports effective pathogen defense while avoiding the accelerated aging associated with inflammatory excess.''',
            'order': 2
        },
        {
            'title': 'Optimal Ranges',
            'content': '''**Standard Laboratory Reference Range:**
- Normal: 4,000-11,000 cells/μL

**Longevity-Optimized Range:**
- Optimal: 4,500-6,500 cells/μL
- Acceptable: 4,000-7,000 cells/μL
- Monitor closely: Below 4,000 or above 7,000 cells/μL

**Why Standard Labs Miss the Mark:**
Conventional lab ranges are designed to catch disease, not optimize health. The upper limit of 11,000 cells/μL may be "normal" in a population sense, but counts above 7,000 cells/μL consistently associate with increased inflammation and mortality risk in research studies.

**Understanding Your Results:**
- **4,500-6,500 cells/μL (Optimal):** Balanced immune function with minimal inflammatory burden
- **6,500-8,000 cells/μL (Elevated-Acceptable):** May reflect subclinical inflammation or recent immune activation
- **Above 8,000 cells/μL (High):** Suggests chronic inflammation, acute infection, or significant stress response
- **Below 4,000 cells/μL (Low):** May indicate compromised immune function, nutritional deficiency, or bone marrow issues

**Important Context:**
WBC count should always be interpreted alongside the differential (breakdown of WBC types). Two people with identical total WBC counts can have very different health implications depending on which cell types are elevated or decreased.''',
            'order': 3
        },
        {
            'title': 'Symptoms & Causes',
            'content': '''**Symptoms of Elevated WBC Count:**
Often asymptomatic in chronic low-grade elevation, but may include:
- Fatigue and reduced energy
- Frequent minor infections or slow healing
- Joint pain or stiffness
- Digestive issues
- Brain fog or difficulty concentrating
- Unexplained fever (if acutely elevated)

**Common Causes of Elevated WBC:**
- **Chronic inflammation:** Obesity, metabolic syndrome, inflammatory diet
- **Acute infections:** Bacterial, viral, or fungal infections
- **Physical or emotional stress:** Intense exercise, psychological stress
- **Smoking:** Directly elevates WBC count
- **Autoimmune conditions:** Rheumatoid arthritis, inflammatory bowel disease
- **Medications:** Corticosteroids, epinephrine, lithium
- **Poor sleep:** Chronic sleep deprivation increases inflammatory signaling
- **Allergic reactions:** Elevated eosinophils driving total count up

**Symptoms of Low WBC Count:**
- Frequent infections (respiratory, skin, urinary)
- Prolonged recovery from illness
- Mouth ulcers or gum infections
- Fever and chills
- Severe fatigue

**Common Causes of Low WBC:**
- **Nutritional deficiencies:** Vitamin B12, folate, copper, zinc
- **Bone marrow disorders:** Aplastic anemia, myelodysplastic syndrome
- **Autoimmune conditions:** Lupus, rheumatoid arthritis
- **Viral infections:** HIV, hepatitis, Epstein-Barr virus
- **Medications:** Chemotherapy, antibiotics, antipsychotics
- **Radiation exposure:** Even low-dose chronic exposure
- **Severe chronic stress:** Prolonged cortisol elevation can suppress production''',
            'order': 4
        },
        {
            'title': 'How to Optimize',
            'content': '''**To Lower Elevated WBC Count:**

**1. Address Underlying Inflammation:**
- **Anti-inflammatory diet:** Emphasize omega-3 fatty acids (fatty fish, flaxseed), polyphenols (berries, green tea), and fiber while eliminating processed foods and excess omega-6 oils
- **Weight optimization:** Even modest weight loss significantly reduces inflammatory markers
- **Gut health:** Support diverse microbiome with fermented foods and prebiotics

**2. Lifestyle Modifications:**
- **Quit smoking:** WBC count typically normalizes within weeks to months after quitting
- **Stress management:** Meditation, yoga, and adequate recovery between intense activities
- **Sleep optimization:** Aim for 7-9 hours of quality sleep nightly
- **Moderate exercise:** Regular moderate activity reduces inflammation; avoid chronic overtraining

**3. Targeted Interventions:**
- **Curcumin:** 500-1,000 mg daily (with black pepper for absorption)
- **Omega-3s:** 2-4 grams EPA+DHA daily from fish oil or algae
- **Vitamin D optimization:** Maintain levels of 40-60 ng/mL
- **Resveratrol:** 150-500 mg daily

**To Raise Low WBC Count:**

**1. Correct Nutritional Deficiencies:**
- **Vitamin B12:** 1,000 mcg daily if deficient
- **Folate:** 400-800 mcg daily (methylfolate form preferred)
- **Zinc:** 15-30 mg daily (with copper balance)
- **Selenium:** 200 mcg daily

**2. Support Bone Marrow Function:**
- **Protein adequacy:** Ensure 0.8-1.0 g/kg body weight minimum
- **Iron status:** Optimize if deficient, but avoid excess
- **Vitamin B6:** 25-50 mg daily

**3. Lifestyle Factors:**
- **Avoid immune suppressors:** Excessive alcohol, chronic sleep deprivation
- **Manage chronic stress:** Prolonged cortisol elevation suppresses WBC production
- **Careful with medications:** Review medications with your doctor that may suppress bone marrow

**4. Medical Evaluation:**
If WBC remains low despite optimization, work with your physician to rule out:
- Autoimmune conditions requiring treatment
- Bone marrow disorders
- Chronic viral infections
- Medication side effects requiring adjustment''',
            'order': 5
        },
        {
            'title': 'Special Considerations',
            'content': '''**When to Seek Immediate Medical Attention:**
- WBC count below 3,000 cells/μL with fever
- WBC count above 15,000 cells/μL without obvious acute cause
- Rapid changes in WBC count between tests
- Low WBC with frequent or severe infections

**Athletes and Active Individuals:**
- Intense training can transiently elevate WBC count for 24-48 hours
- Chronic overtraining may elevate baseline WBC, reflecting inflammation
- Time blood tests for rest days when possible for accurate assessment
- Recovery inadequacy often shows as persistently elevated WBC

**Pregnancy:**
- WBC naturally increases during pregnancy (up to 15,000 cells/μL is normal)
- Further elevation may indicate infection requiring evaluation
- Returns to baseline within weeks after delivery

**Older Adults:**
- Baseline WBC tends to decrease modestly with age
- Lower end of optimal range (4,000-5,000 cells/μL) may be appropriate
- Greater vulnerability to infections if count drops below 4,000 cells/μL
- Monitor more closely as immune resilience naturally declines

**Medications That Affect WBC:**
- **Increase WBC:** Corticosteroids, lithium, epinephrine, G-CSF
- **Decrease WBC:** Chemotherapy, antibiotics (sulfonamides), antithyroid drugs, antipsychotics
- Inform your healthcare provider of all medications when interpreting results

**Testing Frequency:**
- Annual testing adequate if stable and optimal
- Every 3-6 months if elevated and implementing interventions
- More frequent if very low or if on medications affecting WBC
- Always retest abnormal results to confirm''',
            'order': 6
        },
        {
            'title': 'The Bottom Line',
            'content': '''White blood cell count is a powerful biomarker of immune function and inflammatory status—two critical determinants of how well you age. While conventional medicine views WBC count through the lens of diagnosing infections or blood disorders, the longevity perspective recognizes that even "normal" elevations predict accelerated aging and increased disease risk.

**Key Takeaways:**
- **Target 4,500-6,500 cells/μL** for optimal immune function with minimal inflammatory burden
- **Higher isn't better:** Counts above 7,000 cells/μL, though "normal," associate with increased mortality
- **Context matters:** Always interpret WBC alongside the differential to understand which cell types drive the total count
- **Modifiable factors:** Diet, weight, sleep, stress, and smoking significantly influence WBC count
- **Early indicator:** Changes in WBC can precede clinical disease, offering opportunity for early intervention

An optimized WBC count reflects the immune system sweet spot—vigilant enough to defend against threats but restrained enough to avoid the chronic inflammation that accelerates aging. This balance supports both healthspan and lifespan, allowing you to maintain vitality and resilience as you age.''',
            'order': 7
        }
    ]

    for section in sections:
        cur.execute("""
            INSERT INTO biomarkers_education_sections (
                biomarker_id,
                section_title,
                section_content,
                display_order,
                is_active
            )
            VALUES (%s, %s, %s, %s, %s)
        """, (biomarker_id, section['title'], section['content'], section['order'], True))

    print(f"  ✓ Added {len(sections)} sections for WBC")

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("BATCH 4: Adding Inflammation Markers Education")
        print("="*80)

        add_wbc_education(cur)

        conn.commit()
        print("\n✅ Batch 4 WBC complete!")

    except Exception as e:
        conn.rollback()
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
        raise
    finally:
        cur.close()
        conn.close()

if __name__ == '__main__':
    main()
