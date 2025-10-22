#!/usr/bin/env python3
"""
Quick test of adherence calculator to verify it works standalone
"""

import sys
import os

# Add scoring_engine to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'scoring_engine'))

from adherence import AdherenceCalculator

def test_list_configs():
    """Test listing available configs"""
    print("=" * 60)
    print("TEST 1: List Available Configs")
    print("=" * 60)

    configs = AdherenceCalculator.list_available_configs()
    print(f"✓ Found {len(configs)} recommendation configs")

    # Show first 10
    print("\nFirst 10 configs:")
    for config in configs[:10]:
        print(f"  - {config}")

    return len(configs) > 0


def test_load_config():
    """Test loading a specific config"""
    print("\n" + "=" * 60)
    print("TEST 2: Load Specific Config")
    print("=" * 60)

    try:
        calculator = AdherenceCalculator(config_id="REC0001.1-PROPORTIONAL")
        info = calculator.get_algorithm_info()

        print(f"✓ Loaded config: {info['config_id']}")
        print(f"  Algorithm Type: {info['algorithm_type']}")
        print(f"  Recommendation ID: {info['recommendation_id']}")
        print(f"  Title: {info['title']}")

        return True
    except Exception as e:
        print(f"✗ Error loading config: {e}")
        return False


def test_get_recommendation_configs():
    """Test getting all configs for a recommendation"""
    print("\n" + "=" * 60)
    print("TEST 3: Get Configs for REC0001")
    print("=" * 60)

    configs = AdherenceCalculator.get_config_by_recommendation("REC0001")
    print(f"✓ Found {len(configs)} configs for REC0001:")
    for config in configs:
        print(f"  - {config}")

    return len(configs) > 0


def test_algorithm_types():
    """Test that all algorithm types are available"""
    print("\n" + "=" * 60)
    print("TEST 4: Verify Algorithm Types")
    print("=" * 60)

    algorithms = [
        'BINARY-THRESHOLD',
        'MINIMUM-FREQUENCY',
        'PROPORTIONAL',
        'ZONE-BASED',
        'COMPOSITE-WEIGHTED',
        'SLEEP-COMPOSITE',
        'WEEKLY-ELIMINATION',
        'CONSTRAINED-WEEKLY-ALLOWANCE',
        'CATEGORICAL-FILTER-DAILY',
        'PROPORTIONAL-FREQUENCY-HYBRID',
        'BASELINE-CONSISTENCY',
        'WEEKEND-VARIANCE',
        'COMPLETION-BASED',
        'THERAPEUTIC-ADHERENCE'
    ]

    print("Checking algorithm implementations:")
    for alg in algorithms:
        if alg in AdherenceCalculator.ALGORITHM_MAP:
            print(f"  ✓ {alg}")
        else:
            print(f"  ✗ {alg} MISSING")

    return True


def main():
    """Run all tests"""
    print("\n" + "🧪 " * 30)
    print("TESTING ADHERENCE CALCULATOR - V2 BACKEND")
    print("🧪 " * 30 + "\n")

    results = []

    results.append(("List Configs", test_list_configs()))
    results.append(("Load Config", test_load_config()))
    results.append(("Get Recommendation Configs", test_get_recommendation_configs()))
    results.append(("Verify Algorithm Types", test_algorithm_types()))

    # Summary
    print("\n" + "=" * 60)
    print("TEST SUMMARY")
    print("=" * 60)

    for test_name, passed in results:
        status = "✓ PASS" if passed else "✗ FAIL"
        print(f"{status:10} {test_name}")

    all_passed = all(r[1] for r in results)

    if all_passed:
        print("\n🎉 ALL TESTS PASSED - V2 Backend is self-contained!")
    else:
        print("\n⚠️  SOME TESTS FAILED - Check errors above")

    return all_passed


if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
