-- =====================================================
-- BATCH 4: Inflammation Markers Education
-- Adding: WBC, Neutrophils, Lymphocytes, Eosinophils
-- =====================================================

-- =====================================================
-- 1. WHITE BLOOD CELL COUNT (WBC)
-- =====================================================

DO $$
DECLARE
    v_biomarker_id UUID;
BEGIN
    -- Get biomarker ID
    SELECT id INTO v_biomarker_id
    FROM biomarkers_base
    WHERE biomarker_name = 'WBC (White Blood Cell Count)';

    -- Section 1: Overview
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Overview',
'White blood cells (WBCs), or leukocytes, are the foundation of your immune system—your body's first responders to infection, inflammation, and tissue damage. Unlike red blood cells that carry oxygen, WBCs defend your body against bacteria, viruses, parasites, and other foreign invaders.

Your total WBC count reflects the combined number of all five types of white blood cells in your bloodstream: neutrophils, lymphocytes, monocytes, eosinophils, and basophils. Each type has specialized functions, from fighting bacterial infections to coordinating immune responses to managing allergic reactions.

A normal WBC count indicates your immune system is functioning properly—neither underactive (leaving you vulnerable to infections) nor overactive (causing chronic inflammation that accelerates aging). For longevity optimization, maintaining WBC count in the optimal range supports immune resilience while minimizing the inflammatory burden that drives age-related diseases.',
    1, true);

    -- Section 2: The Longevity Connection
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Longevity Connection',
'**Why WBC Count Matters for Healthy Aging:**

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
The "sweet spot" for longevity appears to be WBC counts in the 4,000-6,500 cells/μL range—high enough to maintain robust immune function but low enough to minimize chronic inflammation. This range supports effective pathogen defense while avoiding the accelerated aging associated with inflammatory excess.',
    2, true);

    -- Section 3: Optimal Ranges
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Optimal Ranges',
'**Standard Laboratory Reference Range:**
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
WBC count should always be interpreted alongside the differential (breakdown of WBC types). Two people with identical total WBC counts can have very different health implications depending on which cell types are elevated or decreased.',
    3, true);

    -- Section 4: Symptoms & Causes
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Symptoms & Causes',
'**Symptoms of Elevated WBC Count:**
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
- **Severe chronic stress:** Prolonged cortisol elevation can suppress production',
    4, true);

    -- Section 5: How to Optimize
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'How to Optimize',
'**To Lower Elevated WBC Count:**

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
- Medication side effects requiring adjustment',
    5, true);

    -- Section 6: Special Considerations
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Special Considerations',
'**When to Seek Immediate Medical Attention:**
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
- Always retest abnormal results to confirm',
    6, true);

    -- Section 7: The Bottom Line
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Bottom Line',
'White blood cell count is a powerful biomarker of immune function and inflammatory status—two critical determinants of how well you age. While conventional medicine views WBC count through the lens of diagnosing infections or blood disorders, the longevity perspective recognizes that even "normal" elevations predict accelerated aging and increased disease risk.

**Key Takeaways:**
- **Target 4,500-6,500 cells/μL** for optimal immune function with minimal inflammatory burden
- **Higher isn't better:** Counts above 7,000 cells/μL, though "normal," associate with increased mortality
- **Context matters:** Always interpret WBC alongside the differential to understand which cell types drive the total count
- **Modifiable factors:** Diet, weight, sleep, stress, and smoking significantly influence WBC count
- **Early indicator:** Changes in WBC can precede clinical disease, offering opportunity for early intervention

An optimized WBC count reflects the immune system sweet spot—vigilant enough to defend against threats but restrained enough to avoid the chronic inflammation that accelerates aging. This balance supports both healthspan and lifespan, allowing you to maintain vitality and resilience as you age.',
    7, true);

END $$;

-- =====================================================
-- 2. NEUTROPHILS (Absolute Count)
-- =====================================================

DO $$
DECLARE
    v_biomarker_id UUID;
BEGIN
    -- Get biomarker ID
    SELECT id INTO v_biomarker_id
    FROM biomarkers_base
    WHERE biomarker_name = 'Neutrophils (Absolute)';

    -- Section 1: Overview
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Overview',
'Neutrophils are your body's most abundant and fast-acting white blood cells, comprising 40-70% of your total WBC count. These frontline defenders are the first responders to bacterial infections and tissue injury, arriving within minutes to engulf and destroy invading pathogens through a process called phagocytosis.

Think of neutrophils as your immune system's special forces—rapidly deployed, highly effective, and programmed for short-term missions. They circulate in your bloodstream for only 5-90 hours before migrating to tissues or dying, requiring constant replenishment by your bone marrow.

Your absolute neutrophil count (ANC) measures the actual number of neutrophils per microliter of blood, providing crucial insight into your body's capacity to fight infections and your overall inflammatory status. While essential for defense against bacterial threats, chronically elevated neutrophils can indicate persistent inflammation that accelerates aging and increases disease risk.',
    1, true);

    -- Section 2: The Longevity Connection
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Longevity Connection',
'**Why Neutrophils Matter for Longevity:**

Neutrophil count sits at the intersection of immune defense and inflammatory aging. While adequate neutrophils are essential for fighting infections, elevated counts—even within the standard "normal" range—serve as a marker of chronic inflammation and predict adverse health outcomes.

**The Inflammation Connection:**
Research demonstrates that higher neutrophil counts associate with:
- **Cardiovascular disease:** Elevated neutrophils predict heart attack and stroke risk independent of other risk factors
- **Metabolic dysfunction:** Higher counts correlate with insulin resistance, metabolic syndrome, and type 2 diabetes
- **Cancer risk:** Chronic neutrophil elevation promotes tumor growth and metastasis through inflammatory signaling
- **Accelerated aging:** Neutrophils release reactive oxygen species that damage DNA and accelerate cellular aging

**The Neutrophil-to-Lymphocyte Ratio (NLR):**
The ratio of neutrophils to lymphocytes has emerged as a powerful predictor of mortality and disease. Higher NLR (typically above 2.5-3.0) indicates an inflammatory, immunosenescent state associated with:
- Increased all-cause mortality
- Greater frailty in older adults
- Poorer outcomes across multiple disease states
- Shorter healthspan and lifespan

**Optimal Range for Healthy Aging:**
For longevity optimization, the sweet spot appears to be absolute neutrophil counts of 2,500-4,500 cells/μL—adequate for robust antimicrobial defense but low enough to minimize chronic inflammatory signaling. Combined with optimal lymphocyte counts, this supports an NLR below 2.0, associated with healthy immune aging.',
    2, true);

    -- Section 3: Optimal Ranges
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Optimal Ranges',
'**Standard Laboratory Reference Range:**
- Normal: 1,500-8,000 cells/μL (or 40-70% of total WBC)

**Longevity-Optimized Range:**
- Optimal: 2,500-4,500 cells/μL
- Acceptable: 2,000-5,500 cells/μL
- Monitor closely: Below 2,000 or above 5,500 cells/μL

**Why Standard Labs Miss the Mark:**
Conventional ranges cast a wide net to avoid missing serious conditions like neutropenia (dangerously low counts). However, counts in the upper half of the "normal" range (above 5,500 cells/μL) often reflect chronic inflammation that silently accelerates aging.

**Understanding Your Results:**
- **2,500-4,500 cells/μL (Optimal):** Balanced immune readiness with minimal inflammatory burden
- **4,500-6,000 cells/μL (Elevated-Acceptable):** May reflect subclinical inflammation or recent immune activation
- **Above 6,000 cells/μL (High):** Suggests chronic inflammation, acute infection, or significant stress
- **1,500-2,000 cells/μL (Low-Acceptable):** May be normal for some individuals; monitor for infections
- **Below 1,500 cells/μL (Neutropenia):** Increased infection risk; requires medical evaluation

**Key Ratios to Monitor:**
- **Neutrophil-to-Lymphocyte Ratio (NLR):** Optimal below 2.0; concerning above 3.0
- **Neutrophil percentage:** Optimal 40-60% of total WBC count',
    3, true);

    -- Section 4: Symptoms & Causes
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Symptoms & Causes',
'**Symptoms of Elevated Neutrophils:**
Often asymptomatic when chronically elevated, but may include:
- Persistent fatigue despite adequate sleep
- Frequent minor infections or slow wound healing
- Joint pain or stiffness (inflammatory arthritis)
- Skin issues (acne, rashes, slow healing)
- Digestive discomfort or inflammatory bowel symptoms
- Fever and malaise (if acutely elevated from infection)

**Common Causes of Elevated Neutrophils:**
- **Chronic inflammation:** Obesity, metabolic syndrome, inflammatory diet (high processed foods, excess omega-6)
- **Acute bacterial infections:** Pneumonia, urinary tract infections, skin infections
- **Physical stress:** Intense exercise, surgery, trauma, burns
- **Smoking:** Directly stimulates neutrophil production and activation
- **Chronic diseases:** Rheumatoid arthritis, inflammatory bowel disease, chronic obstructive pulmonary disease
- **Medications:** Corticosteroids, lithium, G-CSF
- **Emotional stress:** Chronic psychological stress elevates inflammatory signaling

**Symptoms of Low Neutrophils (Neutropenia):**
- Frequent infections, especially bacterial (skin, respiratory, oral)
- Severe or unusual infections from normally harmless bacteria
- Fever without obvious source
- Mouth ulcers or gum inflammation
- Severe fatigue

**Common Causes of Low Neutrophils:**
- **Bone marrow disorders:** Aplastic anemia, myelodysplastic syndrome, leukemia
- **Nutritional deficiencies:** Vitamin B12, folate, copper
- **Autoimmune conditions:** Lupus, rheumatoid arthritis (Felty's syndrome)
- **Medications:** Chemotherapy, antibiotics (sulfonamides), antithyroid drugs, antipsychotics
- **Viral infections:** HIV, hepatitis, influenza, COVID-19
- **Chronic diseases:** Severe kidney disease, liver disease, hypersplenism
- **Genetic conditions:** Congenital neutropenia, cyclic neutropenia',
    4, true);

    -- Section 5: How to Optimize
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'How to Optimize',
'**To Lower Elevated Neutrophils:**

**1. Anti-Inflammatory Diet:**
- **Increase omega-3 fatty acids:** Fatty fish (salmon, sardines, mackerel) 3-4x weekly, or 2-3g EPA+DHA supplement daily
- **Polyphenol-rich foods:** Berries, green tea, extra virgin olive oil, dark chocolate (85%+ cacao)
- **Eliminate inflammatory triggers:** Processed foods, refined sugars, excess omega-6 vegetable oils
- **Adequate fiber:** 30-40g daily from vegetables, legumes, whole grains

**2. Lifestyle Interventions:**
- **Quit smoking:** Neutrophil counts typically normalize within weeks to months
- **Optimize sleep:** 7-9 hours nightly; poor sleep drives neutrophil elevation
- **Moderate exercise:** Regular moderate activity reduces inflammation; avoid chronic overtraining
- **Stress management:** Meditation, deep breathing, yoga reduce cortisol and inflammatory signaling
- **Weight optimization:** Even 5-10% weight loss significantly reduces neutrophil counts in overweight individuals

**3. Targeted Supplements:**
- **Curcumin:** 500-1,000 mg daily (with black pepper or lipidized form for absorption)
- **Omega-3s:** 2-4g EPA+DHA daily if diet insufficient
- **Vitamin D:** Maintain levels 40-60 ng/mL (typically requires 2,000-5,000 IU daily)
- **Probiotics:** Multi-strain formulation to support gut barrier and reduce systemic inflammation

**To Raise Low Neutrophils:**

**1. Address Nutritional Deficiencies:**
- **Vitamin B12:** 1,000 mcg daily if deficient (sublingual or injection for absorption issues)
- **Folate:** 400-800 mcg daily (methylfolate preferred)
- **Copper:** 1-2 mg daily (important for neutrophil maturation)
- **Zinc:** 15-30 mg daily (balance with copper)

**2. Support Bone Marrow:**
- **Adequate protein:** Minimum 0.8-1.0 g/kg body weight daily
- **Iron status:** Optimize if deficient, but avoid excess
- **Vitamin B6:** 25-50 mg daily for white blood cell production

**3. Avoid Suppressors:**
- **Limit alcohol:** Excessive intake suppresses bone marrow
- **Medication review:** Work with your doctor to identify drugs that may lower neutrophils
- **Avoid infections:** Practice good hygiene if counts are low

**4. Medical Evaluation:**
If neutrophils remain low (<1,500 cells/μL), work with a hematologist to evaluate for:
- Bone marrow disorders requiring treatment
- Autoimmune conditions
- Medication adjustments
- G-CSF therapy if severe (under medical supervision)',
    5, true);

    -- Section 6: Special Considerations
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Special Considerations',
'**When to Seek Immediate Medical Attention:**
- Neutrophil count below 1,000 cells/μL (severe neutropenia)
- Fever (>101°F) with neutropenia
- Severe infection with low neutrophils
- Rapid unexplained changes in neutrophil count

**Athletes and Exercise:**
- Intense training can elevate neutrophils for 24-48 hours post-exercise
- Chronic elevation may indicate overtraining or inadequate recovery
- Prolonged intense exercise temporarily suppresses neutrophil function despite elevated counts
- Schedule blood tests on rest days for accurate assessment

**Pregnancy:**
- Neutrophils naturally increase during pregnancy (up to 10,000-12,000 cells/μL normal)
- Labor and delivery cause sharp temporary spike
- Returns to baseline within weeks postpartum

**Older Adults:**
- Neutrophil counts tend to remain stable with age, unlike some other immune cells
- However, neutrophil function declines (reduced pathogen killing ability)
- Lower threshold for infection risk even with normal counts
- Monitor NLR closely as predictor of frailty and mortality

**Ethnic Variations:**
- Benign ethnic neutropenia (BEN): Some individuals of African, Middle Eastern, or West Indian descent have constitutionally lower neutrophil counts (1,200-1,500 cells/μL) without increased infection risk
- This is genetic and normal for these populations
- Should not be treated unless accompanied by recurrent infections

**Medications That Affect Neutrophils:**
- **Increase:** Corticosteroids, lithium, G-CSF/GM-CSF
- **Decrease:** Chemotherapy, antithyroid drugs (methimazole), antibiotics (trimethoprim-sulfamethoxazole), antipsychotics (clozapine)
- Inform healthcare providers of all medications when interpreting results

**Testing Frequency:**
- Annual if stable and optimal
- Every 3-6 months if elevated and implementing lifestyle interventions
- More frequent if low (<2,000 cells/μL) or on medications affecting neutrophils
- Retest abnormal results to confirm before making major interventions',
    6, true);

    -- Section 7: The Bottom Line
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Bottom Line',
'Neutrophils represent the delicate balance between immune readiness and inflammatory burden. While essential for fighting bacterial infections and healing injuries, chronically elevated neutrophils signal persistent inflammation that accelerates aging and disease risk.

**Key Takeaways:**
- **Target 2,500-4,500 cells/μL** for optimal balance between infection defense and minimal inflammation
- **Monitor your NLR:** Neutrophil-to-Lymphocyte Ratio below 2.0 is ideal for longevity
- **Higher isn't healthier:** Counts above 5,500 cells/μL predict increased cardiovascular, metabolic, and cancer risk
- **Lifestyle is powerful:** Diet, weight, sleep, stress, and smoking significantly influence neutrophil counts
- **Age matters:** While counts remain stable with age, neutrophil function declines, requiring greater attention to optimal ranges

An optimized neutrophil count reflects an immune system that's alert but not hypervigilant—ready to respond to threats without creating the chronic inflammatory state that undermines healthy aging. This balance is fundamental to maintaining both robust immunity and long-term vitality.',
    7, true);

END $$;

-- =====================================================
-- 3. LYMPHOCYTES (Absolute Count)
-- =====================================================

DO $$
DECLARE
    v_biomarker_id UUID;
BEGIN
    -- Get biomarker ID
    SELECT id INTO v_biomarker_id
    FROM biomarkers_base
    WHERE biomarker_name = 'Lymphocytes (Absolute)';

    -- Section 1: Overview
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Overview',
'Lymphocytes are the intelligence officers of your immune system, comprising 20-40% of your total white blood cells. Unlike neutrophils that provide rapid but nonspecific defense, lymphocytes orchestrate targeted, sophisticated immune responses with remarkable memory and precision.

There are three main types of lymphocytes, each with specialized functions:
- **T cells (70-80% of lymphocytes):** Coordinate immune responses, directly kill infected cells, and regulate immune activity
- **B cells (10-15%):** Produce antibodies that tag pathogens for destruction
- **Natural Killer (NK) cells (5-10%):** Destroy virus-infected cells and tumor cells without prior sensitization

Your absolute lymphocyte count (ALC) measures the total number of these cells per microliter of blood. This biomarker provides crucial insight into your adaptive immune function—your body's ability to remember past infections, mount effective responses to new threats, and maintain immune surveillance against cancer and chronic viral infections.

For longevity, optimal lymphocyte counts indicate robust adaptive immunity capable of providing long-term protection while maintaining immune balance.',
    1, true);

    -- Section 2: The Longevity Connection
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Longevity Connection',
'**Why Lymphocytes Matter for Healthy Aging:**

Lymphocyte count and function are central to immune competence and healthy aging. As we age, the immune system undergoes a process called immunosenescence—a gradual decline in immune function that increases vulnerability to infections, cancer, and autoimmune conditions.

**The Immune Aging Paradox:**
Unlike neutrophils (where higher is generally worse for longevity), lymphocyte relationships with aging are more nuanced:
- **Lymphopenia (low counts):** Associated with increased mortality, greater infection risk, and poorer response to vaccinations
- **Very high counts:** May indicate chronic viral infections, autoimmune activation, or blood cancers
- **Optimal range:** Maintains robust adaptive immunity and favorable neutrophil-to-lymphocyte ratio

**The Neutrophil-to-Lymphocyte Ratio (NLR) Story:**
The ratio of neutrophils to lymphocytes has emerged as one of the most powerful predictors of biological aging and longevity:
- **NLR below 2.0:** Associated with healthier aging, lower mortality, reduced frailty
- **NLR above 3.0:** Predicts increased mortality, cardiovascular events, and poor disease outcomes across multiple conditions

Higher lymphocyte counts (in the optimal range) help maintain a favorable NLR by balancing neutrophil-driven inflammation with adaptive immune competence.

**Cancer Surveillance:**
Natural Killer (NK) cells and cytotoxic T cells continuously patrol your body, identifying and destroying abnormal cells before they become tumors. Adequate lymphocyte counts and function are essential for this cancer immunosurveillance. Studies show that individuals with higher lymphocyte counts within the optimal range have reduced cancer incidence.

**Optimal Range for Longevity:**
Research suggests absolute lymphocyte counts of 1,500-3,000 cells/μL support robust adaptive immunity, favorable inflammatory balance, and effective cancer surveillance—all key components of healthy aging.',
    2, true);

    -- Section 3: Optimal Ranges
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Optimal Ranges',
'**Standard Laboratory Reference Range:**
- Normal: 1,000-4,800 cells/μL (or 20-40% of total WBC)

**Longevity-Optimized Range:**
- Optimal: 1,500-3,000 cells/μL
- Acceptable: 1,200-3,500 cells/μL
- Monitor closely: Below 1,200 or above 3,500 cells/μL

**Why Standard Labs Miss the Mark:**
Conventional ranges are designed to catch severe lymphopenia (which increases infection risk) or lymphocytosis (which might indicate leukemia). However, subtle variations within the "normal" range significantly impact immune competence and longevity.

**Understanding Your Results:**
- **1,500-3,000 cells/μL (Optimal):** Robust adaptive immunity with optimal NLR
- **1,200-1,500 cells/μL (Low-Acceptable):** May be adequate but worth optimizing
- **Below 1,200 cells/μL (Lymphopenia):** Increased infection risk; impaired vaccine responses; evaluate for causes
- **3,000-4,000 cells/μL (Elevated-Acceptable):** Generally healthy; may reflect recent infection or vaccination
- **Above 4,000 cells/μL (Lymphocytosis):** Warrants evaluation for chronic infection, autoimmune disease, or lymphoproliferative disorder

**Key Ratios to Monitor:**
- **Neutrophil-to-Lymphocyte Ratio (NLR):** Optimal below 2.0; concerning above 3.0
- **Lymphocyte percentage:** Optimal 25-35% of total WBC count
- **CD4:CD8 ratio:** If tested, optimal 1.0-2.5 (measures T cell balance)',
    3, true);

    -- Section 4: Symptoms & Causes
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Symptoms & Causes',
'**Symptoms of Low Lymphocytes (Lymphopenia):**
Often asymptomatic initially, but increasing vulnerability manifests as:
- Frequent or prolonged viral infections (colds, flu, respiratory infections)
- Recurrent or severe herpes virus reactivations (cold sores, shingles)
- Slow recovery from infections
- Poor response to vaccinations
- Unusual or opportunistic infections
- Chronic fatigue and low vitality
- Increased susceptibility to cancer (with prolonged lymphopenia)

**Common Causes of Lymphopenia:**
- **Aging (immunosenescence):** Natural decline in lymphocyte production and function
- **Nutritional deficiencies:** Protein, zinc, vitamin D, vitamin B6
- **Chronic stress:** Sustained cortisol elevation depletes lymphocytes
- **Autoimmune diseases:** Lupus, rheumatoid arthritis, multiple sclerosis
- **Viral infections:** HIV, hepatitis, influenza, COVID-19 (acute and long COVID)
- **Medications:** Corticosteroids, chemotherapy, immunosuppressants
- **Bone marrow disorders:** Aplastic anemia, myelodysplastic syndrome
- **Chronic diseases:** Kidney failure, liver cirrhosis, heart failure
- **Excessive alcohol use:** Suppresses lymphocyte production and function
- **Radiation exposure:** Even low-dose chronic exposure
- **Overtraining syndrome:** Chronic intense exercise without adequate recovery

**Symptoms of Elevated Lymphocytes (Lymphocytosis):**
Often asymptomatic, but may include:
- Fatigue and malaise
- Enlarged lymph nodes
- Fever and night sweats
- Unintentional weight loss
- Abdominal discomfort (enlarged spleen)

**Common Causes of Elevated Lymphocytes:**
- **Acute viral infections:** Infectious mononucleosis (Epstein-Barr virus), cytomegalovirus, whooping cough
- **Chronic viral infections:** HIV, hepatitis, CMV
- **Autoimmune conditions:** Rheumatoid arthritis, thyroiditis
- **Chronic lymphocytic leukemia (CLL):** Most common leukemia in adults; often discovered incidentally
- **Other lymphoproliferative disorders:** Non-Hodgkin's lymphoma
- **Smoking:** Can cause persistent moderate elevation
- **Recent vaccination:** Temporary elevation is normal
- **Hyperthyroidism:** Overactive thyroid increases lymphocyte production',
    4, true);

    -- Section 5: How to Optimize
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'How to Optimize',
'**To Raise Low Lymphocytes:**

**1. Nutritional Support:**
- **Adequate protein:** 0.8-1.2 g/kg body weight daily (higher for older adults and athletes)
- **Zinc:** 15-30 mg daily; critical for T cell development and function
- **Vitamin D:** Maintain levels 40-60 ng/mL (typically 2,000-5,000 IU daily); essential for lymphocyte development
- **Vitamin B6:** 25-50 mg daily; required for lymphocyte proliferation
- **Vitamin A:** 5,000-10,000 IU daily; supports mucosal immunity and T cell function
- **Selenium:** 200 mcg daily; enhances NK cell activity
- **Omega-3 fatty acids:** 2-3g EPA+DHA daily; supports lymphocyte membrane function

**2. Lifestyle Optimization:**
- **Quality sleep:** 7-9 hours nightly; lymphocyte production peaks during deep sleep
- **Stress management:** Chronic stress depletes lymphocytes through sustained cortisol elevation
  - Meditation, deep breathing, yoga proven to increase lymphocyte counts
  - Social connection and purpose boost immune function
- **Moderate regular exercise:** 30-45 minutes of moderate activity 5x weekly increases lymphocyte circulation
  - Avoid chronic overtraining which suppresses counts
- **Avoid immune suppressors:** Excessive alcohol, smoking, chronic sleep deprivation
- **Optimize body composition:** Both obesity and excessive leanness impair lymphocyte function

**3. Targeted Interventions:**
- **Probiotics:** Multi-strain formulation (at least 10 billion CFU daily); gut microbiome strongly influences lymphocyte development
- **Medicinal mushrooms:** Reishi, maitake, or turkey tail (follow product recommendations); enhance NK cell activity
- **Astragalus:** 500-1,000 mg daily; traditional herb shown to increase lymphocyte counts
- **Curcumin:** 500-1,000 mg daily; modulates T cell function

**4. Address Underlying Causes:**
- **Chronic stress:** Psychological intervention, adaptogenic herbs (ashwagandha, rhodiola)
- **Chronic infections:** Work with physician to identify and treat (e.g., EBV, CMV, hepatitis)
- **Autoimmune conditions:** Appropriate medical management
- **Medication review:** Discuss with doctor whether immunosuppressive medications can be adjusted

**For Elevated Lymphocytes:**

**1. Determine the Cause:**
- **Acute infection:** Usually self-resolves; focus on rest, hydration, nutrition
- **Chronic infection or autoimmune disease:** Requires medical diagnosis and treatment
- **Lymphoproliferative disorder:** If persistently >4,000 cells/μL, see hematologist for evaluation

**2. General Health Support:**
- Anti-inflammatory diet with focus on polyphenols and omega-3s
- Stress reduction and adequate sleep
- Avoid smoking and excessive alcohol
- No specific interventions to lower lymphocytes unless underlying pathology identified',
    5, true);

    -- Section 6: Special Considerations
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Special Considerations',
'**When to Seek Medical Attention:**
- Lymphocyte count below 1,000 cells/μL
- Persistent elevation above 4,000 cells/μL without obvious cause (e.g., recent infection)
- Lymphocytosis with concerning symptoms: unexplained weight loss, night sweats, enlarged lymph nodes, persistent fatigue
- Recurrent or severe infections with low counts

**Athletes and Exercise:**
- Moderate regular exercise boosts lymphocyte counts and function
- Intense acute exercise temporarily depletes circulating lymphocytes (they migrate to tissues)
- Chronic overtraining suppresses lymphocyte counts and impairs function
- "Open window" period of increased infection susceptibility 3-72 hours post-intense exercise
- Adequate recovery, nutrition, and sleep essential to maintain optimal counts

**Pregnancy:**
- Lymphocyte counts may slightly decrease during pregnancy (immune system shifts to prevent fetal rejection)
- This is normal and protective; counts return to baseline postpartum
- More vulnerable to certain infections during pregnancy; optimize prenatal nutrition

**Older Adults:**
- Lymphocyte counts tend to decline modestly with age (immunosenescence)
- Greater emphasis on maintaining counts at higher end of optimal range (2,000-3,000 cells/μL)
- Lymphocyte function declines more than count (reduced diversity, impaired activation)
- Strategies to slow immunosenescence:
  - Optimize vitamin D and zinc status
  - Regular moderate exercise
  - Stress management and social engagement
  - Consider thymus-supporting supplements (zinc, vitamin A)
  - Maintain healthy weight

**Medications That Affect Lymphocytes:**
- **Decrease:** Corticosteroids (most significant), chemotherapy, immunosuppressants (cyclosporine, tacrolimus), some antivirals
- **Increase:** Lithium, growth factors (G-CSF can indirectly affect), some antibiotics during infection recovery
- Chronic medication effects: Inform healthcare provider when interpreting results

**Vaccinations:**
- Expect temporary lymphocyte increase 7-14 days post-vaccination (normal immune response)
- Schedule testing before vaccination or >4 weeks after for baseline assessment
- Lymphopenia may impair vaccine response; consider checking antibody titers if counts low

**Chronic Viral Infections:**
- Persistent low lymphocytes may indicate chronic viral suppression (HIV, hepatitis, CMV, EBV)
- Testing for these infections appropriate if counts remain low without obvious cause
- Reactivation of latent viruses (HSV, VZV, EBV) more common with low counts

**Testing Frequency:**
- Annual if stable and optimal
- Every 3-6 months if low (<1,500 cells/μL) and implementing optimization strategies
- Every 3-6 months if elevated (>4,000 cells/μL) until cause identified
- More frequent if on immunosuppressive medications
- Always retest abnormal results before major interventions',
    6, true);

    -- Section 7: The Bottom Line
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Bottom Line',
'Lymphocytes are the guardians of long-term immune competence—your body's capacity to remember past threats, mount effective responses to new challenges, and maintain continuous surveillance against cancer and chronic infections. Unlike the inflammatory burden associated with elevated neutrophils, healthy lymphocyte counts within the optimal range support longevity.

**Key Takeaways:**
- **Target 1,500-3,000 cells/μL** for robust adaptive immunity and optimal NLR
- **Higher is often better (within reason):** Adequate lymphocytes protect against infections, support cancer surveillance, and balance inflammatory signaling
- **Monitor your NLR:** Lymphocytes play the denominator role; optimal counts help maintain NLR below 2.0
- **Lifestyle profoundly impacts counts:** Sleep, stress, nutrition, and exercise significantly influence lymphocyte production and function
- **Age requires vigilance:** Natural decline with aging makes optimization strategies increasingly important

Optimal lymphocyte counts reflect an adaptive immune system that's competent, balanced, and resilient—capable of defending against diverse threats while maintaining the immunological memory that protects you throughout life. This immune competence is fundamental to healthy aging and longevity.',
    7, true);

END $$;

-- =====================================================
-- 4. EOSINOPHILS (Absolute Count)
-- =====================================================

DO $$
DECLARE
    v_biomarker_id UUID;
BEGIN
    -- Get biomarker ID
    SELECT id INTO v_biomarker_id
    FROM biomarkers_base
    WHERE biomarker_name = 'Eosinophils (Absolute)';

    -- Section 1: Overview
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Overview',
'Eosinophils are specialized white blood cells that play a critical role in defending against parasitic infections and modulating allergic and inflammatory responses. Though they comprise only 1-6% of your total white blood cell count, these cells pack powerful inflammatory mediators that can both protect and—when dysregulated—cause significant tissue damage.

Named for their distinctive appearance under a microscope (they turn bright pink/red when stained with eosin dye), these cells contain granules filled with toxic proteins designed to destroy large parasites that other immune cells can't engulf. Beyond parasite defense, eosinophils regulate allergic inflammation, respond to certain infections, and can contribute to tissue remodeling and fibrosis.

Your absolute eosinophil count (AEC) measures the actual number of eosinophils per microliter of blood. While some eosinophils are essential for immune function, elevated counts often indicate allergic conditions, parasitic infections, or inflammatory disorders. For longevity optimization, maintaining eosinophils in the lower end of the normal range suggests minimal allergic or inflammatory burden.',
    1, true);

    -- Section 2: The Longevity Connection
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Longevity Connection',
'**Why Eosinophils Matter for Healthy Aging:**

While less studied than neutrophils or lymphocytes in the context of longevity, eosinophil counts provide valuable insight into allergic burden and certain inflammatory conditions that impact healthspan.

**The Allergy-Inflammation Connection:**
Chronically elevated eosinophils most commonly reflect allergic conditions or atopic diseases:
- **Asthma:** Eosinophilic airway inflammation contributes to remodeling and progressive lung function decline
- **Allergic rhinitis and sinusitis:** Chronic nasal/sinus inflammation driven by eosinophils
- **Atopic dermatitis (eczema):** Eosinophils contribute to skin barrier dysfunction and chronic inflammation
- **Food allergies and eosinophilic esophagitis:** Gastrointestinal eosinophilia causes chronic digestive issues

These conditions create persistent low-grade inflammation that, while more localized than systemic metabolic inflammation, still extracts a toll on healthspan through:
- Reduced quality of life from chronic symptoms
- Sleep disruption (from allergies, asthma)
- Medication side effects (chronic steroid use)
- Progressive organ dysfunction (lung remodeling, gastrointestinal strictures)

**The Tissue Damage Paradox:**
Eosinophils release highly toxic proteins (major basic protein, eosinophil peroxidase) designed to kill parasites. In allergic and inflammatory conditions, these same proteins damage host tissues, leading to:
- Airway remodeling in asthma
- Gastrointestinal strictures in eosinophilic disorders
- Cardiac damage in hypereosinophilic syndromes
- Skin barrier dysfunction in atopic dermatitis

**Optimal Range for Longevity:**
For longevity optimization, eosinophil counts in the 0-200 cells/μL range suggest minimal allergic and parasitic burden. While higher counts within the normal range (up to 500 cells/μL) aren't necessarily pathological, they often indicate subclinical allergic or inflammatory processes worth addressing.',
    2, true);

    -- Section 3: Optimal Ranges
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Optimal Ranges',
'**Standard Laboratory Reference Range:**
- Normal: 0-500 cells/μL (or 1-6% of total WBC)

**Longevity-Optimized Range:**
- Optimal: 0-200 cells/μL
- Acceptable: 0-350 cells/μL
- Monitor closely: Above 350 cells/μL

**Why Standard Labs Miss the Mark:**
Conventional ranges define eosinophilia (elevated eosinophils) as counts above 500 cells/μL. However, even "high-normal" counts (350-500 cells/μL) may reflect significant allergic burden worth addressing for optimal health.

**Understanding Your Results:**
- **0-200 cells/μL (Optimal):** Minimal allergic or parasitic burden
- **200-500 cells/μL (High-Normal):** May indicate:
  - Mild seasonal allergies
  - Subclinical food sensitivities
  - Minimal parasitic exposure
  - Skin conditions (mild eczema)
- **500-1,500 cells/μL (Mild Eosinophilia):** Warrants evaluation for:
  - Allergic conditions (asthma, rhinitis)
  - Parasitic infection
  - Certain medications
  - Skin conditions
- **1,500-5,000 cells/μL (Moderate Eosinophilia):** Requires medical evaluation
- **Above 5,000 cells/μL (Severe Eosinophilia):** Urgent medical evaluation for:
  - Hypereosinophilic syndrome
  - Certain blood cancers
  - Drug reactions
  - Severe parasitic infections

**Important Note:**
Zero eosinophils (or very low counts) is generally considered normal and not a cause for concern. Unlike other white blood cell types, you don't need a minimum number of circulating eosinophils for health.',
    3, true);

    -- Section 4: Symptoms & Causes
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Symptoms & Causes',
'**Symptoms of Elevated Eosinophils:**
Symptoms depend on the underlying cause and degree of elevation:

**Mild Elevation (500-1,500 cells/μL):**
- Seasonal allergy symptoms (sneezing, runny nose, itchy eyes)
- Mild asthma symptoms (occasional wheeze, cough)
- Skin rashes or itching
- Often asymptomatic

**Moderate to Severe Elevation (>1,500 cells/μL):**
- Persistent respiratory symptoms (cough, wheeze, shortness of breath)
- Digestive issues (abdominal pain, nausea, diarrhea)
- Skin problems (severe eczema, hives, rashes)
- Fatigue and malaise
- Fever (if infection or inflammatory condition)
- Muscle pain and joint pain

**Severe Eosinophilia (>5,000 cells/μL):**
Can cause organ damage from eosinophil infiltration and toxic protein release

**Common Causes of Elevated Eosinophils:**

**Allergic Conditions (Most Common):**
- Asthma (especially allergic asthma)
- Allergic rhinitis (hay fever)
- Atopic dermatitis (eczema)
- Food allergies
- Eosinophilic esophagitis or gastroenteritis
- Drug allergies

**Parasitic Infections:**
- Intestinal parasites (hookworm, roundworm, tapeworm)
- Tissue parasites (toxocara, trichinella)
- More common with international travel or certain dietary practices (raw/undercooked meat)

**Medications:**
- Antibiotics (penicillins, cephalosporins)
- NSAIDs (ibuprofen, naproxen)
- Anticonvulsants
- Allopurinol
- Many others

**Autoimmune and Inflammatory Conditions:**
- Vasculitis (Churg-Strauss syndrome)
- Inflammatory bowel disease (Crohn's, ulcerative colitis)
- Rheumatoid arthritis
- Sarcoidosis

**Blood Disorders:**
- Hypereosinophilic syndrome
- Eosinophilic leukemia (rare)
- Lymphomas
- Myeloproliferative disorders

**Other:**
- Adrenal insufficiency (Addison's disease)
- Chronic kidney disease (during dialysis)
- Certain cancers
- Radiation exposure

**Low or Zero Eosinophils:**
- Generally not clinically significant
- May occur during acute stress or Cushing's syndrome
- Can occur with corticosteroid use
- Does not typically require treatment',
    4, true);

    -- Section 5: How to Optimize
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'How to Optimize',
'**To Lower Elevated Eosinophils:**

**1. Identify and Address Root Causes:**

**For Allergic Conditions:**
- **Allergy testing:** Identify specific allergens (environmental, food)
- **Environmental control:**
  - HEPA air filters for indoor allergens
  - Dust mite covers for bedding
  - Remove mold sources
  - Minimize pet dander exposure if allergic
- **Dietary modifications:** Eliminate confirmed food allergens or sensitivities
- **Consider immunotherapy:** Allergy shots or sublingual tablets for persistent environmental allergies

**For Parasitic Infections:**
- **Stool testing:** Comprehensive parasitology exam (may need multiple samples)
- **Anti-parasitic treatment:** If parasites identified, appropriate medical treatment
- **Prevention:** Properly cook meat; wash produce; practice good hygiene; careful with water sources when traveling

**2. Anti-Inflammatory Diet:**
- **Omega-3 fatty acids:** 2-4g EPA+DHA daily; reduces eosinophil activation and allergic responses
- **Quercetin:** 500-1,000 mg daily; natural antihistamine and mast cell stabilizer
- **Vitamin C:** 1,000-2,000 mg daily; antihistamine effects
- **Eliminate common allergens:** Consider trial elimination of dairy, gluten, eggs if elevated without clear cause
- **Increase flavonoids:** Berries, green tea, apples; modulate allergic responses

**3. Targeted Supplements:**
- **Vitamin D:** Maintain 40-60 ng/mL; regulates immune tolerance and reduces allergic sensitization
- **Probiotics:** Multi-strain formulation; supports gut barrier and reduces systemic allergic responses
- **Stinging nettle:** 300-600 mg daily; natural antihistamine
- **Butterbur:** 75 mg twice daily; effective for allergic rhinitis (use PA-free formulations only)
- **Bromelain:** 500-1,000 mg between meals; anti-inflammatory enzyme

**4. Lifestyle Interventions:**
- **Stress management:** Chronic stress exacerbates allergic responses
- **Quality sleep:** Poor sleep worsens allergic symptoms and eosinophil activation
- **Nasal rinsing:** Saline irrigation reduces allergen load and symptoms
- **Skin barrier support:** For eczema, consistent moisturizing and avoiding irritants

**5. Medical Interventions (When Appropriate):**
- **Antihistamines:** For symptomatic allergies
- **Nasal corticosteroids:** For allergic rhinitis; minimal systemic absorption
- **Inhaled corticosteroids:** For asthma control; essential to prevent long-term lung damage
- **Leukotriene inhibitors:** (montelukast) for asthma and allergies
- **Biologics:** For severe eosinophilic asthma or conditions (omalizumab, mepolizumab, others)

**6. Monitor and Adjust:**
- Recheck eosinophil count after 3-6 months of interventions
- Track symptoms alongside laboratory values
- Adjust strategies based on response',
    5, true);

    -- Section 6: Special Considerations
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'Special Considerations',
'**When to Seek Medical Attention:**
- Eosinophil count above 1,500 cells/μL without obvious cause
- Count above 5,000 cells/μL (urgent evaluation)
- Elevated eosinophils with concerning symptoms:
  - Severe abdominal pain
  - Persistent fever
  - Difficulty breathing
  - Chest pain
  - Neurological symptoms
  - Severe skin rashes
- Rapidly rising eosinophil counts on serial testing

**Athletes:**
- Exercise generally doesn't significantly affect eosinophil counts
- Chronic overtraining may suppress counts (like other immune cells)
- Some endurance athletes with asthma have elevated eosinophils
- Eosinophilic airway inflammation can limit performance; worth treating

**Seasonal Variations:**
- Eosinophils often fluctuate with seasonal allergen exposure
- Spring (tree pollen) and fall (ragweed) peaks common
- May be elevated 1-2 months per year in seasonal allergy sufferers
- Consistent elevation outside allergy season warrants investigation

**Geographic Considerations:**
- Higher prevalence of parasitic infections in certain regions
- International travelers may acquire parasites
- Consider parasitic testing if:
  - Recent travel to endemic areas
  - Unexplained eosinophilia
  - Digestive symptoms

**Children:**
- Eosinophilia more common in children due to higher rates of allergies and parasitic infections
- Reference ranges similar to adults
- Atopic conditions (asthma, eczema, allergies) often begin in childhood
- Early intervention may prevent progression

**Pregnancy:**
- Eosinophil counts typically remain stable during pregnancy
- Elevation may indicate:
  - Pre-existing allergic conditions
  - Parasitic infection
  - Drug reaction
- Safe to treat allergic conditions during pregnancy with appropriate medications

**Medications That Affect Eosinophils:**
- **Increase:** Many drugs can cause eosinophilia (see Causes section)
- **Decrease:** Corticosteroids dramatically lower eosinophil counts (often to near-zero)
- **Timing:** Drug-induced eosinophilia typically develops weeks to months after starting medication

**Asthma Monitoring:**
- Eosinophil count used to phenotype asthma (eosinophilic vs. non-eosinophilic)
- Higher counts indicate greater response to:
  - Inhaled corticosteroids
  - Biologic therapies targeting eosinophils
- Persistently elevated despite treatment may indicate:
  - Poor medication adherence
  - Inadequate dosing
  - Need for additional therapies

**Testing Frequency:**
- Annual if normal and asymptomatic
- Every 3-6 months if elevated and implementing interventions
- More frequent if:
  - Significantly elevated (>1,000 cells/μL)
  - On treatment for eosinophilic condition
  - Monitoring for medication-induced eosinophilia
- Always retest abnormal results before major interventions',
    6, true);

    -- Section 7: The Bottom Line
    INSERT INTO biomarkers_education_sections (biomarker_id, section_title, section_content, display_order, is_active)
    VALUES (v_biomarker_id, 'The Bottom Line',
'Eosinophils serve as a sensitive marker of allergic burden and certain inflammatory conditions. While not as strongly linked to longevity as other WBC subtypes, elevated eosinophils indicate immune dysregulation that can compromise healthspan through chronic symptoms, medication side effects, and progressive organ dysfunction.

**Key Takeaways:**
- **Target 0-200 cells/μL** for minimal allergic and inflammatory burden
- **Higher indicates allergic activation:** Most common cause is allergic conditions (asthma, rhinitis, eczema, food allergies)
- **Parasites matter:** Don't overlook parasitic causes, especially with travel history or gastrointestinal symptoms
- **Medications are common culprits:** Many drugs can cause eosinophilia
- **Severe elevation requires urgent evaluation:** Counts above 5,000 cells/μL can cause organ damage
- **Zero is okay:** Unlike other WBC types, very low or zero eosinophils is generally not concerning

Optimizing eosinophil counts reflects addressing the root causes of allergic and inflammatory conditions—reducing allergen exposure, healing gut barriers, eliminating parasites, and modulating immune responses. This optimization reduces the chronic inflammatory burden that, while often localized, still extracts a toll on overall health and vitality. An eosinophil count in the optimal range suggests your immune system is balanced and not wasting resources fighting unnecessary battles.',
    7, true);

END $$;

SELECT '✅ Batch 4 inflammation markers education complete' as status;
