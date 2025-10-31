#!/usr/bin/env python3
"""
Batch 2: Add education for more critical biomarkers
Focus on: Vitamin D, Homocysteine, Ferritin, Hemoglobin, AST
"""

import psycopg2

DATABASE_URL = "postgresql://postgres.csotzmardnvrpdhlogjm:pd3Wc7ELL20OZYkE@aws-1-us-west-1.pooler.supabase.com:5432/postgres?sslmode=require"

BATCH2_BIOMARKERS = {
    'Homocysteine': {
        'education': """**Understanding Homocysteine**

Homocysteine is an amino acid byproduct of methionine metabolism. Elevated levels are a powerful independent risk factor for cardiovascular disease, stroke, dementia, and all-cause mortality.

**The Longevity Connection:**
- Elevated homocysteine increases stroke risk 2-3 fold
- Each 5 μmol/L increase raises cardiovascular disease risk 20-30%
- Strong predictor of Alzheimer's disease and cognitive decline
- Associated with accelerated brain atrophy
- May be causative (damages blood vessels, neurons) not just correlative

**Optimal Ranges:**
- **Optimal**: <7 μmol/L
- **Good**: 7-10 μmol/L
- **Borderline**: 10-15 μmol/L
- **Elevated**: 15-30 μmol/L
- **High**: >30 μmol/L

**Standard Lab Reference (Too Lenient):**
- Often lists <15 μmol/L as "normal"
- But cardiovascular and cognitive risks start rising above 10 μmol/L
- Target <7 μmol/L for optimal longevity

**Why High Homocysteine is Dangerous:**

**Cardiovascular:**
- Damages arterial endothelium (inner lining)
- Promotes blood clot formation
- Increases LDL oxidation
- Accelerates atherosclerosis
- Increases stroke risk dramatically

**Brain/Cognitive:**
- Neurotoxic at high levels
- Accelerates brain atrophy (shrinkage)
- Damages hippocampus (memory center)
- Strongly predicts Alzheimer's disease
- Impairs neurotransmitter function

**What Causes Elevated Homocysteine:**

**Nutritional Deficiencies (Most Common):**
- **Folate (B9) deficiency**: most common cause
- **Vitamin B12 deficiency**: especially in elderly, vegans
- **Vitamin B6 deficiency**: less common but important
- These vitamins are required to metabolize homocysteine

**Genetic:**
- **MTHFR mutation**: very common (40-50% have at least one copy)
- Impairs folate metabolism
- Requires higher folate intake or methylfolate supplement
- C677T variant most clinically significant

**Lifestyle:**
- **Coffee**: >4 cups daily can raise homocysteine
- **Smoking**: significantly raises levels
- **Excessive alcohol**: impairs B vitamin absorption
- **Poor diet**: low in folate-rich foods

**Medical:**
- **Kidney disease**: impairs homocysteine excretion
- **Hypothyroidism**
- **Certain medications**: methotrexate, anti-epileptics, metformin (mild B12 depletion)

**How to Lower Homocysteine:**

**B Vitamin Supplementation (Highly Effective):**
Most people can normalize homocysteine with B vitamins:

**Folate (B9):**
- **Folic acid**: 400-800mcg daily (synthetic)
- **Methylfolate**: 400-1000mcg daily (active form, better if MTHFR mutation)
- From food: leafy greens, legumes, fortified grains

**Vitamin B12:**
- **Methylcobalamin or hydroxocobalamin**: 500-1000mcg daily
- Higher doses (1000-2000mcg) if elderly or vegan
- Sublingual or injection if absorption issues
- From food: meat, fish, eggs, dairy

**Vitamin B6:**
- **Pyridoxine or P5P** (active form): 25-50mg daily
- From food: poultry, fish, potatoes, chickpeas

**Combination B-Complex:**
- Often easiest approach
- Look for methylated forms (methylfolate, methylcobalamin)
- Typical dose: B6 25-50mg, B12 500-1000mcg, Folate 400-800mcg

**Expected Results:**
- Homocysteine typically drops 25-50% within 6-12 weeks
- Can normalize even very high levels (>20) down to <10
- Monitor with repeat testing

**Dietary Sources:**

**High in Folate:**
- Leafy greens (spinach, kale, collards)
- Legumes (lentils, beans, chickpeas)
- Asparagus, broccoli, Brussels sprouts
- Avocado
- Fortified grains/cereals

**High in B12:**
- Meat (especially liver)
- Fish and seafood
- Eggs
- Dairy products
- Fortified foods (for vegans)

**High in B6:**
- Poultry, fish
- Potatoes, sweet potatoes
- Bananas
- Chickpeas

**Lifestyle:**
- **Reduce coffee**: if >4 cups daily, cut back
- **Don't smoke**: raises homocysteine significantly
- **Moderate alcohol**: excessive intake depletes B vitamins
- **Regular exercise**: may modestly lower homocysteine

**Special Considerations:**

**MTHFR Mutation:**
- Very common genetic variant
- Impairs folate metabolism
- Solution: use methylfolate (not folic acid)
- Higher doses may be needed (800-1000mcg)
- Test if homocysteine elevated despite B vitamin supplementation

**Vegans/Vegetarians:**
- High risk for B12 deficiency
- MUST supplement B12 (500-1000mcg daily)
- Check B12 and homocysteine annually
- Folate usually adequate from plant foods

**Elderly:**
- B12 absorption declines with age (low stomach acid)
- Higher doses needed (1000-2000mcg)
- Consider sublingual or injection
- Regular monitoring essential

**Kidney Disease:**
- Homocysteine rises as kidney function declines
- Harder to lower with B vitamins alone
- Still supplement, but may not normalize completely
- Monitor closely

**On Metformin:**
- Long-term metformin can deplete B12
- Supplement B12 preventively
- Check B12 and homocysteine annually

**Monitoring:**
- Test homocysteine at baseline
- Retest 3 months after starting B vitamins
- Once optimal (<7-10), check annually
- If elevated despite supplementation, check B vitamin levels and consider MTHFR testing

**Why This Matters:**
Despite strong evidence linking elevated homocysteine to disease, routine testing is uncommon. Yet it's:
- Easy to test
- Easy to treat (inexpensive B vitamins)
- Potentially high impact for brain and cardiovascular health

**The Bottom Line:**
Target homocysteine <7-10 μmol/L for optimal longevity. If elevated, supplement with B vitamins: methylfolate 400-800mcg, methylcobalamin 500-1000mcg, B6 25-50mg daily. Most people will see dramatic reductions within 3 months. This is one of the easiest and most impactful interventions for brain and cardiovascular health.""",
        'recommendations_primary': 'Supplement methylfolate 400-800mcg + methylcobalamin 500-1000mcg + B6 25-50mg daily; eat folate-rich foods (leafy greens, legumes); reduce coffee if >4 cups daily',
        'therapeutics_primary': 'High-dose B-complex with methylated forms; methylfolate 1000mcg if MTHFR mutation; B12 injection if absorption issues'
    },

    'Ferritin': {
        'education': """**Understanding Ferritin**

Ferritin is your body's iron storage protein. It's the most sensitive marker of iron status and a key predictor of energy, athletic performance, and longevity. Both too low AND too high are problematic.

**The Longevity Connection:**
- Low ferritin: fatigue, poor exercise capacity, impaired cognition, weakened immunity
- High ferritin: oxidative stress, increased infection risk, associated with metabolic syndrome
- Optimal levels support oxygen delivery, energy production, immune function
- Sweet spot exists - not too low, not too high

**Optimal Ranges:**

**For Men:**
- **Optimal**: 50-150 ng/mL
- **Low/depleted**: <30 ng/mL (iron deficiency)
- **Borderline low**: 30-50 ng/mL (suboptimal for performance)
- **High**: >300 ng/mL
- **Very high**: >500 ng/mL (investigate for hemochromatosis)

**For Women (Premenopausal):**
- **Optimal**: 30-100 ng/mL
- **Low/depleted**: <15 ng/mL (iron deficiency)
- **Borderline low**: 15-30 ng/mL (very common in menstruating women)
- **High**: >200 ng/mL

**For Athletes:**
- Target higher: 50-100 ng/mL (men), 30-80 ng/mL (women)
- Endurance athletes especially susceptible to low ferritin
- Performance suffers even with "normal" ferritin if <50

**What is Ferritin:**
- Stores iron in liver, spleen, bone marrow
- Released into blood in small amounts
- Serum ferritin reflects total body iron stores
- Falls BEFORE hemoglobin drops (early warning sign)

**Symptoms of Low Ferritin:**

**Physical:**
- Chronic fatigue, low energy (most common)
- Exercise intolerance, poor endurance
- Shortness of breath with exertion
- Pale skin, brittle nails
- Hair loss (especially in women)
- Cold intolerance
- Restless leg syndrome

**Cognitive:**
- Brain fog, poor concentration
- Memory problems
- Mood disturbances, irritability

**Why Low Ferritin Happens:**

**Women (Most Common):**
- **Menstruation**: lose iron monthly
- **Pregnancy**: high iron demands
- **Breastfeeding**: depletes stores
- ~25-30% of premenopausal women have low ferritin

**Diet:**
- **Vegetarian/vegan**: plant iron poorly absorbed (3-5% vs. 15-25% from meat)
- **Low meat intake**: heme iron (from meat) best absorbed
- **Poor absorption**: phytates (grains, legumes), tannins (tea, coffee) inhibit absorption

**Medical:**
- **GI blood loss**: ulcers, polyps, cancer
- **Heavy periods**: menorrhagia
- **Celiac disease**: impaired absorption
- **H. pylori infection**: reduces iron absorption
- **Chronic inflammation**: sequesters iron

**Athletes:**
- **Foot strike hemolysis**: endurance running
- **GI bleeding**: from NSAIDs or intense exercise
- **Hepcidin elevation**: intense training raises hepcidin (blocks iron absorption)
- **Increased needs**: higher blood volume, myoglobin

**How to Raise Ferritin:**

**Dietary Iron (Best from Food):**

**Heme Iron (Best Absorbed: 15-25%):**
- Red meat (beef, lamb)
- Organ meats (liver - extremely high in iron)
- Poultry (dark meat)
- Fish and seafood (especially oysters, mussels)

**Non-Heme Iron (Poorly Absorbed: 3-5%):**
- Legumes (lentils, beans)
- Tofu
- Fortified cereals
- Spinach, kale (but contain inhibitors)
- Pumpkin seeds, quinoa

**Enhance Absorption:**
- **Vitamin C**: consume with iron-rich meals (citrus, peppers, tomatoes)
- **Meat**: even small amounts enhance non-heme iron absorption

**Avoid with Meals:**
- **Coffee/tea**: tannins block iron absorption (wait 1 hour after eating)
- **Calcium**: competes with iron (separate supplements by 2 hours)
- **Phytates**: soak/sprout grains and legumes to reduce

**Iron Supplementation (If Needed):**

**When to Supplement:**
- Ferritin <30 ng/mL (women), <50 ng/mL (men or athletes)
- Symptoms of deficiency
- Can't get enough from diet alone
- Monitor with testing

**Forms:**
- **Ferrous sulfate**: cheap, effective, but GI side effects common (25-50mg elemental iron)
- **Ferrous bisglycinate**: chelated, better absorbed, fewer GI issues (25-50mg)
- **Iron polysaccharide**: gentle on stomach
- **Heme iron supplement**: from animal sources, best absorbed

**Dosing:**
- **Typical**: 25-50mg elemental iron daily
- **Therapeutic**: 50-100mg daily (if very deficient)
- **Take on empty stomach** (better absorption) or with food if GI issues
- **With vitamin C**: enhances absorption

**How Quickly Does Ferritin Rise:**
- Ferritin increases slowly: 2-5 ng/mL per month on supplements
- If starting at 15 ng/mL, may take 3-6 months to reach 50 ng/mL
- Hemoglobin rises faster than ferritin (weeks vs. months)
- Patience essential - keep supplementing

**Side Effects:**
- Constipation (most common - start low dose)
- Nausea, stomach upset
- Dark stools (normal, not concerning)

**Too Much Iron:**

**Symptoms of High Ferritin (>300-500):**
- Fatigue (yes, can cause fatigue too!)
- Joint pain
- Abdominal pain
- Bronze skin color
- Liver problems
- Increased infection risk

**Causes:**
- **Hemochromatosis** (genetic iron overload - 1 in 200 people)
- **Inflammation**: ferritin is acute phase reactant (rises with inflammation)
- **Chronic disease**: liver disease, cancer
- **Excessive supplementation**

**If High Ferritin:**
- **Check CRP**: if elevated, may be inflammation not true iron overload
- **Check iron saturation**: if >45%, consider hemochromatosis
- **Genetic testing**: HFE gene mutations (C282Y, H63D)
- **Treatment**: phlebotomy (blood donation) if true iron overload

**Monitoring:**
- Test ferritin at baseline
- If low, retest every 3 months while supplementing
- Once optimal, check annually
- Women: check more frequently (menstruation depletes stores)

**Special Populations:**

**Vegetarians/Vegans:**
- Need 1.8x more iron than meat-eaters (poor absorption)
- Combine iron-rich plant foods with vitamin C
- May need supplementation despite "adequate" dietary iron
- Check ferritin annually

**Athletes:**
- Higher requirements (increased blood volume, losses)
- Target ferritin 50-100 ng/mL (higher than general population)
- Monitor every 3-6 months
- Performance suffers with ferritin <50 even if "normal"

**Pregnant Women:**
- Iron needs double during pregnancy
- Ferritin often drops despite supplementation
- Important for fetal development and maternal energy
- Monitor closely

**The Bottom Line:**
Target ferritin 50-150 ng/mL (men), 30-100 ng/mL (women) for optimal energy and performance. If low: eat red meat 2-3x weekly or supplement with 25-50mg elemental iron daily (ferrous bisglycinate best tolerated). Takes 3-6 months to rebuild stores. If high (>300), investigate for hemochromatosis or inflammation. Don't ignore low ferritin - it's an easy fix with major energy and performance benefits.""",
        'recommendations_primary': 'Eat red meat 2-3x weekly or supplement iron 25-50mg daily if deficient; consume with vitamin C; avoid coffee/tea with meals; monitor levels',
        'therapeutics_primary': 'Ferrous bisglycinate 25-50mg elemental iron daily (best tolerated); higher doses 50-100mg if very deficient; IV iron if oral not tolerated/absorbed'
    },

    'Hemoglobin': {
        'education': """**Understanding Hemoglobin**

Hemoglobin is the oxygen-carrying protein in red blood cells. It's essential for delivering oxygen to every cell in your body and directly affects energy, exercise capacity, and longevity.

**The Longevity Connection:**
- Both low (anemia) and high (polycythemia) increase mortality risk
- Anemia increases cardiovascular strain, accelerates aging
- Low hemoglobin reduces exercise capacity, energy, cognitive function
- Optimal levels support aerobic performance, recovery, overall vitality

**Optimal Ranges:**

**Men:**
- **Optimal**: 14-16 g/dL
- **Normal**: 13.5-17.5 g/dL
- **Anemia**: <13.5 g/dL
- **Polycythemia (too high)**: >17.5 g/dL

**Women:**
- **Optimal**: 13-15 g/dL
- **Normal**: 12-16 g/dL
- **Anemia**: <12 g/dL
- **Polycythemia**: >16 g/dL

**Athletes (Higher Normal):**
- May run 0.5-1 g/dL higher than sedentary individuals
- Adaptation to training increases red blood cell production
- Higher levels support oxygen delivery during exercise

**What is Hemoglobin:**
- Protein in red blood cells containing iron
- Binds oxygen in lungs, releases to tissues
- Also carries CO2 from tissues back to lungs
- Hemoglobin level reflects oxygen-carrying capacity

**Symptoms of Low Hemoglobin (Anemia):**

**Physical:**
- Fatigue, exhaustion (overwhelming tiredness)
- Weakness, low energy
- Shortness of breath (especially with exertion)
- Dizziness, lightheadedness
- Rapid or irregular heartbeat
- Pale skin, nail beds, conjunctiva
- Cold hands and feet
- Headaches

**Exercise:**
- Poor endurance, can't sustain effort
- Elevated heart rate at given workload
- Slow recovery
- Performance decline

**Cognitive:**
- Brain fog, difficulty concentrating
- Memory problems
- Mood disturbances

**Causes of Low Hemoglobin:**

**Iron Deficiency (Most Common):**
- Inadequate dietary iron
- Blood loss (menstruation, GI bleeding)
- Poor absorption
- See Ferritin education for details

**Nutritional:**
- **B12 deficiency**: impairs red blood cell production
- **Folate deficiency**: also impairs RBC production
- **Copper deficiency**: rare but impairs iron utilization

**Chronic Disease:**
- Kidney disease (low erythropoietin production)
- Chronic inflammation (anemia of chronic disease)
- Cancer
- Autoimmune conditions

**Genetic:**
- Thalassemia
- Sickle cell disease
- Other hemoglobinopathies

**How to Raise Hemoglobin:**

**Address Underlying Cause:**
- **If iron deficiency**: supplement iron + optimize diet (see Ferritin)
- **If B12/folate deficiency**: supplement those vitamins
- **If chronic disease**: treat underlying condition
- **If blood loss**: identify and stop source

**Dietary Optimization:**
- **Iron-rich foods**: red meat, organ meats, seafood
- **B12**: meat, fish, eggs, dairy
- **Folate**: leafy greens, legumes, fortified grains
- **Copper**: shellfish, nuts, seeds
- **Vitamin C**: enhances iron absorption

**Supplementation:**
- **Iron**: 25-100mg elemental iron daily (if deficient)
- **B12**: 500-1000mcg daily (if deficient)
- **Folate**: 400-800mcg daily (if deficient)
- **Multi-nutrient approach**: often all three needed

**How Fast Does Hemoglobin Rise:**
- Faster than ferritin: 0.1-0.2 g/dL per week on iron
- If starting at 11 g/dL, may take 2-3 months to normalize to 13-14 g/dL
- Reticulocyte count (immature RBCs) rises first (within weeks)
- Hemoglobin follows (months)

**High Hemoglobin (Polycythemia):**

**Causes:**
- **Dehydration** (falsely elevated - test when well-hydrated)
- **Smoking** (compensatory increase due to CO exposure)
- **Sleep apnea** (low oxygen → more RBC production)
- **Living at altitude** (physiologic adaptation)
- **Polycythemia vera** (bone marrow disorder - rare)
- **Testosterone therapy** or anabolic steroids (stimulate RBC production)
- **EPO use** (doping)

**Dangers of High Hemoglobin:**
- Increased blood viscosity ("thick blood")
- Higher risk of blood clots
- Stroke and heart attack risk
- Headaches, dizziness
- High blood pressure

**If Hemoglobin Elevated:**
- **Recheck when well-hydrated**
- **Check oxygen saturation**
- **Sleep study** if suspect apnea
- **Stop smoking**
- **If on testosterone**: may need dose reduction or phlebotomy
- **Rule out polycythemia vera**: hematology referral

**Special Considerations:**

**Women:**
- More prone to anemia (menstruation)
- Check hemoglobin annually
- If heavy periods: supplement iron preventively
- Pregnancy: needs increase significantly

**Athletes:**
- Endurance athletes prone to "sports anemia"
  - Dilutional (expanded blood volume)
  - True iron deficiency
- Monitor ferritin (more sensitive than hemoglobin)
- Performance impaired even with "normal-low" hemoglobin
- Target upper-normal range for optimal performance

**Elderly:**
- Anemia common (10-20% of those >65)
- Often multifactorial (nutrition, chronic disease, medications)
- Don't accept as "normal aging" - investigate cause
- Associated with frailty, cognitive decline

**On Testosterone:**
- TRT stimulates RBC production
- Hemoglobin and hematocrit may rise
- Monitor every 3-6 months
- If too high (>17-18 g/dL): reduce dose or donate blood

**The Bottom Line:**
Target hemoglobin 14-16 g/dL (men), 13-15 g/dL (women) for optimal oxygen delivery and energy. If anemic: investigate cause (usually iron deficiency), supplement appropriately, and recheck in 2-3 months. If high: rule out dehydration, sleep apnea, smoking; if persistently elevated, see hematologist. Optimal hemoglobin is key for energy, exercise performance, and longevity.""",
        'recommendations_primary': 'If low: supplement iron 25-50mg + B12 500mcg + folate 400mcg daily; eat iron-rich foods (red meat, organ meats); address underlying causes',
        'therapeutics_primary': 'Iron supplementation 50-100mg daily; B12 injection if severe deficiency; erythropoietin (EPO) if kidney disease-related anemia; phlebotomy if polycythemia'
    },

    'AST': {
        'education': """**Understanding AST (Aspartate Aminotransferase)**

AST is an enzyme found in liver, heart, muscle, kidneys, and brain. Elevated AST suggests tissue damage, most commonly in the liver. It's often measured alongside ALT to assess liver health.

**The Longevity Connection:**
- Elevated AST predicts metabolic syndrome, cardiovascular disease, mortality
- Marker of liver health - fatty liver now affects 25-30% of population
- Also reflects muscle damage, heart damage (in specific contexts)
- Optimal levels indicate good hepatic and overall metabolic health

**Optimal Ranges:**
- **Optimal**: <25 U/L (men), <20 U/L (women)
- **Acceptable**: 25-30 U/L
- **Borderline**: 30-40 U/L
- **Elevated**: >40 U/L

**Standard Lab Reference (Too Lenient):**
- Often <40 U/L listed as "normal"
- But metabolic risk rises above 25-30 U/L
- Target <25 U/L for optimal health

**AST vs. ALT:**

**Key Differences:**
- **ALT**: more liver-specific
- **AST**: also in heart, muscle, kidneys, brain
- **AST/ALT ratio** helps diagnose cause:
  - <1: typical of NAFLD (non-alcoholic fatty liver)
  - >2: suggests alcoholic liver disease
  - >3: consider cirrhosis or alcoholic hepatitis

**What Causes Elevated AST:**

**Liver (Most Common):**
- **Non-alcoholic fatty liver disease** (NAFLD)
- **Alcohol**: excessive consumption
- **Viral hepatitis** (B, C)
- **Medications**: statins, acetaminophen, many others
- **Autoimmune hepatitis**
- **Cirrhosis**

**Muscle:**
- **Intense exercise**: especially resistance training or marathon running
- **Rhabdomyolysis**: severe muscle breakdown
- **Muscle injury or trauma**
- **Statin-induced myopathy**: muscle damage from statins

**Heart:**
- **Heart attack** (myocardial infarction)
- **Heart failure**
- Usually accompanied by elevated troponin (more specific)

**Other:**
- **Hemolysis**: red blood cell breakdown
- **Celiac disease**
- **Hypothyroidism**

**How to Lower AST:**

**If Liver-Related (Most Common):**

**Diet:**
- **Eliminate added sugars**: especially fructose/HFCS
- **No fruit juice or soda**
- **Mediterranean or low-carb diet**: most evidence for NAFLD
- **Increase fiber**: 30-40g daily
- **Coffee**: 2-3 cups daily (protective for liver)
- **Omega-3s**: 2-4g EPA+DHA daily

**Weight Loss:**
- 5-10% weight loss reduces liver enzymes 30-40%
- Visceral fat loss particularly important
- Rapid weight loss (keto, VLCD) can quickly improve AST

**Exercise:**
- 150+ minutes weekly
- Both aerobic and resistance training reduce liver fat
- But AST may temporarily rise after intense exercise (normal)

**Avoid/Limit Alcohol:**
- If AST elevated, consider eliminating entirely
- At minimum: <7 drinks/week

**Supplements:**
- **Vitamin E**: 800 IU daily (for NASH)
- **Omega-3s**: 2-4g EPA+DHA
- **Silymarin** (milk thistle): 420mg daily
- **NAC**: 600-1200mg

**Medications:**
- **Pioglitazone**: for NASH with diabetes/insulin resistance
- **GLP-1 agonists**: weight loss improves NAFLD
- **Statins**: don't stop if mild AST elevation (often safe to continue)

**If Muscle-Related:**
- **Rest and recovery**: after intense exercise
- **Hydration**: prevents rhabdomyolysis
- **Gradual training progression**: avoid sudden increases
- **If on statins**: discuss with doctor; may need dose adjustment or different statin
- **CoQ10**: 100-200mg if statin-induced myopathy

**Interpreting AST:**

**AST/ALT Ratio <1 (ALT > AST):**
- Typical of NAFLD
- Fatty liver from metabolic syndrome
- Focus on weight loss, diet, exercise

**AST/ALT Ratio >2 (AST much higher than ALT):**
- Suggests alcohol-related liver disease
- OR cirrhosis (advanced scarring)
- More concerning pattern
- Requires medical evaluation

**Both AST and ALT Elevated:**
- Liver inflammation (hepatitis)
- Check for: viral hepatitis, autoimmune hepatitis, medications
- Ultrasound or FibroScan to assess severity

**AST Elevated, ALT Normal:**
- Consider non-liver causes:
- Muscle damage (check CK)
- Heart issues (check troponin)
- Hemolysis (check bilirubin, haptoglobin)
- Recent intense exercise

**Special Considerations:**

**Athletes:**
- AST commonly elevated 2-3x after intense training
- Especially resistance training, marathon running
- Retest 3-5 days after rest
- If normalizes, likely muscle-related (not concerning)

**On Statins:**
- Mild AST elevation (up to 2-3x normal) often acceptable
- Don't automatically stop statins
- Monitor over time
- If >3x normal or symptomatic (muscle pain): discuss alternatives
- CoQ10 may help statin-induced myopathy

**Alcohol Consumption:**
- AST typically higher than ALT with alcohol
- AST/ALT ratio >2 strongly suggests alcohol-related
- Even moderate drinking (2-3 drinks/day) can elevate AST
- Trial of alcohol cessation for 4-6 weeks

**When to Investigate Further:**

**AST 40-100 U/L:**
- Check AST/ALT ratio
- Assess metabolic risk factors
- Consider liver ultrasound or FibroScan
- Check viral hepatitis serologies
- Review medications

**AST >100 U/L:**
- Urgent evaluation
- Check for acute hepatitis, drug-induced liver injury
- If muscle-related: rule out rhabdomyolysis (very high CK)
- Hepatology referral

**Monitoring:**
- If elevated: retest every 3-6 months
- Track alongside ALT, weight, metabolic markers
- Once normalized: annual testing

**The Bottom Line:**
Target AST <25 U/L. If elevated with ALT, assume liver-related (likely fatty liver) until proven otherwise. Treatment: lose 5-10% body weight, eliminate sugar/refined carbs, exercise 150+ min weekly, limit alcohol. If isolated AST elevation, consider muscle or heart causes. AST often normalizes within 3-6 months with aggressive lifestyle intervention.""",
        'recommendations_primary': 'If liver-related: lose weight, eliminate added sugars, exercise 150+ min weekly, limit alcohol, drink coffee daily; if muscle-related: rest and recovery',
        'therapeutics_primary': 'Vitamin E 800 IU daily (for NASH); pioglitazone if diabetic with NASH; GLP-1 agonists for weight loss; CoQ10 100-200mg if statin-induced'
    },
}

def populate_batch2():
    """Add batch 2 biomarkers"""
    conn = psycopg2.connect(DATABASE_URL)
    cur = conn.cursor()

    try:
        print("="*80)
        print("BATCH 2: ADDING MORE BIOMARKER EDUCATION")
        print("="*80)
        print()

        count = 0
        for biomarker_name, content in BATCH2_BIOMARKERS.items():
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
                content['education'],
                content.get('recommendations_primary'),
                content.get('therapeutics_primary'),
                biomarker_name
            ))

            if cur.rowcount > 0:
                print(f"✓ Updated: {biomarker_name}")
                count += 1
            else:
                print(f"⚠ Not found: {biomarker_name}")

        conn.commit()

        print()
        print("="*80)
        print(f"✅ Batch 2 complete! Added {count} biomarkers")
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
    populate_batch2()
