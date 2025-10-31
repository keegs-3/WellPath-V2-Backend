-- Add comprehensive education content for Batch 2 biomarkers
-- Homocysteine, Ferritin, Hemoglobin, AST

-- Homocysteine
UPDATE biomarkers_base
SET
    education = '**Understanding Homocysteine**

Homocysteine is an amino acid byproduct of methionine metabolism. Elevated levels are a powerful independent risk factor for cardiovascular disease, stroke, dementia, and all-cause mortality.

**The Longevity Connection:**
- Elevated homocysteine increases stroke risk 2-3 fold
- Each 5 μmol/L increase raises cardiovascular disease risk 20-30%
- Strong predictor of Alzheimer''s disease and cognitive decline
- Homocysteine >15 μmol/L associated with 50-70% increased all-cause mortality
- High homocysteine damages blood vessels, promotes thrombosis, causes neurotoxicity

**Optimal Ranges:**
- **Optimal for longevity**: <7-10 μmol/L
- **Standard lab reference**: <15 μmol/L (too permissive)
- **Elevated**: 15-30 μmol/L
- **High**: >30 μmol/L

**Why It Matters:**
Homocysteine is generated when methionine (an essential amino acid from protein) is broken down. To recycle it back to methionine or convert it to cysteine, your body needs adequate B vitamins (folate, B12, B6). When these are deficient, homocysteine builds up.

Elevated homocysteine:
- Damages endothelial lining of blood vessels
- Promotes atherosclerosis and thrombosis
- Increases oxidative stress and inflammation
- Neurotoxic - linked to Alzheimer''s, cognitive decline, depression
- Predicts cardiovascular events independent of cholesterol

**Causes of Elevated Homocysteine:**
1. **B vitamin deficiencies** (most common): Low folate, B12, or B6
2. **MTHFR gene variants**: Reduce folate metabolism efficiency (10-20% of population)
3. **Kidney disease**: Impaired clearance
4. **Medications**: Metformin, PPIs, some epilepsy drugs
5. **Lifestyle**: High protein intake, smoking, excess coffee/alcohol
6. **Age**: Homocysteine increases with age

**How to Lower Homocysteine:**

**1. B Vitamin Supplementation** (Most Effective)
- **Methylfolate** (active folate): 400-800mcg daily
  - More effective than folic acid, especially if MTHFR variant
- **Methylcobalamin** (active B12): 500-1000mcg daily
  - Sublingual or injectable for best absorption
- **Vitamin B6** (P-5-P form): 25-50mg daily
- Many see 25-50% reduction in homocysteine with B-complex supplementation

**2. Dietary Sources**
- **Folate-rich foods**: Leafy greens, lentils, beans, asparagus, avocados
- **B12-rich foods**: Meat, fish, eggs, dairy (vegans need to supplement)
- **B6-rich foods**: Chicken, fish, potatoes, bananas, chickpeas

**3. MTHFR Testing**
- If homocysteine remains elevated despite supplementation, test for MTHFR gene variants
- C677T and A1298C variants reduce folate metabolism 30-70%
- If positive: Use methylated B vitamins, higher doses of methylfolate (1-5mg)

**4. Lifestyle**
- Reduce alcohol and coffee intake (both increase homocysteine)
- Quit smoking
- Exercise regularly (improves B vitamin metabolism)
- Manage kidney health

**Monitoring:**
- Retest homocysteine 2-3 months after starting B vitamin supplementation
- Goal: Achieve <7-10 μmol/L
- Once stable, retest annually

**Special Considerations:**
- **Cardiovascular disease**: Target <8 μmol/L
- **Cognitive decline/dementia risk**: Target <10 μmol/L
- **Pregnancy**: Target <10 μmol/L (high homocysteine linked to complications)
- **Kidney disease**: May need higher B vitamin doses

**Medications (if applicable):**
- Most cases respond to B vitamin supplementation alone
- For severe elevation or kidney disease: High-dose B-complex under medical supervision

**The Bottom Line:**
Homocysteine is a powerful but modifiable risk factor. Target <7-10 μmol/L through B vitamin supplementation (methylfolate 400-800mcg + methylcobalamin 500-1000mcg + B6 25-50mg daily). If MTHFR variants, use methylated forms at higher doses. Extremely cost-effective longevity intervention.',
    recommendations_primary = COALESCE(recommendations_primary, 'Supplement methylfolate 400-800mcg + methylcobalamin 500-1000mcg + B6 25-50mg daily; consume folate-rich foods (leafy greens, lentils, beans); reduce alcohol/coffee; if MTHFR variant, use higher-dose methylated B vitamins'),
    therapeutics_primary = COALESCE(therapeutics_primary, 'High-dose B-complex with methylated forms; methylfolate 1000mcg + methylcobalamin 1000-5000mcg + P-5-P B6 50-100mg if MTHFR mutation or persistently elevated'),
    updated_at = NOW()
WHERE biomarker_name = 'Homocysteine'
  AND is_active = true;

-- Ferritin
UPDATE biomarkers_base
SET
    education = '**Understanding Ferritin**

Ferritin is your body''s iron storage protein. It''s the most sensitive marker of iron status and a key predictor of energy, athletic performance, and longevity.

**The Longevity Connection:**
- Both low and high ferritin associated with increased mortality
- **Low ferritin** (iron deficiency): Chronic fatigue, poor exercise capacity, cognitive impairment, weakened immunity
- **High ferritin** (iron overload): Increased oxidative stress, liver damage, diabetes risk, cardiovascular disease
- Optimal range for longevity: 50-150 ng/mL (men), 30-100 ng/mL (women)

**Optimal Ranges:**
- **Men Optimal**: 50-150 ng/mL
- **Women Optimal**: 30-100 ng/mL (higher in men due to lack of menstruation)
- **Athletes**: Target higher end (50-100 ng/mL for men, 30-80 ng/mL for women)
- **Standard lab "normal"**: 12-300 ng/mL (too wide - permits deficiency and overload)

**Low Ferritin (<30 ng/mL):**
Indicates iron deficiency, even if hemoglobin is normal.

**Symptoms of Low Ferritin:**
- Chronic fatigue, weakness
- Shortness of breath during exercise
- Poor exercise performance and recovery
- Hair loss
- Pale skin, brittle nails
- Restless legs syndrome
- Difficulty concentrating, brain fog
- Frequent infections (weakened immunity)

**Causes of Low Ferritin:**
- Insufficient dietary iron intake (especially vegetarians/vegans)
- Poor iron absorption (celiac, IBD, achlorhydria, PPI use)
- Blood loss (menstruation, GI bleeding, frequent blood donation)
- Pregnancy and breastfeeding (increased iron needs)
- Endurance athletes (increased losses through sweat, GI bleeding, hemolysis)

**How to Raise Ferritin:**

**1. Iron-Rich Diet**
- **Heme iron (best absorbed)**: Red meat, organ meats (liver), poultry, fish
  - 15-35% absorption rate
- **Non-heme iron (poorly absorbed)**: Beans, lentils, spinach, fortified grains
  - 2-20% absorption (improve with vitamin C)
- **Enhance absorption**: Pair with vitamin C (citrus, bell peppers, tomatoes)
- **Avoid inhibitors**: Coffee, tea, calcium, phytates (grains/legumes) block absorption

**2. Iron Supplementation**
- **Ferrous bisglycinate** (best tolerated): 25-50mg elemental iron daily
  - Take on empty stomach with vitamin C for best absorption
  - Less GI side effects than ferrous sulfate
- **Dosing**: 25mg daily if mildly low; 50-100mg if severely deficient
- **Timing**: Takes 2-3 months to replete iron stores
- **Retest**: Check ferritin every 2-3 months during repletion

**3. Address Underlying Causes**
- Treat GI conditions (celiac, IBD)
- Reduce PPI use if possible
- Investigate GI bleeding if unexplained iron loss
- Consider copper status (copper deficiency impairs iron utilization)

**High Ferritin (>200-300 ng/mL):**
Can indicate:
1. **Iron overload** (hemochromatosis, excessive supplementation)
2. **Inflammation** (ferritin is an acute phase reactant)
3. **Liver disease, metabolic syndrome**
4. **Chronic disease/infection**

**If Ferritin is High:**
- Check **transferrin saturation** to differentiate iron overload from inflammation
  - Transferrin saturation >45% → likely iron overload
  - Transferrin saturation <45% → likely inflammation (check hsCRP)
- If iron overload confirmed:
  - Stop all iron supplementation
  - Reduce red meat/organ meat intake
  - Consider phlebotomy (therapeutic blood donation) if genetic hemochromatosis
  - Test for HFE gene mutations
- If inflammation:
  - Treat underlying inflammatory condition
  - Reduce inflammatory foods (processed foods, sugar, trans fats)

**Monitoring:**
- Test ferritin annually (more often if supplementing or symptomatic)
- Pair with CBC (hemoglobin, MCV) and iron panel (serum iron, TIBC, transferrin saturation)
- Target: 50-150 ng/mL (men), 30-100 ng/mL (women)

**Special Considerations:**
- **Athletes**: Higher ferritin needs (target 50+ for optimal performance)
- **Women of reproductive age**: Monthly menstruation increases iron needs
- **Vegetarians/Vegans**: Higher risk of deficiency (supplement preventively)
- **Pregnant/breastfeeding**: Increased needs (30-60mg elemental iron daily)
- **Frequent blood donors**: Monitor ferritin regularly

**The Bottom Line:**
Ferritin is the most sensitive marker of iron status. Target 50-150 ng/mL (men) or 30-100 ng/mL (women) for optimal energy and performance. If low, supplement with ferrous bisglycinate 25-50mg daily and consume iron-rich foods (red meat, organ meats, with vitamin C). If high, differentiate iron overload from inflammation and treat accordingly.',
    recommendations_primary = COALESCE(recommendations_primary, 'Target 50-150 ng/mL (men) or 30-100 ng/mL (women); consume iron-rich foods (red meat, organ meats, seafood); pair with vitamin C to enhance absorption; avoid coffee/tea with meals; supplement ferrous bisglycinate 25-50mg daily if low'),
    therapeutics_primary = COALESCE(therapeutics_primary, 'Ferrous bisglycinate 25-50mg elemental iron daily (best tolerated); ferrous sulfate 325mg daily if severe deficiency; IV iron infusion if malabsorption or severe deficiency not responding to oral'),
    updated_at = NOW()
WHERE biomarker_name = 'Ferritin'
  AND is_active = true;

-- Hemoglobin
UPDATE biomarkers_base
SET
    education = '**Understanding Hemoglobin**

Hemoglobin (Hgb or Hb) is the iron-containing protein in red blood cells that carries oxygen from your lungs to tissues throughout your body. It''s a fundamental marker of oxygen-carrying capacity and overall health.

**The Longevity Connection:**
- Both low hemoglobin (anemia) and high hemoglobin (polycythemia) increase mortality risk
- **Anemia** linked to: Fatigue, poor cognitive function, heart strain, increased all-cause mortality
- **Polycythemia** linked to: Increased blood viscosity, clotting risk, stroke, cardiovascular disease
- Optimal hemoglobin associated with vitality, exercise capacity, cognitive function

**Optimal Ranges:**
- **Men Optimal**: 14-16 g/dL
- **Women Optimal**: 13-15 g/dL
- **Standard lab "normal"**: Men 13.5-17.5 g/dL, Women 12-16 g/dL
- **Anemia threshold**: <13 g/dL (men), <12 g/dL (women)
- **Polycythemia threshold**: >17 g/dL (men), >16 g/dL (women)

**Low Hemoglobin (Anemia):**

**Symptoms:**
- Chronic fatigue, weakness
- Shortness of breath, especially during exertion
- Dizziness, lightheadedness
- Pale skin, pale conjunctiva (inner eyelids)
- Rapid or irregular heartbeat
- Chest pain (in severe cases)
- Cold hands and feet
- Poor exercise performance
- Difficulty concentrating, brain fog

**Common Causes of Anemia:**
1. **Iron deficiency** (most common): Poor intake, blood loss, malabsorption
2. **Vitamin B12 or folate deficiency**: Macrocytic anemia (large red blood cells)
3. **Chronic disease**: Inflammation, kidney disease, cancer
4. **Bone marrow disorders**: Aplastic anemia, myelodysplastic syndrome
5. **Hemolysis**: Red blood cells destroyed prematurely (genetic or acquired)
6. **Blood loss**: Menstruation, GI bleeding, trauma

**Diagnosis of Anemia Cause:**
- Check **MCV** (mean corpuscular volume):
  - **Low MCV (<80 fL)**: Microcytic anemia → likely iron deficiency or thalassemia
  - **Normal MCV (80-100 fL)**: Normocytic anemia → likely chronic disease, kidney disease, or blood loss
  - **High MCV (>100 fL)**: Macrocytic anemia → likely B12 or folate deficiency, alcohol use
- Check **ferritin, iron panel**: Assess iron status
- Check **B12, folate**: If macrocytic
- Check **reticulocyte count**: Assesses bone marrow response
- Check **kidney function** (creatinine, eGFR) if chronic disease suspected

**How to Treat Anemia:**
**Depends on underlying cause:**

**1. Iron Deficiency Anemia:**
- Ferrous bisglycinate 25-50mg elemental iron daily
- Consume iron-rich foods (red meat, organ meats, seafood)
- Pair with vitamin C; avoid coffee/tea with meals
- Retest hemoglobin and ferritin in 2-3 months
- If severe or malabsorption: IV iron infusion

**2. B12/Folate Deficiency Anemia:**
- Methylcobalamin 1000mcg daily (sublingual or IM injection if severe)
- Methylfolate 400-800mcg daily
- Retest in 2-3 months

**3. Chronic Disease/Inflammation:**
- Treat underlying condition
- May require erythropoiesis-stimulating agents (ESAs) in some cases

**4. Kidney Disease:**
- Treat CKD, optimize nutrition
- May require ESAs (epoetin alfa, darbepoetin) + iron supplementation

**High Hemoglobin (Polycythemia):**

**Causes:**
1. **Dehydration** (most common, easily corrected)
2. **Chronic hypoxia**: Sleep apnea, COPD, high altitude, smoking
3. **Polycythemia vera**: Bone marrow disorder (overproduction of RBCs)
4. **Testosterone supplementation**: Increases RBC production
5. **EPO abuse**: Erythropoietin doping (athletes)

**Risks of High Hemoglobin:**
- Increased blood viscosity (thickness)
- Higher risk of blood clots, stroke, heart attack
- Headaches, dizziness, blurred vision
- Increased bleeding risk (paradoxically)

**Treatment for High Hemoglobin:**
- **Rehydrate** if dehydrated
- **Treat sleep apnea** if present
- **Stop smoking**
- **Reduce or adjust testosterone** if on TRT
- **Phlebotomy** (therapeutic blood donation) if polycythemia vera or symptomatic
  - Target: Hemoglobin <14 g/dL (men), <13 g/dL (women) if polycythemia vera
- **Aspirin** (low-dose 81mg daily) to reduce clotting risk

**Monitoring:**
- Test hemoglobin annually as part of CBC
- More frequent testing if anemic, on supplementation, or on testosterone
- Pair with MCV, ferritin, B12, folate for complete assessment

**Special Considerations:**
- **Athletes**: May have slightly lower hemoglobin due to "sports anemia" (dilutional, not true anemia)
- **High altitude**: Hemoglobin increases to compensate for lower oxygen
- **Smokers**: Often have elevated hemoglobin (chronic hypoxia from CO exposure)
- **Testosterone users**: Monitor hemoglobin regularly (target <17 g/dL)

**The Bottom Line:**
Hemoglobin is a core marker of oxygen delivery and vitality. Target 14-16 g/dL (men) or 13-15 g/dL (women). If low (anemic), determine cause (check MCV, ferritin, B12, folate) and treat accordingly with iron, B vitamins, or address underlying disease. If high, rule out dehydration, sleep apnea, smoking, or polycythemia vera.',
    recommendations_primary = COALESCE(recommendations_primary, 'Target 14-16 g/dL (men) or 13-15 g/dL (women); if anemic, determine cause (check MCV, ferritin, B12) and treat with iron or B vitamins; if elevated, hydrate, treat sleep apnea, stop smoking, or consider phlebotomy'),
    therapeutics_primary = COALESCE(therapeutics_primary, 'For iron deficiency anemia: Ferrous bisglycinate 25-50mg daily or IV iron; For B12/folate deficiency: Methylcobalamin 1000mcg + methylfolate 400-800mcg; For polycythemia: Phlebotomy, low-dose aspirin 81mg if clotting risk'),
    updated_at = NOW()
WHERE biomarker_name = 'Hemoglobin'
  AND is_active = true;

-- AST
UPDATE biomarkers_base
SET
    education = '**Understanding AST (Aspartate Aminotransferase)**

AST is an enzyme found in high concentrations in the liver, heart, muscle, kidneys, and brain. Elevated AST most commonly indicates liver or muscle damage.

**The Longevity Connection:**
- Elevated AST (especially if liver-related) linked to increased mortality from liver disease, cardiovascular disease
- Non-alcoholic fatty liver disease (NAFLD) strongly predicts metabolic syndrome, diabetes, cardiovascular disease
- Optimal liver enzyme levels associated with better metabolic health and longevity

**Optimal Ranges:**
- **Optimal for longevity**: <20-25 U/L
- **Standard lab "normal"**: <40 U/L (too permissive)
- **Mildly elevated**: 25-40 U/L (often fatty liver or muscle-related)
- **Moderately elevated**: 40-100 U/L (investigate liver disease)
- **Severely elevated**: >100 U/L (acute liver injury, hepatitis, muscle breakdown)

**AST vs. ALT:**
- **ALT** is more liver-specific
- **AST** can come from liver OR muscle (less specific)
- **AST/ALT ratio** helps differentiate:
  - **AST/ALT <1** (ALT > AST): Typical of fatty liver disease (NAFLD)
  - **AST/ALT >1** (AST > ALT): Suggests alcohol-related liver disease or cirrhosis
  - **AST/ALT >2**: Strongly suggests alcoholic hepatitis or advanced liver disease

**Common Causes of Elevated AST:**

**1. Liver Conditions:**
- **Non-alcoholic fatty liver disease (NAFLD)** (most common in US)
  - Driven by obesity, insulin resistance, metabolic syndrome
- **Alcoholic liver disease**
- **Viral hepatitis** (Hep B, Hep C)
- **Medication-induced hepatotoxicity**: Statins, acetaminophen, antibiotics, NSAIDs
- **Cirrhosis, fibrosis**

**2. Muscle Damage:**
- **Intense exercise**: Heavy weight training, rhabdomyolysis
- **Muscle injury, trauma**
- **Statin-induced myopathy**

**3. Other:**
- **Heart attack** (AST released from damaged heart muscle)
- **Hemolysis** (red blood cell breakdown)
- **Kidney disease**

**How to Determine If AST Elevation is Liver vs. Muscle:**
- Check **ALT** (more liver-specific):
  - If both AST and ALT elevated → likely liver
  - If AST elevated but ALT normal → likely muscle
- Check **CK (creatine kinase)**:
  - If CK elevated → muscle damage
- Check **GGT (gamma-glutamyl transferase)**:
  - If GGT elevated → liver (alcohol-related or bile duct issue)
- Check **imaging (ultrasound, FibroScan)**:
  - Assess for fatty liver, fibrosis, cirrhosis

**If AST is Elevated Due to Liver:**

**1. Lifestyle Interventions** (Most Effective for NAFLD/Fatty Liver)
- **Lose weight if overweight**: 5-10% weight loss significantly reduces liver fat
- **Low-carb or Mediterranean diet**: Reduces liver fat, improves insulin sensitivity
- **Avoid alcohol**: Even moderate alcohol worsens liver disease
- **Exercise regularly**: 150+ minutes weekly (both cardio and resistance training)
- **Avoid fructose/added sugars**: Major driver of fatty liver
- **Increase omega-3 intake**: 2-3g EPA/DHA daily (fish oil) reduces liver inflammation

**2. Supplements**
- **Vitamin E** (800 IU daily): Proven to reduce liver inflammation in NAFLD (use gamma-tocopherol form)
- **Milk thistle (silymarin)**: 200-400mg daily (modest benefit)
- **NAC (N-acetylcysteine)**: 600-1200mg daily (antioxidant, supports glutathione)
- **Berberine**: 500mg 2-3x daily (improves insulin sensitivity, reduces liver fat)

**3. Medications (if needed)**
- **GLP-1 agonists** (semaglutide, liraglutide): Effective for weight loss and reducing liver fat
- **Pioglitazone**: Improves insulin sensitivity, reduces liver inflammation (if diabetic/prediabetic)
- **Statins**: Safe in most liver disease (monitor enzymes)

**4. Avoid Hepatotoxins**
- Limit acetaminophen (Tylenol) use
- Avoid excessive NSAIDs (ibuprofen, naproxen)
- Review all medications and supplements for liver toxicity

**If AST is Elevated Due to Muscle:**
- Likely from intense exercise or statin use
- Check **CK (creatine kinase)**: If very high (>1000 U/L), could indicate rhabdomyolysis (medical emergency)
- If statin-related: Reduce statin dose or switch to lower-potency statin
- If exercise-related: Allow adequate recovery, stay hydrated

**Monitoring:**
- Retest AST and ALT every 3-6 months if elevated
- Pair with GGT, CK, metabolic panel, and liver imaging if persistently elevated
- Goal: AST <25 U/L for optimal liver health

**Special Considerations:**
- **Alcohol use**: Even "moderate" drinking (1-2 drinks daily) can elevate AST and worsen liver health
- **Metabolic syndrome**: AST often elevated alongside high triglycerides, low HDL, high glucose, obesity
- **Medications**: Many common drugs (statins, metformin, antibiotics) can transiently elevate AST

**The Bottom Line:**
AST is a marker of liver or muscle damage. Target <20-25 U/L for optimal liver health. If elevated, check ALT, GGT, CK to differentiate liver vs. muscle causes. For fatty liver (most common cause), focus on weight loss, low-carb diet, exercise, avoid alcohol/fructose, and supplement with vitamin E 800 IU and omega-3s 2-3g daily.',
    recommendations_primary = COALESCE(recommendations_primary, 'Target <25 U/L; if elevated due to liver: lose weight (5-10%), low-carb Mediterranean diet, exercise 150+ min weekly, avoid alcohol/fructose, supplement vitamin E 800 IU + omega-3s 2-3g daily; check ALT, GGT, CK to differentiate liver vs. muscle'),
    therapeutics_primary = COALESCE(therapeutics_primary, 'For fatty liver: Vitamin E 800 IU daily, omega-3s (EPA/DHA) 2-3g daily, berberine 500mg 2-3x daily; GLP-1 agonists (semaglutide) if obesity/metabolic syndrome; pioglitazone 15-30mg if diabetic/prediabetic'),
    updated_at = NOW()
WHERE biomarker_name = 'AST'
  AND is_active = true;

SELECT '✅ Added education for batch 2 biomarkers: Homocysteine, Ferritin, Hemoglobin, AST' as status;
