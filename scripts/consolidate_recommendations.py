"""
Recommendation Consolidation Script

Uses AI to analyze and consolidate 227 messy recommendations into
clean, macro recommendations with readable IDs.

Process:
1. Load all existing recommendations
2. Use AI to group by concept
3. Extract best content from each group
4. Preserve biomarker/biometric mappings
5. Create clean recommendations with readable IDs
6. Generate SQL to insert consolidated recommendations
"""

import sys
import csv
import json
from typing import List, Dict, Any
import os
from dotenv import load_dotenv

sys.path.insert(0, '/Users/keegs/Documents/WellPath/wellpath-v2-backend')

# Load environment variables
load_dotenv('/Users/keegs/Documents/WellPath/wellpath-v2-backend/.env')

from anthropic import Anthropic


class RecommendationConsolidator:
    """Consolidates messy recommendations into clean macro recommendations."""

    def __init__(self):
        self.client = Anthropic(api_key=os.getenv('ANTHROPIC_API_KEY'))
        self.model = "claude-sonnet-4-20250514"
        self.recommendations = []

    def load_recommendations(self, csv_path: str):
        """Load recommendations from CSV export."""
        with open(csv_path, 'r') as f:
            reader = csv.DictReader(f)
            self.recommendations = list(reader)

        print(f"✓ Loaded {len(self.recommendations)} recommendations")

    def analyze_and_group(self) -> Dict[str, List[Dict[str, Any]]]:
        """Use AI to group recommendations by concept."""
        print("\n🤖 Using AI to analyze and group recommendations...")

        # Prepare summary for AI
        summary = []
        for rec in self.recommendations:
            summary.append({
                "rec_id": rec['rec_id'],
                "title": rec['title'],
                "type": rec['recommendation_type'],
                "level": rec.get('level', ''),
                "primary_biomarkers": rec.get('primary_biomarkers', ''),
                "raw_impact": rec.get('raw_impact', '')
            })

        prompt = f"""Analyze these {len(summary)} health recommendations and group them into macro concepts.

Many are variants of the same recommendation (different difficulty levels). Group these together.

Recommendations:
{json.dumps(summary, indent=2)}

Response Format (JSON):
{{
  "groups": [
    {{
      "concept_id": "readable_id_like_daily_steps",
      "concept_name": "Daily Steps Goal",
      "description": "Walking for cardiovascular health and metabolic function",
      "pillar": "movement",
      "rec_ids_in_group": ["REC0001.1", "REC0001.2", "REC0001.3"],
      "has_levels": true,
      "typical_range": "8,000-15,000 steps based on current level"
    }}
  ]
}}

Group similar recommendations together. Use clean, readable concept_ids (snake_case).
Identify the core concept that all variants represent."""

        try:
            response = self.client.messages.create(
                model=self.model,
                max_tokens=8000,
                temperature=0.3,
                messages=[{
                    "role": "user",
                    "content": prompt
                }]
            )

            response_text = response.content[0].text

            # Parse response
            if "```json" in response_text:
                json_start = response_text.find("```json") + 7
                json_end = response_text.find("```", json_start)
                json_str = response_text[json_start:json_end].strip()
            else:
                json_start = response_text.find("{")
                json_end = response_text.rfind("}") + 1
                json_str = response_text[json_start:json_end]

            result = json.loads(json_str)
            groups = result.get('groups', [])

            print(f"✓ AI identified {len(groups)} macro concepts")

            # Create groups dictionary
            grouped = {}
            for group in groups:
                concept_id = group['concept_id']
                grouped[concept_id] = {
                    'concept': group,
                    'recommendations': []
                }

                # Add actual recommendations to group
                for rec in self.recommendations:
                    if rec['rec_id'] in group['rec_ids_in_group']:
                        grouped[concept_id]['recommendations'].append(rec)

            return grouped

        except Exception as e:
            print(f"❌ Error in AI analysis: {str(e)}")
            return {}

    def consolidate_group(self, group_data: Dict[str, Any]) -> Dict[str, Any]:
        """Consolidate a group of recommendations into one clean recommendation."""
        concept = group_data['concept']
        recs = group_data['recommendations']

        print(f"\nConsolidating: {concept['concept_name']} ({len(recs)} variants)")

        # Aggregate biomarkers/biometrics (union of all variants)
        all_primary_biomarkers = set()
        all_secondary_biomarkers = set()
        all_tertiary_biomarkers = set()
        all_primary_biometrics = set()
        all_secondary_biometrics = set()
        all_tertiary_biometrics = set()

        for rec in recs:
            if rec.get('primary_biomarkers'):
                all_primary_biomarkers.update(rec['primary_biomarkers'].split(','))
            if rec.get('secondary_biomarkers'):
                all_secondary_biomarkers.update(rec['secondary_biomarkers'].split(','))
            if rec.get('tertiary_biomarkers'):
                all_tertiary_biomarkers.update(rec['tertiary_biomarkers'].split(','))
            if rec.get('primary_biometrics'):
                all_primary_biometrics.update(rec['primary_biometrics'].split(','))
            if rec.get('secondary_biometrics'):
                all_secondary_biometrics.update(rec['secondary_biometrics'].split(','))
            if rec.get('tertiary_biometrics'):
                all_tertiary_biometrics.update(rec['tertiary_biometrics'].split(','))

        # Get best overview (usually from level 1 or first variant)
        best_overview = next((r['overview'] for r in recs if r.get('overview')), '')

        # Get raw impact (use highest)
        raw_impacts = [int(r['raw_impact']) for r in recs if r.get('raw_impact') and r['raw_impact'].isdigit()]
        max_impact = max(raw_impacts) if raw_impacts else 50

        # Evidence (combine all)
        all_evidence = set()
        for rec in recs:
            if rec.get('evidence'):
                all_evidence.update(rec['evidence'].split(','))

        consolidated = {
            "id": concept['concept_id'],
            "name": concept['concept_name'],
            "description": best_overview or concept['description'],
            "agent_goal": self._generate_agent_goal(concept, recs),
            "pillar": concept['pillar'],
            "recommendation_type": recs[0].get('recommendation_type', 'Lifestyle'),
            "primary_biomarkers": sorted([b.strip() for b in all_primary_biomarkers if b.strip()]),
            "secondary_biomarkers": sorted([b.strip() for b in all_secondary_biomarkers if b.strip()]),
            "tertiary_biomarkers": sorted([b.strip() for b in all_tertiary_biomarkers if b.strip()]),
            "primary_biometrics": sorted([b.strip() for b in all_primary_biometrics if b.strip()]),
            "secondary_biometrics": sorted([b.strip() for b in all_secondary_biometrics if b.strip()]),
            "tertiary_biometrics": sorted([b.strip() for b in all_tertiary_biometrics if b.strip()]),
            "raw_impact": max_impact,
            "evidence_ids": sorted([e.strip() for e in all_evidence if e.strip()]),
            "has_difficulty_levels": concept.get('has_levels', False),
            "level_range": concept.get('typical_range', ''),
            "source_rec_ids": [r['rec_id'] for r in recs]
        }

        return consolidated

    def _generate_agent_goal(self, concept: Dict[str, Any], variants: List[Dict[str, Any]]) -> str:
        """Generate an agent_goal from the concept."""
        # Agent goal should be flexible - agent will determine specifics
        concept_name = concept['concept_name']

        # Common patterns
        if 'steps' in concept_name.lower():
            return "Walk daily to improve cardiovascular health and metabolic function"
        elif 'fiber' in concept_name.lower():
            return "Increase daily fiber intake to support gut health and cholesterol"
        elif 'zone 2' in concept_name.lower() or 'cardio' in concept_name.lower():
            return "Perform moderate-intensity cardio to build aerobic capacity"
        elif 'strength' in concept_name.lower():
            return "Strength training to maintain muscle mass and bone density"
        elif 'sleep' in concept_name.lower():
            return "Get consistent, sufficient sleep for recovery and health"
        else:
            # Generic goal - agent will interpret
            return f"Follow {concept_name} recommendation"

    def generate_insert_sql(self, consolidated: List[Dict[str, Any]]) -> str:
        """Generate SQL to insert consolidated recommendations."""
        sql_parts = [
            "-- Consolidated Recommendations",
            "-- Generated by AI consolidation script\n"
        ]

        for rec in consolidated:
            sql = f"""
INSERT INTO recommendations_base (
    rec_id,
    title,
    overview,
    agent_goal,
    pillar,
    recommendation_type,
    primary_biomarkers,
    secondary_biomarkers,
    tertiary_biomarkers,
    primary_biometrics,
    secondary_biometrics,
    tertiary_biometrics,
    raw_impact,
    evidence,
    agent_context,
    agent_enabled,
    is_active
) VALUES (
    '{rec['id']}',
    '{rec['name'].replace("'", "''")}',
    '{rec['description'][:500].replace("'", "''")}...',
    '{rec['agent_goal'].replace("'", "''")}',
    '{rec['pillar']}',
    '{rec['recommendation_type']}',
    '{','.join(rec['primary_biomarkers'])}',
    '{','.join(rec['secondary_biomarkers'])}',
    '{','.join(rec['tertiary_biomarkers'])}',
    '{','.join(rec['primary_biometrics'])}',
    '{','.join(rec['secondary_biometrics'])}',
    '{','.join(rec['tertiary_biometrics'])}',
    {rec['raw_impact']},
    '{','.join(rec['evidence_ids'][:10])}',
    '{{"has_difficulty_levels": {str(rec['has_difficulty_levels']).lower()}, "level_range": "{rec['level_range']}", "source_recs": {json.dumps(rec['source_rec_ids'][:5])}}}'::jsonb,
    true,
    true
) ON CONFLICT (rec_id) DO UPDATE SET
    agent_goal = EXCLUDED.agent_goal,
    agent_context = EXCLUDED.agent_context,
    agent_enabled = EXCLUDED.agent_enabled;
"""
            sql_parts.append(sql)

        return "\n".join(sql_parts)

    def run(self, csv_path: str, output_path: str):
        """Run the full consolidation process."""
        print("="*60)
        print("WellPath Recommendation Consolidation")
        print("="*60)

        # Load
        self.load_recommendations(csv_path)

        # Group
        grouped = self.analyze_and_group()

        if not grouped:
            print("❌ Failed to group recommendations")
            return

        # Consolidate each group
        consolidated = []
        for concept_id, group_data in grouped.items():
            clean_rec = self.consolidate_group(group_data)
            consolidated.append(clean_rec)

        # Generate SQL
        sql = self.generate_insert_sql(consolidated)

        # Save
        with open(output_path, 'w') as f:
            f.write(sql)

        # Save JSON for review
        json_path = output_path.replace('.sql', '.json')
        with open(json_path, 'w') as f:
            json.dump(consolidated, f, indent=2)

        print("\n" + "="*60)
        print(f"✓ Consolidated {len(self.recommendations)} → {len(consolidated)} recommendations")
        print(f"✓ SQL saved to: {output_path}")
        print(f"✓ JSON saved to: {json_path}")
        print("="*60)

        # Print summary
        print("\nConsolidated Recommendations:")
        for rec in consolidated[:10]:
            print(f"  - {rec['id']}: {rec['name']}")
            print(f"    Goal: {rec['agent_goal']}")
            print(f"    Impact: {rec['raw_impact']}/100")
            if rec['primary_biomarkers']:
                print(f"    Targets: {', '.join(rec['primary_biomarkers'][:3])}")
            print()


if __name__ == "__main__":
    consolidator = RecommendationConsolidator()
    consolidator.run(
        csv_path="/tmp/wellpath_recommendations_export.csv",
        output_path="/Users/keegs/Documents/WellPath/wellpath-v2-backend/database/migrations/consolidated_recommendations.sql"
    )
