#!/usr/bin/env python3
"""
Map survey_questions_base to group_id from CSV
Updates the group_id column in survey_questions_base table
"""

import csv
import os
from supabase import create_client

# Load environment variables
from dotenv import load_dotenv
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_SERVICE_ROLE_KEY')

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

def load_csv_mapping(csv_path):
    """Load question_id -> group_id mapping from CSV"""
    mapping = {}
    with open(csv_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            question_id = row['question_id']
            group_id = row['group_id']
            mapping[question_id] = group_id

    print(f"✓ Loaded {len(mapping)} question mappings from CSV")
    return mapping

def get_survey_groups():
    """Get all survey groups to validate group_id exists"""
    response = supabase.table('survey_groups').select('group_id, group_name').execute()
    groups = {g['group_id']: g['group_name'] for g in response.data}
    print(f"✓ Found {len(groups)} survey groups in database")
    return groups

def update_question_groups(mapping, valid_groups):
    """Update survey_questions_base with group_id from mapping"""

    # Get all questions
    response = supabase.table('survey_questions_base').select('question_id, question_number').execute()
    questions = response.data
    print(f"✓ Found {len(questions)} questions in survey_questions_base")

    matched = 0
    unmatched = []
    invalid_groups = []

    for question in questions:
        question_number = question['question_number']

        if question_number in mapping:
            group_id = mapping[question_number]

            # Validate group_id exists
            if group_id in valid_groups:
                # Update the question
                supabase.table('survey_questions_base').update({
                    'group_id': group_id
                }).eq('question_id', question['question_id']).execute()

                matched += 1
                if matched % 50 == 0:
                    print(f"  Updated {matched} questions...")
            else:
                invalid_groups.append({
                    'question': question_number,
                    'group_id': group_id
                })
        else:
            unmatched.append(question_number)

    print(f"\n{'='*60}")
    print(f"RESULTS")
    print(f"{'='*60}")
    print(f"✓ Matched and updated: {matched} questions")

    if unmatched:
        print(f"\n⚠️  Unmatched questions (no mapping in CSV): {len(unmatched)}")
        print(f"   First 10: {unmatched[:10]}")

    if invalid_groups:
        print(f"\n❌ Invalid group_ids (not in survey_groups): {len(invalid_groups)}")
        for item in invalid_groups[:10]:
            print(f"   Question {item['question']}: group_id='{item['group_id']}'")

    return matched, unmatched, invalid_groups

def main():
    csv_path = '/Users/keegs/Documents/survey_categories_mapped.csv'

    print("="*60)
    print("Survey Question Group Mapping")
    print("="*60)
    print(f"CSV: {csv_path}\n")

    # Load CSV mapping
    mapping = load_csv_mapping(csv_path)

    # Get valid groups
    valid_groups = get_survey_groups()

    # Update questions
    matched, unmatched, invalid = update_question_groups(mapping, valid_groups)

    print(f"\n{'='*60}")
    print("DONE!")
    print(f"{'='*60}")

if __name__ == '__main__':
    main()
