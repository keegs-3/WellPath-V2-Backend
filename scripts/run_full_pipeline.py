#!/usr/bin/env python3
"""
WellPath Complete Pipeline Runner

Runs the complete WellPath scoring pipeline in sequence:
1. generate_biomarker_dataset.py
2. generate_survey_dataset_v2.py  
3. wellpath_score_runner_markers.py
4. wellpath_score_runner_survey_v2.py
5. wellpath_score_runner_combined.py
6. patient_score_breakdown_generator.py
7. wellpath_impact_scorer_improved.py

Usage:
    python run_full_pipeline.py
    
Options:
    --skip-to STEP_NUMBER    Skip to specific step (1-7)
    --stop-at STEP_NUMBER    Stop after specific step (1-7)
    --simple                 Run in simple mode (hide detailed script output)
"""

import subprocess
import sys
import time
import os
from datetime import datetime
import argparse

# Set UTF-8 encoding for subprocess environment
env = os.environ.copy()
env['PYTHONIOENCODING'] = 'utf-8'

# Pipeline configuration
PIPELINE_STEPS = [
    {
        "name": "Biomarker Dataset Generation",
        "script": "generate_biomarker_dataset.py",
        "description": "Generate synthetic biomarker data for patient profiles"
    },
    {
        "name": "Survey Dataset Generation", 
        "script": "generate_survey_dataset_v2.py",
        "description": "Generate survey responses based on patient profiles"
    },
    {
        "name": "Biomarker Scoring",
        "script": "Wellpath_score_runner_markers.py",
        "description": "Calculate WellPath scores from biomarker data"
    },
    {
        "name": "Survey Scoring",
        "script": "wellpath_score_runner_survey_v2.py",
        "description": "Calculate WellPath scores from survey responses"
    },
    {
        "name": "Combined Scoring",
        "script": "WellPath_score_runner_combined.py",
        "description": "Combine biomarker and survey scores into final WellPath scores"
    },
    {
        "name": "Score Breakdown Generation",
        "script": "Patient_score_breakdown_generator.py",
        "description": "Generate detailed score breakdowns for each patient"
    },
    {
        "name": "Impact Scoring",
        "script": "wellpath_impact_scorer_improved.py", 
        "description": "Calculate recommendation impact scores for each patient"
    }
]

def print_banner():
    """Print pipeline banner"""
    print("=" * 70)
    print("WellPath Complete Pipeline Runner")
    print("=" * 70)
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"Total Steps: {len(PIPELINE_STEPS)}")
    print("=" * 70)

def print_step_header(step_num, step_info):
    """Print step header"""
    print(f"\nSTEP {step_num}/{len(PIPELINE_STEPS)}: {step_info['name']}")
    print(f"Description: {step_info['description']}")
    print(f"Running: {step_info['script']}")
    print("-" * 50)

def run_script(script_path, verbose=False):
    """Run a Python script and return success status"""
    # Get absolute path to scripts directory
    scripts_dir = os.path.dirname(os.path.abspath(__file__))
    full_script_path = os.path.join(scripts_dir, script_path)

    try:
        # Run the script
        if verbose:
            # Show output in real-time
            process = subprocess.Popen(
                [sys.executable, full_script_path],
                stdout=subprocess.PIPE,
                stderr=subprocess.STDOUT,
                universal_newlines=True,
                encoding='utf-8',
                env=env,
                bufsize=1
            )
            
            # Print output line by line
            for line in process.stdout:
                print(f"  {line.rstrip()}")
            
            process.wait()
            return_code = process.returncode
        else:
            # Capture output and only show on error
            result = subprocess.run(
                [sys.executable, full_script_path],
                capture_output=True,
                text=True,
                encoding='utf-8',
                env=env,
                timeout=300  # 5 minute timeout per script
            )
            return_code = result.returncode
            
            if return_code != 0:
                print(f"ERROR: Error output:")
                print(result.stderr)
                print(f"ERROR: Standard output:")
                print(result.stdout)
        
        return return_code == 0
        
    except subprocess.TimeoutExpired:
        print(f"TIMEOUT: Script timed out after 5 minutes")
        return False
    except Exception as e:
        print(f"ERROR: Unexpected error: {e}")
        return False

def main():
    parser = argparse.ArgumentParser(description="Run WellPath complete pipeline")
    parser.add_argument('--skip-to', type=int, metavar='STEP',
                       help='Skip to specific step (1-7)', choices=range(1, 8))
    parser.add_argument('--stop-at', type=int, metavar='STEP',
                       help='Stop after specific step (1-7)', choices=range(1, 8))
    parser.add_argument('--simple', '-s', action='store_true',
                       help='Run in simple mode (hide detailed script output)')
    parser.add_argument('--continue', '-c', dest='continue_on_error', action='store_true',
                       help='Continue pipeline even if steps fail (no prompts)')

    args = parser.parse_args()
    
    # Determine start and end steps
    start_step = args.skip_to or 1
    end_step = args.stop_at or len(PIPELINE_STEPS)
    
    # Validate step range
    if start_step > end_step:
        print("ERROR: --skip-to cannot be greater than --stop-at")
        sys.exit(1)
    
    print_banner()
    
    # Track execution
    start_time = time.time()
    successful_steps = 0
    failed_steps = []
    
    # Run pipeline steps
    for i in range(start_step - 1, end_step):
        step_num = i + 1
        step_info = PIPELINE_STEPS[i]
        script_path = step_info['script']
        
        print_step_header(step_num, step_info)
        
        # Check if script exists (scripts are in same directory)
        scripts_dir = os.path.dirname(os.path.abspath(__file__))
        full_script_path = os.path.join(scripts_dir, script_path)
        if not os.path.exists(full_script_path):
            print(f"ERROR: Script not found: {script_path}")
            failed_steps.append((step_num, step_info['name'], "Script not found"))
            continue
        
        # Run the script
        step_start_time = time.time()
        verbose = not args.simple  # Default to verbose unless --simple is used
        success = run_script(script_path, verbose)
        step_duration = time.time() - step_start_time
        
        if success:
            print(f"SUCCESS: Step {step_num} completed successfully ({step_duration:.1f}s)")
            successful_steps += 1
        else:
            print(f"FAILED: Step {step_num} failed ({step_duration:.1f}s)")
            failed_steps.append((step_num, step_info['name'], "Execution failed"))

            # Ask user if they want to continue (unless --continue flag is set)
            if not args.continue_on_error:
                print(f"\nWARNING: Step {step_num} failed. Continue with remaining steps?")
                response = input("Continue? (y/n): ").lower().strip()
                if response != 'y':
                    print("Pipeline stopped by user")
                    break
            else:
                print(f"WARNING: Step {step_num} failed, continuing due to --continue flag")
    
    # Print final summary
    total_duration = time.time() - start_time
    print("\n" + "=" * 70)
    print("PIPELINE SUMMARY")
    print("=" * 70)
    print(f"Total Duration: {total_duration:.1f} seconds")
    print(f"Successful Steps: {successful_steps}")
    print(f"Failed Steps: {len(failed_steps)}")
    
    if failed_steps:
        print("\nFailed Steps Details:")
        for step_num, step_name, error in failed_steps:
            print(f"  - Step {step_num}: {step_name} - {error}")
    
    print(f"\nPipeline completed: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    # Exit with error code if any steps failed
    if failed_steps:
        sys.exit(1)
    else:
        print("All steps completed successfully!")
        sys.exit(0)

if __name__ == "__main__":
    main()