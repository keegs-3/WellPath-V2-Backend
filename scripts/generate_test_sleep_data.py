"""
Generate Test Sleep Data for Display Screens Testing

This script generates realistic sleep data for test patients to validate
the new display screens architecture in the mobile app.

Date: 2025-10-12
"""

import os
import sys
from datetime import datetime, timedelta
from dotenv import load_dotenv
from supabase import create_client, Client

# Load environment variables
load_dotenv()

SUPABASE_URL = os.getenv('SUPABASE_URL')
SUPABASE_KEY = os.getenv('SUPABASE_KEY')

if not SUPABASE_URL or not SUPABASE_KEY:
    print("Error: SUPABASE_URL and SUPABASE_KEY must be set in .env file")
    sys.exit(1)

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def get_test_patient():
    """Get the first test patient from the database"""
    result = supabase.table('patient_details').select('id, user_id, first_name, last_name').limit(1).execute()
    if result.data and len(result.data) > 0:
        patient = result.data[0]
        print(f"Using test patient: {patient['first_name']} {patient['last_name']} (ID: {patient['id']})")
        return patient
    else:
        print("Error: No patients found in database")
        sys.exit(1)

def generate_sleep_data_for_week(patient_id, start_date=None):
    """
    Generate 7 days of sleep data for a patient

    Data includes:
    - Sleep start/end times
    - Sleep stages (REM, Deep, Core, Awake)
    - Total sleep duration
    """
    if start_date is None:
        start_date = datetime.now().date() - timedelta(days=7)

    sleep_data = []

    for day_offset in range(7):
        current_date = start_date + timedelta(days=day_offset)

        # Generate realistic sleep times (vary slightly each night)
        import random

        # Bedtime between 10 PM and 11:30 PM
        bed_hour = 22 + random.randint(0, 90) / 60.0
        bed_time = current_date.replace(hour=int(bed_hour), minute=int((bed_hour % 1) * 60))

        # Wake time between 6 AM and 8 AM next day
        wake_hour = 6 + random.randint(0, 120) / 60.0
        wake_time = (current_date + timedelta(days=1)).replace(hour=int(wake_hour), minute=int((wake_hour % 1) * 60))

        # Calculate total time in bed (hours)
        time_in_bed_hours = (wake_time - bed_time).total_seconds() / 3600

        # Total sleep is usually 85-95% of time in bed
        sleep_efficiency = 0.85 + random.random() * 0.10
        total_sleep_hours = time_in_bed_hours * sleep_efficiency

        # Sleep stages distribution (percentages of total sleep)
        rem_pct = 0.20 + random.random() * 0.05  # 20-25%
        deep_pct = 0.15 + random.random() * 0.05  # 15-20%
        core_pct = 1 - rem_pct - deep_pct - 0.05  # Rest minus awake
        awake_pct = 0.05  # 5% awake during night

        rem_hours = total_sleep_hours * rem_pct
        deep_hours = total_sleep_hours * deep_pct
        core_hours = total_sleep_hours * core_pct
        awake_hours = time_in_bed_hours - total_sleep_hours

        sleep_data.append({
            'date': str(current_date),
            'bed_time': bed_time.isoformat(),
            'wake_time': wake_time.isoformat(),
            'time_in_bed_hours': round(time_in_bed_hours, 2),
            'total_sleep_hours': round(total_sleep_hours, 2),
            'rem_hours': round(rem_hours, 2),
            'deep_hours': round(deep_hours, 2),
            'core_hours': round(core_hours, 2),
            'awake_hours': round(awake_hours, 2),
        })

    return sleep_data

def insert_display_metrics_readings(patient_id, sleep_data):
    """
    Insert sleep data into display_metrics_readings table

    This is where the frontend will query from to get user data.
    Each metric (Time in Bed, Total Sleep, REM, Deep, Core, Awake) gets its own row.
    """
    readings = []

    for day_data in sleep_data:
        date = day_data['date']

        # DM_225 - Time In Bed (hours converted to minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_225',
            'value': day_data['time_in_bed_hours'] * 60,  # Convert to minutes
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

        # DM_231 - Total Sleep Duration (hours converted to minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_231',
            'value': day_data['total_sleep_hours'] * 60,  # Convert to minutes
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

        # DM_221 - REM Sleep (minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_221',
            'value': day_data['rem_hours'] * 60,
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

        # DM_222 - Deep Sleep (minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_222',
            'value': day_data['deep_hours'] * 60,
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

        # DM_223 - Core Sleep (minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_223',
            'value': day_data['core_hours'] * 60,
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

        # DM_224 - Awake Time (minutes)
        readings.append({
            'patient_id': patient_id,
            'display_metric_id': 'DM_224',
            'value': day_data['awake_hours'] * 60,
            'unit': 'minutes',
            'date': date,
            'time_period': 'daily',
            'source': 'test_data_generator'
        })

    # Insert all readings
    print(f"\nInserting {len(readings)} metric readings...")
    result = supabase.table('display_metrics_readings').insert(readings).execute()
    print(f"✅ Inserted {len(result.data)} readings successfully")

    return result.data

def print_summary(sleep_data):
    """Print a summary of the generated data"""
    print("\n" + "="*60)
    print("SLEEP DATA SUMMARY (Last 7 Days)")
    print("="*60)
    print(f"{'Date':<12} {'Bedtime':<8} {'Wake':<8} {'In Bed':<8} {'Asleep':<8}")
    print("-"*60)

    for day in sleep_data:
        bed = datetime.fromisoformat(day['bed_time']).strftime('%I:%M %p')
        wake = datetime.fromisoformat(day['wake_time']).strftime('%I:%M %p')
        print(f"{day['date']:<12} {bed:<8} {wake:<8} {day['time_in_bed_hours']:>6.1f}h  {day['total_sleep_hours']:>6.1f}h")

    avg_sleep = sum(d['total_sleep_hours'] for d in sleep_data) / len(sleep_data)
    print("-"*60)
    print(f"7-Day Average Sleep: {avg_sleep:.1f} hours")
    print("="*60)

def main():
    print("="*60)
    print("WellPath Test Sleep Data Generator")
    print("="*60)

    # Get test patient
    patient = get_test_patient()
    patient_id = patient['id']

    # Generate sleep data for last 7 days
    print("\nGenerating 7 days of sleep data...")
    sleep_data = generate_sleep_data_for_week(patient_id)

    # Insert into database
    inserted_readings = insert_display_metrics_readings(patient_id, sleep_data)

    # Print summary
    print_summary(sleep_data)

    print("\n✅ Test data generation complete!")
    print(f"\nYou can now test the Sleep Overview screen with patient ID: {patient_id}")
    print("\nNext steps:")
    print("1. Open the mobile app")
    print("2. Navigate to Sleep Overview screen")
    print("3. The screen should display the generated data")

if __name__ == '__main__':
    main()
