import os
import pandas as pd
from datetime import datetime

# --- Load Data ---
base_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
patient_survey = pd.read_csv(os.path.join(base_dir, "data", "synthetic_patient_survey.csv"))
biomarker_df = pd.read_csv(os.path.join(base_dir, "data", "dummy_lab_results_full.csv"))

def clean_id(x):
    x = str(x).strip()
    if '.' in x:
        left, right = x.split('.', 1)
        return f"{int(left)}.{right.zfill(2)}"
    return x

patient_survey.columns = [clean_id(c) if c != 'patient_id' else c for c in patient_survey.columns]

# --- Custom Logic for Protein Intake (2.11) ---
def calc_protein_target(weight_lb, age):
    weight_kg = weight_lb / 2.205
    if age < 65:
        target = 1.2 * weight_kg
    else:
        target = 1.5 * weight_kg
    return round(target, 1)

def protein_intake_score(protein_g, weight_lb, age):
    try:
        protein_g = float(protein_g)
        target = calc_protein_target(weight_lb, age)
        pct = protein_g / target if target else 0
        if pct >= 1:
            return 10
        elif pct >= 0.8:
            return 8
        elif pct >= 0.6:
            return 6
        elif pct > 0:
            return 4
        else:
            return 0
    except Exception:
        return 0

# --- Custom Logic for Calories Intake (2.62) ---
def calc_calorie_target(weight_lb, age, sex):
    weight_kg = weight_lb / 2.205
    # Example: Simple Harris-Benedict BMR * 1.2 sedentary
    if sex.lower().startswith("m"):
        bmr = 88.362 + (13.397 * weight_kg) + (4.799 * 175) - (5.677 * age)  # using avg height 175cm
    else:
        bmr = 447.593 + (9.247 * weight_kg) + (3.098 * 162) - (4.330 * age)  # using avg height 162cm
    calorie_target = bmr * 1.2
    return round(calorie_target)

def calorie_intake_score(calories, weight_lb, age, sex):
    try:
        calories = float(calories)
        target = calc_calorie_target(weight_lb, age, sex)
        pct = calories / target if target else 0
        # Scoring logic, e.g. within ±15% of target = 10; ±25% = 8, ±35% = 6, else 2
        if 0.85 <= pct <= 1.15:
            return 10
        elif 0.75 <= pct < 0.85 or 1.15 < pct <= 1.25:
            return 8
        elif 0.65 <= pct < 0.75 or 1.25 < pct <= 1.35:
            return 6
        else:
            return 2
    except Exception:
        return 0

# --- Custom Logic for Movement (3.03-3.11) ---

FREQ_SCORES = {
    "": 0.0,
    "Rarely (a few times a month)": 0.4,
    "Occasionally (1–2 times per week)": 0.6,
    "Regularly (3–4 times per week)": 0.8,
    "Frequently (5 or more times per week)": 1.0
}

DUR_SCORES = {
    "": 0.0,
    "Less than 30 minutes": 0.6,
    "30–45 minutes": 0.8,
    "45–60 minutes": 0.9,
    "More than 60 minutes": 1.0
}

movement_questions = {
    "Cardio": {
        "freq_q": "3.04",
        "dur_q": "3.08",
        "pillar_weights": {"Movement": 16}
    },
    "Strength": {
        "freq_q": "3.05",
        "dur_q": "3.09",
        "pillar_weights": {"Movement": 16}
    },
    "Flexibility": {
        "freq_q": "3.06",
        "dur_q": "3.10",
        "pillar_weights": {"Movement": 13}
    },
    "HIIT": {
        "freq_q": "3.07",
        "dur_q": "3.11",
        "pillar_weights": {"Movement": 16}
    }
}

def score_movement_pillar(row, movement_questions):
    movement_scores = {}
    for move_type, cfg in movement_questions.items():
        freq_ans = row.get(cfg["freq_q"], "")
        dur_ans = row.get(cfg["dur_q"], "")
        freq = FREQ_SCORES.get(freq_ans, 0.0)
        dur = DUR_SCORES.get(dur_ans, 0.0)
        # Each pillar_weights is a dict, e.g. {"Movement": 16}
        for pillar, weight in cfg["pillar_weights"].items():
            if freq == 0 and dur == 0:
                movement_scores[(move_type, pillar)] = 0
            else:
                total = freq + dur
                if total >= 1.6:
                    movement_scores[(move_type, pillar)] = weight
                else:
                    movement_scores[(move_type, pillar)] = total * (weight / 2)
    return movement_scores

# --- Sleep Issue Config with Pillar Weights (modular for multi-pillar mapping) ---
SLEEP_ISSUES = [
    # (issue_text, frequency_qid, {"Sleep": weight, ...})
    ("Difficulty falling asleep", "4.13", {"Sleep": 5}),
    ("Difficulty staying asleep", "4.14", {"Sleep": 5}),
    ("Waking up too early", "4.15", {"Sleep": 5}),
    ("Frequent nightmares", "4.16", {"Sleep": 3}),
    ("Restless legs", "4.17", {"Sleep": 6, "Movement": 1}),
    ("Snoring", "4.18", {"Sleep": 4, "CoreCare": 2}),
]

SLEEP_FREQ_MAP = {
    "Always": 0.2,
    "Frequently": 0.4,
    "Occasionally": 0.6,
    "Rarely": 0.8,
    "": 1.0,  # Not selected/frequency – full credit
}

def score_sleep_issues(patient_answers):
    # patient_answers is a dict-like row from patient_survey
    sleep_issues_reported = [x.strip() for x in str(patient_answers.get("4.12", "")).split("|") if x.strip()]
    # Full credit if none reported or "None" selected
    if not sleep_issues_reported or any("none" in s.lower() for s in sleep_issues_reported):
        # Return a dict by pillar with full credit
        pillar_totals = {}
        for _, _, pillar_wts in SLEEP_ISSUES:
            for p, w in pillar_wts.items():
                pillar_totals[p] = pillar_totals.get(p, 0.0) + w
        return pillar_totals

    # Otherwise, score each reported issue
    pillar_scores = {}
    for issue, freq_qid, pillar_wts in SLEEP_ISSUES:
        if issue in sleep_issues_reported:
            freq_ans = str(patient_answers.get(freq_qid, "")).strip()
            mult = SLEEP_FREQ_MAP.get(freq_ans, 0.2)
        else:
            mult = 1.0  # Not selected = full credit
        for p, w in pillar_wts.items():
            pillar_scores[p] = pillar_scores.get(p, 0.0) + (w * mult)
    return pillar_scores

# --- Sleep Hygiene Protocols (4.07) ---
def score_sleep_protocols(answer_str):
    WEIGHT = 9.0  # Assign to pillar(s) below in config
    protocols = [x.strip() for x in (answer_str or "").split("|") if x.strip()]
    n = len(protocols)
    if n >= 7:
        score = 1.0
    elif n >= 5:
        score = 0.8
    elif n >= 3:
        score = 0.6
    elif n >= 1:
        score = 0.4
    else:
        score = 0.2
    return round(score * WEIGHT, 2)

# --- Sleep Apnea Management Score (4.28-4.32) ---
def calc_sleep_apnea_score(diagnosis, severity, time_since, treatments, improvement):
    """
    Sleep quality-focused scoring for sleep apnea management.
    Focus: How well is sleep apnea being managed to preserve sleep quality?
    
    Philosophy: Sleep apnea only matters if it impairs sleep quality.
    Well-managed severe apnea > poorly managed mild apnea.
    
    Returns: Score from 0.0 to 1.0 (will be multiplied by pillar weights separately)
    """
    
    # Base cases
    if diagnosis == "No":
        return 1.0  # Full marks - no sleep apnea
    elif diagnosis == "I suspect I may have it but haven't been diagnosed":
        return 0.0  # Zero marks - unmanaged suspected condition affects sleep
    
    # For diagnosed patients: Sleep Quality Management Assessment
    
    # 1. Severity-based potential impact (starting point)
    severity_base = {
        "Severe (AHI 30+ events per hour)": 0.20,      # Most potential for improvement
        "Moderate (AHI 15-29 events per hour)": 0.35,  # Moderate potential
        "Mild (AHI 5-14 events per hour)": 0.50,       # Less severe baseline
        "I don't know/wasn't told the severity": 0.35  # Default to moderate
    }
    base_score = severity_base.get(severity, 0.35)
    
    # 2. Time-based approach: Recent vs Established diagnosis
    time_categories = {
        "Less than 6 months": "recent",
        "6 months to 1 year": "recent", 
        "1-2 years": "established",
        "2-5 years": "established",
        "More than 5 years": "established"
    }
    time_category = time_categories.get(time_since, "established")
    
    # 3. Calculate management quality score
    if time_category == "recent":
        # Recent diagnosis: Focus on treatment quality (improvement takes time)
        treatment_bonus = 0.0
        
        # Parse treatments (pipe-separated string)
        treatment_list = [t.strip() for t in str(treatments).split("|") if t.strip()]
        
        # Gold standard treatments
        if any("CPAP" in t or "BiPAP" in t for t in treatment_list):
            treatment_bonus += 0.30  # Excellent treatment choice
        elif any("Oral appliance" in t for t in treatment_list):
            treatment_bonus += 0.20  # Good alternative treatment
        
        # Comprehensive approach bonus
        active_treatments = [t for t in treatment_list if "No treatment" not in t]
        if len(active_treatments) >= 2:
            treatment_bonus += 0.10  # Multi-modal approach
        
        # Lifestyle engagement
        if any("Lifestyle modifications" in t or "Weight loss" in t for t in treatment_list):
            treatment_bonus += 0.05
            
        # Surgery (aggressive management)
        if any("Surgery" in t for t in treatment_list):
            treatment_bonus += 0.15
            
        # Penalty for no treatment
        if any("No treatment currently" in t for t in treatment_list):
            treatment_bonus -= 0.25
        
        # Modest improvement bonus for recent diagnosis
        improvement_bonus = {
            "Significantly improved": 0.10,
            "Moderately improved": 0.05,
            "Slightly improved": 0.02,
            "No improvement": 0.0,
            "Symptoms have worsened": -0.05
        }.get(improvement, 0.0)
        
        management_score = base_score + treatment_bonus + improvement_bonus
        
    else:
        # Established diagnosis: Focus on outcomes (improvement over time)
        improvement_bonus = {
            "Significantly improved": 0.65,  # Sleep quality restored!
            "Moderately improved": 0.45,    # Good sleep improvement  
            "Slightly improved": 0.25,      # Some sleep benefit
            "No improvement": -0.10,        # Still impaired sleep
            "Symptoms have worsened": -0.20  # Worsening sleep quality
        }.get(improvement, 0.0)
        
        # Modest treatment bonus for established patients
        treatment_list = [t.strip() for t in str(treatments).split("|") if t.strip()]
        treatment_bonus = 0.0
        
        if any("CPAP" in t or "BiPAP" in t for t in treatment_list):
            treatment_bonus += 0.05
        elif any("No treatment currently" in t for t in treatment_list):
            treatment_bonus -= 0.10
            
        management_score = base_score + improvement_bonus + treatment_bonus
    
    # 4. Excellence in management bonus
    # Reward exceptional management of severe conditions
    if (severity == "Severe (AHI 30+ events per hour)" and 
        improvement == "Significantly improved"):
        management_score += 0.10  # Conquered a major sleep disruptor
    
    # 5. Final score calculation
    final_score = management_score
    return round(max(0.0, min(1.0, final_score)), 3)

# --- Cognitive activity count (5.08) ---
def score_cognitive_activities(answer_str):
    WEIGHT = 8.0
    activities = [x.strip() for x in (answer_str or "").split("|") if x.strip()]
    n = len(activities)
    if n >= 5:
        score = 1.0
    elif n == 4:
        score = 0.8
    elif n == 3:
        score = 0.6
    elif n == 2:
        score = 0.4
    elif n == 1:
        score = 0.2
    else:
        score = 0.0
    return round(score * WEIGHT, 2)

# --- 6.01 / 6.02 Stress score ---
def stress_score(stress_level_ans, freq_ans):
    level_map = {
        "No stress": 1.0,
        "Low stress": 0.8,
        "Moderate stress": 0.5,
        "High stress": 0.2,
        "Extreme stress": 0.0,
        "Stress levels vary from low to moderate": 0.5,
        "Stress levels vary from moderate to high": 0.5,
    }
    freq_map = {
        "Rarely": 1.0,
        "Occasionally": 0.7,
        "Frequently": 0.4,
        "Always": 0.0,
    }
    s = level_map.get(str(stress_level_ans).strip(), 0.5)
    f = freq_map.get(str(freq_ans).strip(), 0.5)
    raw_score = (s + f) / 2
    return round(raw_score * 19, 2)  # Out of 19

# --- 6.07 Coping skills score ---
COPING_WEIGHTS_6_07 = {
    "Exercise or physical activity": 1.0,
    "Meditation or mindfulness practices": 1.0,
    "Deep breathing exercises": 0.7,
    "Hobbies or recreational activities": 0.7,
    "Talking to friends or family": 0.7,
    "Professional counseling or therapy": 1.0,
    "Journaling or writing": 0.5,
    "Time management strategies": 0.5,
    "Avoiding stressful situations": 0.3,
    "Other (please specify)": 0.3,
    "None": 0.0,
}

def coping_score(answer_str, coping_weights, stress_level_ans, freq_ans):
    responses = [r.strip() for r in str(answer_str or "").split("|") if r.strip()]
    has_none = any("none" in r.lower() for r in responses)
    high_stress = (str(stress_level_ans).strip() in ["High stress", "Extreme stress"] or
                   str(freq_ans).strip() in ["Frequently", "Always"])
    
    if has_none or not responses:
        return 0.0 if high_stress else 5.5  # No coping strategies
    
    # Calculate weighted score
    total_weight = sum(coping_weights.get(response, 0.5) for response in responses)
    weighted_score = min(total_weight * 3.5, 7.0)
    
    # Adjust scoring based on stress level
    if not high_stress:
        return min(5.5 + total_weight, 7.0)  # Low stress: base 5.5 + bonus for coping
    else:
        return weighted_score  # High-stress people need good coping

# --- Custom logic for Substances ---

USE_BAND_SCORES = {
    "Heavy": 0.0,
    "Moderate": 0.25,
    "Light": 0.5,
    "Minimal": 0.75,
    "Occasional": 1.0
}
DURATION_SCORES = {
    "Less than 1 year": 1.0,
    "1-2 years": 0.8,
    "3-5 years": 0.6,
    "6-10 years": 0.4,
    "11-20 years": 0.2,
    "More than 20 years": 0.0
}

# NEW: Time since quit bonus scores
QUIT_TIME_BONUS = {
    "Less than 3 years": 0.0,
    "3-5 years": 0.1,
    "6-10 years": 0.2,
    "11-20 years": 0.4,
    "More than 20 years": 0.6
}

SUBSTANCE_WEIGHTS = {
    "Tobacco": 15,
    "Nicotine": 4,
    "Alcohol": 10,
    "Recreational Drugs": 8,
    "OTC Meds": 6,
    "Other Substances": 6
}

# UPDATED: Substance questions with new time since quit questions
SUBSTANCE_QUESTIONS = {
    "Tobacco": {
        "current_band": "8.02",
        "current_years": "8.03",
        "current_trend": "8.04",
        "former_band": "8.22",
        "former_years": "8.21",
        "time_since_quit": "8.23",  # NEW
        "current_in_which": "Tobacco (cigarettes, cigars, smokeless tobacco)",
        "former_in_which": "Tobacco (cigarettes, cigars, smokeless tobacco)",
    },
    "Alcohol": {
        "current_band": "8.05",
        "current_years": "8.06",
        "current_trend": "8.07",
        "former_band": "8.25",
        "former_years": "8.24",
        "time_since_quit": "8.26",  # NEW
        "current_in_which": "Alcohol",
        "former_in_which": "Alcohol",
    },
    "Recreational Drugs": {
        "current_band": "8.08",
        "current_years": "8.09",
        "current_trend": "8.10",
        "former_band": "8.28",
        "former_years": "8.27",
        "time_since_quit": "8.29",  # NEW
        "current_in_which": "Recreational drugs (e.g., marijuana)",
        "former_in_which": "Recreational drugs (e.g., marijuana)",
    },
    "Nicotine": {
        "current_band": "8.11",
        "current_years": "8.12",
        "current_trend": "8.13",
        "former_band": "8.31",
        "former_years": "8.30",
        "time_since_quit": "8.32",  # NEW
        "current_in_which": "Nicotine",
        "former_in_which": "Nicotine",
    },
    "OTC Meds": {
        "current_band": "8.14",
        "current_years": "8.15",
        "current_trend": "8.16",
        "former_band": "8.34",
        "former_years": "8.33",
        "time_since_quit": "8.35",  # NEW
        "current_in_which": "Over-the-counter medications (e.g., sleep aids)",
        "former_in_which": "Over-the-counter medications (e.g., sleep aids)",
    },
    "Other Substances": {
        "current_band": "8.17",
        "current_years": "8.18",
        "current_trend": "8.19",
        "former_band": "8.37",
        "former_years": "8.36",
        "time_since_quit": "8.38",  # NEW
        "current_in_which": "Other",
        "former_in_which": "Other",
    }
}

# UPDATED: Enhanced substance scoring with time since quit
def score_substance_use(use_band, years_band, is_current, usage_trend=None, time_since_quit=None):
    band_level = use_band.split(":")[0].strip() if use_band else "Heavy"
    band_score = USE_BAND_SCORES.get(band_level, 0.0)
    duration_score = DURATION_SCORES.get(years_band, 0.0)
    base_score = min(band_score, duration_score)
    
    if not is_current:
        # NEW: Use graduated quit bonus based on time since quit
        if time_since_quit:
            quit_bonus = QUIT_TIME_BONUS.get(time_since_quit, 0.15)  # Default to old bonus if not found
        else:
            quit_bonus = 0.15  # Fallback to old bonus if no time data
        base_score = min(base_score + quit_bonus, 1.0)
    
    if is_current and usage_trend:
        if usage_trend == "I currently use more than I used to":
            base_score = max(base_score - 0.1, 0.0)  # Penalty for increasing use
        elif usage_trend == "I currently use less than I used to":
            base_score = min(base_score + 0.1, 1.0)  # Adjustment for past heavier use
    
    return base_score

# UPDATED: Get substance score with time since quit logic
def get_substance_score(patient_answers):
    substance_scores = {}
    for sub, qmap in SUBSTANCE_QUESTIONS.items():
        current_list = [x.strip() for x in str(patient_answers.get('8.01', '')).split('|')]
        former_list = [x.strip() for x in str(patient_answers.get('8.20', '')).split('|')]
        is_current = qmap['current_in_which'] in current_list
        is_former = (not is_current) and (qmap['former_in_which'] in former_list)
        score = 1.0  # default (never used = perfect)
        
        if is_current:
            use_band = patient_answers.get(qmap['current_band'], "")
            years_band = patient_answers.get(qmap['current_years'], "")
            usage_trend = patient_answers.get(qmap['current_trend'], "")
            score = score_substance_use(use_band, years_band, True, usage_trend)
        elif is_former:
            use_band = patient_answers.get(qmap['former_band'], "")
            years_band = patient_answers.get(qmap['former_years'], "")
            time_since_quit = patient_answers.get(qmap['time_since_quit'], "")  # NEW
            score = score_substance_use(use_band, years_band, False, time_since_quit=time_since_quit)
        
        weighted = score * SUBSTANCE_WEIGHTS[sub]
        substance_scores[sub] = weighted
    return substance_scores

# --- Screening Guidelines and Date Scoring Logic ---
screen_guidelines = {
    '10.01': 6,    # Dental exam: 6 months
    '10.02': 12,   # Skin check: 12 months
    '10.03': 12,   # Vision: 12 months
    '10.04': 120,  # Colon: 120 months (10 years)
    '10.05': 12,   # Mammogram: 12 months
    '10.06': 36,   # PAP: 36 months
    '10.07': 36,   # DEXA: 36 months
    '10.08': 36,   # PSA: 36 months
}

def score_date_response(date_str, window_months):
    if not date_str or pd.isnull(date_str):
        return 0
    try:
        exam_date = datetime.strptime(date_str, "%Y-%m-%d")
    except Exception:
        return 0
    today = datetime.today()
    months_ago = (today.year - exam_date.year) * 12 + (today.month - exam_date.month)
    if months_ago <= window_months:
        return 1.0
    elif months_ago <= int(window_months * 1.5):
        return 0.6
    else:
        return 0.2

# --- Pillars ---
PILLARS = [
    "Nutrition", "Movement", "Sleep", "Cognitive",
    "Stress", "Connection", "CoreCare"
]

# --- Centralized Question Map ---
# For each QID: define (score_map OR scoring_fn, pillar_weight_dict)
# If scoring_fn, it must accept the answer and return a score

# Extracted from preliminary_data
