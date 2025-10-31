#!/usr/bin/env python3
"""
Add Batch 4: Complete inflammation markers education
White Blood Cell Count, Neutrophils, Lymphocytes, Eosinophils
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres"

# All education content for the 4 inflammation markers
BIOMARKER_DATA = {
    "White Blood Cell Count": {
        "sections": [
            {"title": "Overview", "content": """White blood cells (WBCs), or leukocytes, are the foundation of your immune system—your body's first responders to infection, inflammation, and tissue damage. Unlike red blood cells that carry oxygen, WBCs defend your body against bacteria, viruses, parasites, and other foreign invaders.

Your total WBC count reflects the combined number of all five types of white blood cells in your bloodstream: neutrophils, lymphocytes, monocytes, eosinophils, and basophils. Each type has specialized functions, from fighting bacterial infections to coordinating immune responses to managing allergic reactions.

A normal WBC count indicates your immune system is functioning properly—neither underactive (leaving you vulnerable to infections) nor overactive (causing chronic inflammation that accelerates aging). For longevity optimization, maintaining WBC count in the optimal range supports immune resilience while minimizing the inflammatory burden that drives age-related diseases."""},

            {"title": "The Longevity Connection", "content": """**Why WBC Count Matters for Healthy Aging:**

Your WBC count provides crucial insight into immune function and inflammatory status—two key determinants of healthspan and lifespan. Research consistently shows that both elevated and low WBC counts predict increased mortality risk, though through different mechanisms.

**The Inflammation-Aging Link:**
Elevated WBC counts, even within the "normal" clinical range, reflect chronic low-grade inflammation (inflammaging)—a hallmark of biological aging. Studies show that higher WBC counts (particularly above 7,000 cells/μL) associate with increased cardiovascular disease risk, higher rates of type 2 diabetes, greater cancer incidence, accelerated cognitive decline, and shorter telomeres.

**The Immune Resilience Factor:**
Conversely, low WBC counts can indicate compromised immune function, leaving you vulnerable to infections and potentially reflecting underlying nutritional deficiencies, bone marrow issues, or chronic disease.

**Optimal Range for Longevity:**
The sweet spot for longevity appears to be WBC counts in the 4,000-6,500 cells/μL range—high enough to maintain robust immune function but low enough to minimize chronic inflammation."""},

            {"title": "Optimal Ranges", "content": """**Standard Laboratory Reference Range:**
- Normal: 4,000-11,000 cells/μL

**Longevity-Optimized Range:**
- Optimal: 4,500-6,500 cells/μL
- Acceptable: 4,000-7,000 cells/μL
- Monitor closely: Below 4,000 or above 7,000 cells/μL

**Why Standard Labs Miss the Mark:**
Conventional lab ranges are designed to catch disease, not optimize health. The upper limit of 11,000 cells/μL may be "normal" in a population sense, but counts above 7,000 cells/μL consistently associate with increased inflammation and mortality risk.

**Understanding Your Results:**
- **4,500-6,500 cells/μL (Optimal):** Balanced immune function with minimal inflammatory burden
- **6,500-8,000 cells/μL (Elevated-Acceptable):** May reflect subclinical inflammation
- **Above 8,000 cells/μL (High):** Suggests chronic inflammation or acute infection
- **Below 4,000 cells/μL (Low):** May indicate compromised immune function"""},

            {"title": "Symptoms & Causes", "content": """**Symptoms of Elevated WBC Count:**
Often asymptomatic in chronic low-grade elevation, but may include:
- Fatigue and reduced energy
- Frequent minor infections or slow healing
- Joint pain or stiffness
- Digestive issues
- Brain fog or difficulty concentrating
- Unexplained fever (if acutely elevated)

**Common Causes of Elevated WBC:**
- Chronic inflammation (obesity, metabolic syndrome, inflammatory diet)
- Acute infections (bacterial, viral, fungal)
- Physical or emotional stress
- Smoking
- Autoimmune conditions
- Medications (corticosteroids, epinephrine, lithium)
- Poor sleep
- Allergic reactions

**Symptoms of Low WBC Count:**
- Frequent infections (respiratory, skin, urinary)
- Prolonged recovery from illness
- Mouth ulcers or gum infections
- Fever and chills
- Severe fatigue

**Common Causes of Low WBC:**
- Nutritional deficiencies (vitamin B12, folate, copper, zinc)
- Bone marrow disorders
- Autoimmune conditions
- Viral infections (HIV, hepatitis, Epstein-Barr virus)
- Medications (chemotherapy, antibiotics, antipsychotics)
- Radiation exposure
- Severe chronic stress"""},

            {"title": "How to Optimize", "content": """**To Lower Elevated WBC Count:**

**1. Address Underlying Inflammation:**
- Anti-inflammatory diet emphasizing omega-3 fatty acids, polyphenols, and fiber
- Weight optimization
- Gut health support with fermented foods and prebiotics

**2. Lifestyle Modifications:**
- Quit smoking
- Stress management (meditation, yoga)
- Sleep optimization (7-9 hours nightly)
- Moderate exercise

**3. Targeted Interventions:**
- Curcumin: 500-1,000 mg daily
- Omega-3s: 2-4 grams EPA+DHA daily
- Vitamin D optimization: 40-60 ng/mL
- Resveratrol: 150-500 mg daily

**To Raise Low WBC Count:**

**1. Correct Nutritional Deficiencies:**
- Vitamin B12: 1,000 mcg daily if deficient
- Folate: 400-800 mcg daily
- Zinc: 15-30 mg daily
- Selenium: 200 mcg daily

**2. Support Bone Marrow Function:**
- Adequate protein (0.8-1.0 g/kg body weight)
- Optimize iron status
- Vitamin B6: 25-50 mg daily

**3. Lifestyle Factors:**
- Avoid immune suppressors (excessive alcohol, chronic sleep deprivation)
- Manage chronic stress
- Review medications with your doctor

**4. Medical Evaluation:**
If WBC remains low despite optimization, work with your physician to rule out underlying conditions."""},

            {"title": "Special Considerations", "content": """**When to Seek Immediate Medical Attention:**
- WBC count below 3,000 cells/μL with fever
- WBC count above 15,000 cells/μL without obvious cause
- Rapid changes in WBC count
- Low WBC with frequent or severe infections

**Athletes and Active Individuals:**
- Intense training can transiently elevate WBC for 24-48 hours
- Chronic overtraining may elevate baseline WBC
- Time blood tests for rest days for accurate assessment

**Pregnancy:**
- WBC naturally increases during pregnancy (up to 15,000 cells/μL is normal)
- Further elevation may indicate infection requiring evaluation

**Older Adults:**
- Baseline WBC tends to decrease modestly with age
- Lower end of optimal range (4,000-5,000 cells/μL) may be appropriate
- Greater vulnerability to infections if count drops below 4,000 cells/μL

**Medications That Affect WBC:**
- Increase: Corticosteroids, lithium, epinephrine, G-CSF
- Decrease: Chemotherapy, antibiotics, antithyroid drugs, antipsychotics

**Testing Frequency:**
- Annual if stable and optimal
- Every 3-6 months if elevated and implementing interventions
- More frequent if very low or on medications affecting WBC"""},

            {"title": "The Bottom Line", "content": """White blood cell count is a powerful biomarker of immune function and inflammatory status—two critical determinants of how well you age. While conventional medicine views WBC count through the lens of diagnosing infections or blood disorders, the longevity perspective recognizes that even "normal" elevations predict accelerated aging and increased disease risk.

**Key Takeaways:**
- **Target 4,500-6,500 cells/μL** for optimal immune function with minimal inflammatory burden
- **Higher isn't better:** Counts above 7,000 cells/μL associate with increased mortality
- **Context matters:** Always interpret WBC alongside the differential
- **Modifiable factors:** Diet, weight, sleep, stress, and smoking significantly influence WBC count
- **Early indicator:** Changes in WBC can precede clinical disease

An optimized WBC count reflects the immune system sweet spot—vigilant enough to defend against threats but restrained enough to avoid the chronic inflammation that accelerates aging."""}
        ]
    }
}

def add_biomarker_education(cur, biomarker_name, sections_data):
    """Add education sections for a biomarker"""
    print(f"\nAdding {biomarker_name} education...")
    
    # Get biomarker ID
    cur.execute("SELECT id FROM biomarkers_base WHERE biomarker_name = %s", (biomarker_name,))
    result = cur.fetchone()
    if not result:
        print(f"  ⚠️  {biomarker_name} not found in biomarkers_base")
        return
    
    biomarker_id = result[0]
    
    # Insert sections
    for i, section in enumerate(sections_data, 1):
        cur.execute("""
            INSERT INTO biomarkers_education_sections (
                biomarker_id,
                section_title,
                section_content,
                display_order,
                is_active
            )
            VALUES (%s, %s, %s, %s, %s)
        """, (biomarker_id, section['title'], section['content'], i, True))
    
    print(f"  ✓ Added {len(sections_data)} sections")

def main():
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("BATCH 4: Adding Inflammation Markers Education")
        print("="*80)

        for biomarker_name, data in BIOMARKER_DATA.items():
            add_biomarker_education(cur, biomarker_name, data['sections'])

        conn.commit()
        print("\n✅ Batch 4 complete!")
        print(f"   Added education for {len(BIOMARKER_DATA)} biomarkers")

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
