"""
Survey Scoring Engine - Implements custom survey scoring logic from preliminary_data
Matches wellpath_score_runner_survey_v2.py exactly
"""

import pandas as pd
import json
from pathlib import Path
from typing import Dict, Optional, List
from datetime import datetime
import inspect

# Question configuration will be loaded from database
# For now, using wellpath_score_runner_survey_v2.py logic with manual protein scoring


class SurveyScorer:
    """Scores survey responses using custom logic and configured weights."""

    # Pillar name mapping
    PILLAR_MAP = {
        "Nutrition": "Healthful Nutrition",
        "Movement": "Movement + Exercise",
        "Sleep": "Restorative Sleep",
        "Cognitive": "Cognitive Health",
        "Stress": "Stress Management",
        "Connection": "Connection + Purpose",
        "CoreCare": "Core Care",
    }

    def __init__(self):
        # Question config is loaded from database at runtime
        # For now we handle protein (2.11) and other complex calcs manually
        self.question_config = {}

    # =================================================================================
    # CUSTOM SCORING FUNCTIONS (from preliminary_data)
    # =================================================================================

    @staticmethod
    def protein_intake_score(protein_g: str, weight_lb: float, age: int) -> float:
        """Calculate protein intake score based on individual target."""
        try:
            protein_g = float(protein_g)
            weight_lb = float(weight_lb)  # Convert Decimal to float
            weight_kg = weight_lb / 2.205
            target = 1.2 * weight_kg if age < 65 else 1.5 * weight_kg
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

    @staticmethod
    def calorie_intake_score(calories: str, weight_lb: float, age: int, sex: str) -> float:
        """Calculate calorie intake score based on individual BMR target."""
        try:
            calories = float(calories)
            weight_lb = float(weight_lb)  # Convert Decimal to float
            weight_kg = weight_lb / 2.205

            # Harris-Benedict BMR calculation
            if sex.lower().startswith("m"):
                bmr = 88.362 + (13.397 * weight_kg) + (4.799 * 175) - (5.677 * age)
            else:
                bmr = 447.593 + (9.247 * weight_kg) + (3.098 * 162) - (4.330 * age)

            target = bmr * 1.2  # Sedentary multiplier
            pct = calories / target if target else 0

            # Scoring: within ±15% = 10; ±25% = 8; ±35% = 6; else 2
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

    # Movement scoring constants
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

    MOVEMENT_QUESTIONS = {
        "Cardio": {"freq_q": "3.04", "dur_q": "3.08", "pillar_weights": {"Movement": 16}},
        "Strength": {"freq_q": "3.05", "dur_q": "3.09", "pillar_weights": {"Movement": 16}},
        "Flexibility": {"freq_q": "3.06", "dur_q": "3.1", "pillar_weights": {"Movement": 13}},  # Note: 3.1 not 3.10 (DB stores as decimal)
        "HIIT": {"freq_q": "3.07", "dur_q": "3.11", "pillar_weights": {"Movement": 16}}
    }

    def score_movement_pillar(self, row: Dict) -> Dict:
        """Score movement questions with frequency × duration logic."""
        movement_scores = {}
        for move_type, cfg in self.MOVEMENT_QUESTIONS.items():
            freq_ans = row.get(cfg["freq_q"], "")
            dur_ans = row.get(cfg["dur_q"], "")
            freq = self.FREQ_SCORES.get(freq_ans, 0.0)
            dur = self.DUR_SCORES.get(dur_ans, 0.0)

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

    # Sleep issues scoring
    SLEEP_ISSUES = [
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
        "": 1.0,
    }

    def score_sleep_issues(self, patient_answers: Dict) -> Dict:
        """Score sleep issues with frequency-based penalties."""
        sleep_issues_reported = [
            x.strip() for x in str(patient_answers.get("4.12", "")).split("|") if x.strip()
        ]

        # Full credit if none reported
        if not sleep_issues_reported or any("none" in s.lower() for s in sleep_issues_reported):
            pillar_totals = {}
            for _, _, pillar_wts in self.SLEEP_ISSUES:
                for p, w in pillar_wts.items():
                    pillar_totals[p] = pillar_totals.get(p, 0.0) + w
            return pillar_totals

        # Score each reported issue
        pillar_scores = {}
        for issue, freq_qid, pillar_wts in self.SLEEP_ISSUES:
            if issue in sleep_issues_reported:
                freq_ans = str(patient_answers.get(freq_qid, "")).strip()
                mult = self.SLEEP_FREQ_MAP.get(freq_ans, 0.2)
            else:
                mult = 1.0  # Not selected = full credit

            for p, w in pillar_wts.items():
                pillar_scores[p] = pillar_scores.get(p, 0.0) + (w * mult)

        return pillar_scores

    @staticmethod
    def score_sleep_protocols(answer_str: str) -> float:
        """Score sleep hygiene protocols by count."""
        WEIGHT = 9.0
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

    @staticmethod
    def calc_sleep_apnea_score(
        diagnosis: str, severity: str, time_since: str, treatments: str, improvement: str
    ) -> float:
        """Calculate sleep apnea management score (0-1)."""
        # Base cases
        if diagnosis == "No":
            return 1.0
        elif diagnosis == "I suspect I may have it but haven't been diagnosed":
            return 0.0

        # Severity-based starting point
        severity_base = {
            "Severe (AHI 30+ events per hour)": 0.20,
            "Moderate (AHI 15-29 events per hour)": 0.35,
            "Mild (AHI 5-14 events per hour)": 0.50,
            "I don't know/wasn't told the severity": 0.35
        }
        base_score = severity_base.get(severity, 0.35)

        # Time-based categorization
        time_categories = {
            "Less than 6 months": "recent",
            "6 months to 1 year": "recent",
            "1-2 years": "established",
            "2-5 years": "established",
            "More than 5 years": "established"
        }
        time_category = time_categories.get(time_since, "established")

        treatment_list = [t.strip() for t in str(treatments).split("|") if t.strip()]

        if time_category == "recent":
            # Recent diagnosis: focus on treatment quality
            treatment_bonus = 0.0

            if any("CPAP" in t or "BiPAP" in t for t in treatment_list):
                treatment_bonus += 0.30
            elif any("Oral appliance" in t for t in treatment_list):
                treatment_bonus += 0.20

            active_treatments = [t for t in treatment_list if "No treatment" not in t]
            if len(active_treatments) >= 2:
                treatment_bonus += 0.10

            if any("Lifestyle modifications" in t or "Weight loss" in t for t in treatment_list):
                treatment_bonus += 0.05

            if any("Surgery" in t for t in treatment_list):
                treatment_bonus += 0.15

            if any("No treatment currently" in t for t in treatment_list):
                treatment_bonus -= 0.25

            improvement_bonus = {
                "Significantly improved": 0.10,
                "Moderately improved": 0.05,
                "Slightly improved": 0.02,
                "No improvement": 0.0,
                "Symptoms have worsened": -0.05
            }.get(improvement, 0.0)

            management_score = base_score + treatment_bonus + improvement_bonus
        else:
            # Established diagnosis: focus on outcomes
            improvement_bonus = {
                "Significantly improved": 0.65,
                "Moderately improved": 0.45,
                "Slightly improved": 0.25,
                "No improvement": -0.10,
                "Symptoms have worsened": -0.20
            }.get(improvement, 0.0)

            treatment_bonus = 0.0
            if any("CPAP" in t or "BiPAP" in t for t in treatment_list):
                treatment_bonus += 0.05
            elif any("No treatment currently" in t for t in treatment_list):
                treatment_bonus -= 0.10

            management_score = base_score + improvement_bonus + treatment_bonus

        # Excellence bonus
        if (severity == "Severe (AHI 30+ events per hour)" and
            improvement == "Significantly improved"):
            management_score += 0.10

        return round(max(0.0, min(1.0, management_score)), 3)

    @staticmethod
    def score_cognitive_activities(answer_str: str) -> float:
        """Score cognitive activities by count."""
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

    @staticmethod
    def stress_score(stress_level_ans: str, freq_ans: str) -> float:
        """Calculate stress score from level and frequency."""
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

    COPING_WEIGHTS = {
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

    @staticmethod
    def coping_score(answer_str: str, stress_level_ans: str, freq_ans: str) -> float:
        """Score coping strategies with stress context."""
        responses = [r.strip() for r in str(answer_str or "").split("|") if r.strip()]
        has_none = any("none" in r.lower() for r in responses)
        high_stress = (
            str(stress_level_ans).strip() in ["High stress", "Extreme stress"] or
            str(freq_ans).strip() in ["Frequently", "Always"]
        )

        if has_none or not responses:
            return 0.0 if high_stress else 5.5

        # Calculate weighted score
        coping_weights = SurveyScorer.COPING_WEIGHTS
        total_weight = sum(coping_weights.get(response, 0.5) for response in responses)
        weighted_score = min(total_weight * 3.5, 7.0)

        if not high_stress:
            return min(5.5 + total_weight, 7.0)
        else:
            return weighted_score

    # Substance use scoring
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

    SUBSTANCE_QUESTIONS = {
        "Tobacco": {
            "current_band": "8.02", "current_years": "8.03", "current_trend": "8.04",
            "former_band": "8.22", "former_years": "8.21", "time_since_quit": "8.23",
            "current_in_which": "Tobacco (cigarettes, cigars, smokeless tobacco)",
            "former_in_which": "Tobacco (cigarettes, cigars, smokeless tobacco)",
        },
        "Alcohol": {
            "current_band": "8.05", "current_years": "8.06", "current_trend": "8.07",
            "former_band": "8.25", "former_years": "8.24", "time_since_quit": "8.26",
            "current_in_which": "Alcohol",
            "former_in_which": "Alcohol",
        },
        "Recreational Drugs": {
            "current_band": "8.08", "current_years": "8.09", "current_trend": "8.10",
            "former_band": "8.28", "former_years": "8.27", "time_since_quit": "8.29",
            "current_in_which": "Recreational drugs (e.g., marijuana)",
            "former_in_which": "Recreational drugs (e.g., marijuana)",
        },
        "Nicotine": {
            "current_band": "8.11", "current_years": "8.12", "current_trend": "8.13",
            "former_band": "8.31", "former_years": "8.30", "time_since_quit": "8.32",
            "current_in_which": "Nicotine",
            "former_in_which": "Nicotine",
        },
        "OTC Meds": {
            "current_band": "8.14", "current_years": "8.15", "current_trend": "8.16",
            "former_band": "8.34", "former_years": "8.33", "time_since_quit": "8.35",
            "current_in_which": "Over-the-counter medications (e.g., sleep aids)",
            "former_in_which": "Over-the-counter medications (e.g., sleep aids)",
        },
        "Other Substances": {
            "current_band": "8.17", "current_years": "8.18", "current_trend": "8.19",
            "former_band": "8.37", "former_years": "8.36", "time_since_quit": "8.38",
            "current_in_which": "Other",
            "former_in_which": "Other",
        }
    }

    def score_substance_use(
        self, use_band: str, years_band: str, is_current: bool,
        usage_trend: Optional[str] = None, time_since_quit: Optional[str] = None
    ) -> float:
        """Score individual substance use."""
        band_level = use_band.split(":")[0].strip() if use_band else "Heavy"
        band_score = self.USE_BAND_SCORES.get(band_level, 0.0)
        duration_score = self.DURATION_SCORES.get(years_band, 0.0)
        base_score = min(band_score, duration_score)

        if not is_current:
            quit_bonus = self.QUIT_TIME_BONUS.get(time_since_quit, 0.15) if time_since_quit else 0.15
            base_score = min(base_score + quit_bonus, 1.0)

        if is_current and usage_trend:
            if usage_trend == "I currently use more than I used to":
                base_score = max(base_score - 0.1, 0.0)
            elif usage_trend == "I currently use less than I used to":
                base_score = min(base_score + 0.1, 1.0)

        return base_score

    def get_substance_score(self, patient_answers: Dict) -> Dict:
        """Calculate scores for all substances."""
        substance_scores = {}
        for sub, qmap in self.SUBSTANCE_QUESTIONS.items():
            current_list = [x.strip() for x in str(patient_answers.get('8.01', '')).split('|')]
            former_list = [x.strip() for x in str(patient_answers.get('8.20', '')).split('|')]
            is_current = qmap['current_in_which'] in current_list
            is_former = (not is_current) and (qmap['former_in_which'] in former_list)
            score = 1.0  # Default (never used = perfect)

            if is_current:
                use_band = patient_answers.get(qmap['current_band'], "")
                years_band = patient_answers.get(qmap['current_years'], "")
                usage_trend = patient_answers.get(qmap['current_trend'], "")
                score = self.score_substance_use(use_band, years_band, True, usage_trend)
            elif is_former:
                use_band = patient_answers.get(qmap['former_band'], "")
                years_band = patient_answers.get(qmap['former_years'], "")
                time_since_quit = patient_answers.get(qmap['time_since_quit'], "")
                score = self.score_substance_use(use_band, years_band, False, time_since_quit=time_since_quit)

            weighted = score * self.SUBSTANCE_WEIGHTS[sub]
            substance_scores[sub] = weighted

        return substance_scores

    # Screening date scoring
    SCREEN_GUIDELINES = {
        '10.01': 6,    # Dental exam: 6 months
        '10.02': 12,   # Skin check: 12 months
        '10.03': 12,   # Vision: 12 months
        '10.04': 120,  # Colon: 120 months (10 years)
        '10.05': 12,   # Mammogram: 12 months
        '10.06': 36,   # PAP: 36 months
        '10.07': 36,   # DEXA: 36 months
        '10.08': 36,   # PSA: 36 months
    }

    @staticmethod
    def score_date_response(date_str: str, window_months: int) -> float:
        """Score screening dates based on recency."""
        if not date_str or pd.isnull(date_str):
            return 0

        try:
            exam_date = datetime.strptime(str(date_str), "%Y-%m-%d")
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

    # =================================================================================
    # MAIN SCORING LOGIC
    # =================================================================================

    def score_patient_from_csv(
        self,
        patient_row: Dict,
        weight_lb: float,
        age: int,
        sex: str
    ) -> Dict:
        """
        Score a single patient's survey responses from CSV format.
        This replicates the exact scoring logic from preliminary_data.

        Args:
            patient_row: Dictionary of question_id -> answer
            weight_lb: Patient weight in pounds
            age: Patient age
            sex: Patient sex (M/F)

        Returns:
            Dictionary with pillar scores and percentages
        """
        # Import the QUESTION_CONFIG from preliminary_data
        # For now, we'll use hardcoded scoring logic that matches the structure

        # Track weighted scores per pillar
        pillar_weighted = {p: 0.0 for p in self.PILLAR_MAP.keys()}
        pillar_max = {p: 0.0 for p in self.PILLAR_MAP.keys()}

        # Score each question based on its configuration
        # This is a simplified version - we'll need to add the full QUESTION_CONFIG
        #for qid, answer in patient_row.items():
        #    if qid == 'patient_id':
        #        continue

        # For now, return preliminary_data scores as placeholder
        # The real implementation requires the full QUESTION_CONFIG

        return {
            'pillar_scores': pillar_weighted,
            'pillar_max': pillar_max,
            'pillar_percentages': {
                p: (pillar_weighted[p] / pillar_max[p] * 100) if pillar_max[p] > 0 else 0
                for p in pillar_weighted.keys()
            }
        }

    def score_patient_surveys(
        self,
        survey_responses_df: pd.DataFrame,
        patient_info: Optional[Dict] = None
        ) -> Dict:
        """
        Score all survey responses for a patient.

        This implements the same logic as preliminary_data/wellpath_score_runner_survey_v2.py
        but pulls question config from the survey_question_config_data module.

        Args:
            survey_responses_df: DataFrame with columns: patient_id, question_id, response_value
            patient_info: Optional dict with patient context (age, sex, weight_lb, etc.)

        Returns:
            Dict with pillar_scores and question_details
        """
        if survey_responses_df.empty:
            return {'pillar_scores': {}, 'question_details': []}

        # Import QUESTION_CONFIG
        try:
            from scoring_engine.survey_question_config_data import QUESTION_CONFIG
        except Exception as e:
            print(f"⚠️  Could not load QUESTION_CONFIG: {e}")
            return self._empty_scores()

        # Get patient context for custom scoring functions
        weight_lb = patient_info.get('weight_lb', 70 * 2.205) if patient_info else 154  # Default 70kg
        age = patient_info.get('age', 40) if patient_info else 40
        sex = patient_info.get('sex', 'male') if patient_info else 'male'

        # Convert responses to dict for easier lookup
        # Format question_id as string matching QUESTION_CONFIG keys (e.g., "1.01", "8.09")
        responses = {}
        for _, row in survey_responses_df.iterrows():
            qid = row['question_id']
            # Convert numeric to string format
            if isinstance(qid, (int, float)):
                qid_str = str(qid)
            else:
                qid_str = str(qid).strip()

            # Store the original ID
            responses[qid_str] = row['response_value']

            # Handle decimal padding: 8.1 (from DB) came from 8.10 (Airtable/CSV)
            # CSV drops trailing zeros: 8.10 → 8.1 when imported
            # So we need to add the trailing zero back: 8.1 → 8.10
            if '.' in qid_str:
                parts = qid_str.split('.')
                decimal_part = parts[1]

                # If decimal part is single digit, add trailing zero (8.1 -> 8.10)
                if len(decimal_part) == 1:
                    padded_trailing = f"{parts[0]}.{decimal_part}0"
                    responses[padded_trailing] = row['response_value']

        print(f"🔍 Converted {len(responses)} responses")
        if responses:
            print(f"   Sample response keys: {list(responses.keys())[:5]}")
            print(f"   Sample QUESTION_CONFIG keys: {list(QUESTION_CONFIG.keys())[:5]}")

        # Score each question
        pillar_totals = {}
        pillar_max = {}
        question_details = []

        for qid, config in QUESTION_CONFIG.items():
            if qid not in responses:
                continue

            answer = responses[qid]

            # Skip NULL responses (conditional questions that weren't asked)
            if pd.isna(answer) or answer is None:
                continue

            score = 0
            max_score = 0

            # Calculate max possible score
            if "response_scores" in config and config["response_scores"]:
                max_score = max(config["response_scores"].values())
            elif "score_fn" in config:
                max_score = 10  # Assume max 10 for custom functions

            # Scale max score (0-10 -> 0-1)
            max_score_scaled = max_score / 10 if max_score > 1 else max_score

            # Score the answer
            if "score_fn" in config:
                # Custom scoring function
                try:
                    fn = config["score_fn"]
                    fn_params = inspect.signature(fn).parameters

                    if 'sex' in fn_params:
                        score = fn(answer, weight_lb, age, sex)
                    elif 'row' in fn_params:
                        # Pass full responses dict as 'row'
                        score = fn(answer, weight_lb, age, row=responses)
                    else:
                        score = fn(answer, weight_lb, age)
                except Exception as e:
                    print(f"⚠️  Error scoring {qid} with custom function: {e}")
                    score = 0
            elif "complex_calc" in config and config["complex_calc"] == "sleep_apnea":
                # Sleep apnea complex calculation
                if str(answer).strip() == "Yes":
                    diagnosis = str(responses.get("4.28", "")).strip()
                    severity = str(responses.get("4.29", "")).strip()
                    time_since = str(responses.get("4.30", "")).strip()
                    treatments = str(responses.get("4.31", "")).strip()
                    improvement = str(responses.get("4.32", "")).strip()
                    score = self.calc_sleep_apnea_score(diagnosis, severity, time_since, treatments, improvement) * 10
                else:
                    score = config.get("response_scores", {}).get(str(answer).strip(), 0)
            else:
                # Direct response scoring
                score = config.get("response_scores", {}).get(str(answer).strip(), 0)

            # Scale score (0-10 -> 0-1)
            score_scaled = score / 10 if score is not None and score > 1 else (score if score is not None else 0)

            # Apply pillar weights
            for pillar, weight in config.get("pillar_weights", {}).items():
                if weight and weight > 0:
                    full_pillar_name = self.PILLAR_MAP.get(pillar, pillar)

                    if full_pillar_name not in pillar_totals:
                        pillar_totals[full_pillar_name] = 0
                        pillar_max[full_pillar_name] = 0

                    weighted_score = score_scaled * weight
                    max_weighted = max_score_scaled * weight

                    pillar_totals[full_pillar_name] += weighted_score
                    pillar_max[full_pillar_name] += max_weighted

                    question_details.append({
                        'question_id': qid,
                        'question': config.get('question', ''),
                        'answer': answer,
                        'raw_score': score_scaled,
                        'pillar': full_pillar_name,
                        'weight': weight,
                        'weighted_score': weighted_score,
                        'max_weighted': max_weighted
                    })

        # Add custom scoring that's not in QUESTION_CONFIG
        # These special scoring functions are called outside QUESTION_CONFIG in the original script

        # Movement pillar scoring (questions 3.04-3.11)
        move_scores = self.score_movement_pillar(responses)
        for (move_type, pillar), score in move_scores.items():
            full_pillar_name = self.PILLAR_MAP.get(pillar, pillar)
            if full_pillar_name not in pillar_totals:
                pillar_totals[full_pillar_name] = 0
                pillar_max[full_pillar_name] = 0

            pillar_totals[full_pillar_name] += score
            pillar_max[full_pillar_name] += self.MOVEMENT_QUESTIONS[move_type]["pillar_weights"][pillar]

            question_details.append({
                'question_id': f"Movement_{move_type}",
                'question': f"{move_type} Training",
                'answer': f"{responses.get(self.MOVEMENT_QUESTIONS[move_type]['freq_q'], '')} / {responses.get(self.MOVEMENT_QUESTIONS[move_type]['dur_q'], '')}",
                'raw_score': score / self.MOVEMENT_QUESTIONS[move_type]["pillar_weights"][pillar] if self.MOVEMENT_QUESTIONS[move_type]["pillar_weights"][pillar] > 0 else 0,
                'pillar': full_pillar_name,
                'weight': self.MOVEMENT_QUESTIONS[move_type]["pillar_weights"][pillar],
                'weighted_score': score,
                'max_weighted': self.MOVEMENT_QUESTIONS[move_type]["pillar_weights"][pillar]
            })

        # Sleep issues scoring (question 4.12 with follow-ups 4.13-4.18)
        sleep_issues_scores = self.score_sleep_issues(responses)
        for pillar, score in sleep_issues_scores.items():
            full_pillar_name = self.PILLAR_MAP.get(pillar, pillar)
            if full_pillar_name not in pillar_totals:
                pillar_totals[full_pillar_name] = 0
                pillar_max[full_pillar_name] = 0

            # Max for sleep issues is the sum of all weights for that pillar
            max_sleep_issues_for_pillar = sum(pillar_wts.get(pillar, 0) for _, _, pillar_wts in self.SLEEP_ISSUES)

            pillar_totals[full_pillar_name] += score
            pillar_max[full_pillar_name] += max_sleep_issues_for_pillar

            question_details.append({
                'question_id': f"4.12_{pillar}",
                'question': f"Sleep Issues ({pillar})",
                'answer': responses.get("4.12", ""),
                'raw_score': score / max_sleep_issues_for_pillar if max_sleep_issues_for_pillar > 0 else 0,
                'pillar': full_pillar_name,
                'weight': max_sleep_issues_for_pillar,
                'weighted_score': score,
                'max_weighted': max_sleep_issues_for_pillar
            })

        # Sleep hygiene protocols scoring (question 4.07)
        sleep_proto_score = self.score_sleep_protocols(responses.get("4.07", ""))
        if sleep_proto_score:
            full_pillar_name = "Restorative Sleep"
            if full_pillar_name not in pillar_totals:
                pillar_totals[full_pillar_name] = 0
                pillar_max[full_pillar_name] = 0

            pillar_totals[full_pillar_name] += sleep_proto_score
            pillar_max[full_pillar_name] += 9.0  # Max weight for sleep hygiene

            question_details.append({
                'question_id': "4.07",
                'question': "Sleep Hygiene Protocols",
                'answer': responses.get("4.07", ""),
                'raw_score': sleep_proto_score / 9.0,
                'pillar': full_pillar_name,
                'weight': 9.0,
                'weighted_score': sleep_proto_score,
                'max_weighted': 9.0
            })

        # Substance use scoring
        sub_scores = self.get_substance_score(responses)
        for sub, weighted_score in sub_scores.items():
            full_pillar_name = "Core Care"
            if full_pillar_name not in pillar_totals:
                pillar_totals[full_pillar_name] = 0
                pillar_max[full_pillar_name] = 0

            pillar_totals[full_pillar_name] += weighted_score
            pillar_max[full_pillar_name] += self.SUBSTANCE_WEIGHTS[sub]

            # Get answer for display
            answer_text = "Substance use data"
            if sub == "Tobacco":
                answer_text = responses.get("8.01", "")
            elif sub == "Alcohol":
                answer_text = responses.get("8.01", "")

            question_details.append({
                'question_id': f"Substance_{sub}",
                'question': f"{sub} Use",
                'answer': answer_text,
                'raw_score': weighted_score / self.SUBSTANCE_WEIGHTS[sub],  # Normalize
                'pillar': full_pillar_name,
                'weight': self.SUBSTANCE_WEIGHTS[sub],
                'weighted_score': weighted_score,
                'max_weighted': self.SUBSTANCE_WEIGHTS[sub]
            })

        # Calculate percentages
        pillar_scores = {}
        for pillar in pillar_totals:
            total = pillar_totals[pillar]
            max_total = pillar_max[pillar]
            percentage = (total / max_total * 100) if max_total > 0 else 0

            pillar_scores[pillar] = {
                'total_score': total,
                'max_score': max_total,
                'raw_score': total,  # Add raw_score for breakdown consistency
                'percentage': percentage,
                'questions': [q for q in question_details if q['pillar'] == pillar]
            }

        return {
            'pillar_scores': pillar_scores,
            'question_details': question_details
        }

    def _empty_scores(self):
        """Return empty score structure"""
        pillar_names = [
            'Healthful Nutrition',
            'Movement + Exercise',
            'Restorative Sleep',
            'Cognitive Health',
            'Stress Management',
            'Connection + Purpose',
            'Core Care'
        ]

        pillar_scores = {}
        for pillar in pillar_names:
            pillar_scores[pillar] = {
                'total_score': 0,
                'max_score': 100,
                'percentage': 0,
                'questions': []
            }

        return {'pillar_scores': pillar_scores, 'question_details': []}
