"""
Biomarker Scoring Engine - Uses ranges and weights from MARKER_CONFIG
"""

import json
import os
from typing import Dict, Optional, List
from pathlib import Path


class BiomarkerScorer:
    """Scores biomarker values using configured ranges and pillar weights."""

    def __init__(self):
        # Load marker config
        config_path = Path(__file__).parent / 'configs' / 'marker_config.json'
        with open(config_path) as f:
            self.marker_config = json.load(f)

    def score_value(
        self,
        marker_key: str,
        value: float,
        patient_info: Optional[Dict] = None
    ) -> Dict:
        """
        Score a single biomarker value.

        Args:
            marker_key: Key in marker_config (e.g., 'hdl', 'ldl')
            value: Measured value
            patient_info: Optional patient context (age, sex, etc.)

        Returns:
            Dict with score, range_label, and pillar contributions
        """
        if marker_key not in self.marker_config:
            return {'error': f'Unknown marker: {marker_key}'}

        config = self.marker_config[marker_key]

        # Get the appropriate sub-config (could be gender/age specific)
        sub_config = self._get_sub_config(config['subs'], patient_info)

        if not sub_config:
            return {'error': f'No matching config for {marker_key}'}

        # Find the range this value falls into
        score, range_label = self._calculate_score(value, sub_config['ranges'])

        # Get max possible score for this sub
        max_score = self._get_max_score_for_sub(sub_config)

        # Calculate pillar contributions
        pillar_contributions = {}
        for pillar, weight in config['pillar_weights'].items():
            if weight > 0:
                pillar_contributions[pillar] = {
                    'raw_score': score,  # Already normalized 0-1
                    'weight': weight,
                    'weighted_score': score * weight,  # score is 0-1, weight is the actual weight
                    'max_score': max_score * weight  # Max for this marker in this pillar
                }

        return {
            'marker': config['name'],
            'value': value,
            'score': score,
            'max_score': max_score,
            'range_label': range_label,
            'pillar_contributions': pillar_contributions
        }

    def _get_sub_config(self, subs: List[Dict], patient_info: Optional[Dict]) -> Optional[Dict]:
        """
        Get the appropriate sub-config based on patient criteria.
        Matches preliminary_data select_sub logic exactly.
        """
        if not patient_info:
            return subs[0] if subs else None

        # Normalize patient info keys to lowercase
        patient = {k.lower(): str(v).lower() if isinstance(v, str) else v
                  for k, v in patient_info.items()}

        for sub in subs:
            match = True

            for key, val in sub.items():
                if key == "ranges":
                    continue

                # Age ranges
                if key in {"age_low", "age_min"}:
                    try:
                        if float(patient.get("age", -999)) < val:
                            match = False
                            break
                    except:
                        match = False
                        break
                    continue

                if key in {"age_high", "age_max"}:
                    try:
                        if float(patient.get("age", 9999)) > val:
                            match = False
                            break
                    except:
                        match = False
                        break
                    continue

                # Wildcards
                if val in ("all", None):
                    continue

                # Only match on keys that exist in patient
                if key not in patient:
                    continue

                patient_val = patient.get(key)

                # Case-insensitive string comparison
                if isinstance(val, str) and isinstance(patient_val, str):
                    if patient_val.lower() != val.lower():
                        match = False
                        break
                else:
                    if patient_val != val:
                        match = False
                        break

            if match:
                return sub

        # No match found - return first sub as fallback
        return subs[0] if subs else None

    def _calculate_score(self, value: float, ranges: List[Dict]) -> tuple:
        """Calculate score based on ranges."""
        for range_def in ranges:
            if range_def['min'] <= value <= range_def['max']:
                score = self._get_range_score(value, range_def)
                return score, range_def['label']

        # Value outside all ranges
        return 0.0, 'out_of_range'

    def _get_max_score_for_sub(self, sub: Dict) -> float:
        """
        Get maximum possible score for a sub-config.
        Returns the highest score across all ranges, normalized to 0-1.
        """
        max_score = 0.0
        for range_def in sub["ranges"]:
            if range_def["score_type"] == "fixed":
                max_score = max(max_score, range_def.get("score", 0) / 10.0)
            elif range_def["score_type"] == "linear":
                max_score = max(max_score,
                               range_def.get("score_start", 0) / 10.0,
                               range_def.get("score_end", 0) / 10.0)
        return max_score

    def _get_range_score(self, value: float, range_def: Dict) -> float:
        """
        Calculate score for a value within a specific range.
        Returns normalized score (0-1 range) by dividing by 10.
        """
        if range_def['score_type'] == 'fixed':
            return float(range_def['score']) / 10.0  # Normalize to 0-1

        elif range_def['score_type'] == 'linear':
            # Linear interpolation between score_start and score_end
            min_val = range_def['min']
            max_val = range_def['max']
            score_start = range_def['score_start']
            score_end = range_def['score_end']

            # Calculate position in range (0 to 1)
            position = (value - min_val) / (max_val - min_val) if max_val != min_val else 0

            # Interpolate score and normalize to 0-1
            score = score_start + (score_end - score_start) * position
            return float(score) / 10.0  # Normalize to 0-1

        return 0.0

    def score_patient_biomarkers(
        self,
        biomarkers: Dict[str, float],
        patient_info: Optional[Dict] = None
    ) -> Dict:
        """
        Score all biomarkers for a patient.

        Args:
            biomarkers: Dict of {marker_key: value}
            patient_info: Optional patient demographics

        Returns:
            Dict with pillar scores and marker details
        """
        pillar_scores = {}
        marker_details = []

        for marker_key, value in biomarkers.items():
            result = self.score_value(marker_key, value, patient_info)

            if 'error' not in result:
                marker_details.append(result)

                # Accumulate pillar scores
                for pillar, contribution in result['pillar_contributions'].items():
                    if pillar not in pillar_scores:
                        pillar_scores[pillar] = {
                            'total_raw_score': 0,
                            'total_weighted_score': 0,
                            'max_score': 0,
                            'markers': []
                        }

                    weight = contribution['weight']
                    pillar_scores[pillar]['total_raw_score'] += contribution['raw_score']
                    pillar_scores[pillar]['total_weighted_score'] += contribution['weighted_score']
                    pillar_scores[pillar]['max_score'] += contribution['max_score']  # Use max from contribution
                    pillar_scores[pillar]['markers'].append({
                        'marker': result['marker'],
                        'value': result['value'],
                        'score': result['score'],
                        'weight': weight
                    })

        # Calculate percentage scores for each pillar
        for pillar in pillar_scores:
            total = pillar_scores[pillar]['total_weighted_score']
            max_score = pillar_scores[pillar]['max_score']
            pillar_scores[pillar]['percentage'] = (total / max_score * 100) if max_score > 0 else 0

            # Add raw_score for breakdown (this is the actual summed score, not the weighted)
            pillar_scores[pillar]['raw_score'] = pillar_scores[pillar]['total_weighted_score']

        return {
            'pillar_scores': pillar_scores,
            'marker_details': marker_details
        }
