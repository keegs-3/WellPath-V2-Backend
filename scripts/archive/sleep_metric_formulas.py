"""
Sleep Metric Calculation Formulas
All formulas derived from the sleep metrics specification
"""

from datetime import datetime, timedelta
import pandas as pd
import numpy as np


class SleepMetrics:
    """Calculate all sleep metrics from raw sleep data"""
    
    # ==================================================================================
    # PERIOD-LEVEL METRICS (Individual Sleep Periods)
    # ==================================================================================
    
    @staticmethod
    def period_rem_sleep_duration(sleep_time: datetime, wake_time: datetime) -> float:
        """
        Duration of individual REM sleep period
        
        Args:
            sleep_time: Start of REM period
            wake_time: End of REM period
            
        Returns:
            Duration in minutes
        """
        return (wake_time - sleep_time).total_seconds() / 60
    
    @staticmethod
    def period_deep_sleep_duration(deep_sleep_start: datetime, deep_sleep_end: datetime) -> float:
        """
        Duration of individual deep sleep period
        
        Args:
            deep_sleep_start: Start of deep sleep period
            deep_sleep_end: End of deep sleep period
            
        Returns:
            Duration in minutes
        """
        return (deep_sleep_end - deep_sleep_start).total_seconds() / 60
    
    @staticmethod
    def period_core_sleep_duration(core_sleep_start: datetime, core_sleep_end: datetime) -> float:
        """
        Duration of individual core/light sleep period
        
        Args:
            core_sleep_start: Start of core sleep period
            core_sleep_end: End of core sleep period
            
        Returns:
            Duration in minutes
        """
        return (core_sleep_end - core_sleep_start).total_seconds() / 60
    
    @staticmethod
    def period_awake_duration(awake_period_start: datetime, awake_period_end: datetime) -> float:
        """
        Duration of individual awake period during sleep
        
        Args:
            awake_period_start: Start of awake period
            awake_period_end: End of awake period
            
        Returns:
            Duration in minutes
        """
        return (awake_period_end - awake_period_start).total_seconds() / 60
    
    # ==================================================================================
    # DAILY AGGREGATED METRICS
    # ==================================================================================
    
    @staticmethod
    def daily_rem_sleep_duration(rem_periods: list) -> float:
        """
        Total REM sleep time per day (sum of all REM periods)
        
        Args:
            rem_periods: List of individual REM period durations in minutes
            
        Returns:
            Total REM duration in minutes
        """
        return sum(rem_periods)
    
    @staticmethod
    def daily_deep_sleep_duration(deep_periods: list) -> float:
        """
        Total deep sleep time per day (sum of all deep periods)
        
        Args:
            deep_periods: List of individual deep sleep period durations in minutes
            
        Returns:
            Total deep sleep duration in minutes
        """
        return sum(deep_periods)
    
    @staticmethod
    def daily_core_sleep_duration(core_periods: list) -> float:
        """
        Total core sleep time per day (sum of all core periods)
        
        Args:
            core_periods: List of individual core/light sleep period durations in minutes
            
        Returns:
            Total core sleep duration in minutes
        """
        return sum(core_periods)
    
    @staticmethod
    def daily_awake_duration(awake_periods: list) -> float:
        """
        Total awake time per day (sum of all awake periods during sleep)
        
        Args:
            awake_periods: List of individual awake period durations in minutes
            
        Returns:
            Total awake duration in minutes
        """
        return sum(awake_periods)
    
    @staticmethod
    def daily_total_sleep_duration(sleep_time: datetime, wake_time: datetime) -> float:
        """
        Total sleep time (from first sleep to final wake)
        Alternative: sum of REM + Deep + Core durations
        
        Args:
            sleep_time: First sleep onset time
            wake_time: Final wake time
            
        Returns:
            Duration in hours (as float)
        """
        total_seconds = abs((wake_time - sleep_time).total_seconds())
        return total_seconds / 3600  # Convert to hours
    
    @staticmethod
    def daily_total_sleep_duration_from_components(rem_duration: float, 
                                                    deep_duration: float, 
                                                    core_duration: float) -> float:
        """
        Alternative calculation: Total Sleep Duration = REM + Deep + Core
        
        Args:
            rem_duration: Total REM sleep in minutes
            deep_duration: Total deep sleep in minutes
            core_duration: Total core sleep in minutes
            
        Returns:
            Total sleep duration in hours
        """
        total_minutes = rem_duration + deep_duration + core_duration
        return total_minutes / 60  # Convert to hours
    
    @staticmethod
    def daily_time_in_bed_duration(time_in_bed_start: datetime, 
                                   time_in_bed_end: datetime) -> float:
        """
        Total time spent in bed per day
        
        Args:
            time_in_bed_start: Time got into bed
            time_in_bed_end: Time got out of bed
            
        Returns:
            Duration in minutes
        """
        return (time_in_bed_end - time_in_bed_start).total_seconds() / 60
    
    @staticmethod
    def daily_total_sleep_window(sleep_time: datetime, wake_time: datetime) -> float:
        """
        Time from first sleep to final wake
        
        Args:
            sleep_time: First sleep onset
            wake_time: Final wake time
            
        Returns:
            Duration in minutes
        """
        return (wake_time - sleep_time).total_seconds() / 60
    
    # ==================================================================================
    # CALCULATED METRICS
    # ==================================================================================
    
    @staticmethod
    def daily_sleep_efficiency(total_sleep_duration: float, 
                               time_in_bed_duration: float) -> float:
        """
        Percentage of time in bed actually asleep
        
        Formula: (total_sleep_duration / time_in_bed_duration) * 100
        
        Args:
            total_sleep_duration: Total sleep time in minutes
            time_in_bed_duration: Total time in bed in minutes
            
        Returns:
            Sleep efficiency as percentage (0-100)
        """
        if time_in_bed_duration == 0:
            return 0.0
        return (total_sleep_duration / time_in_bed_duration) * 100
    
    @staticmethod
    def daily_sleep_latency(sleep_time: datetime, time_in_bed_start: datetime) -> float:
        """
        Time to fall asleep after getting in bed
        
        Args:
            sleep_time: Time fell asleep
            time_in_bed_start: Time got into bed
            
        Returns:
            Sleep latency in minutes
        """
        return (sleep_time - time_in_bed_start).total_seconds() / 60
    
    @staticmethod
    def daily_rem_sleep_percentage(rem_duration: float, total_sleep_duration: float) -> float:
        """
        Percentage of total sleep that was REM
        
        Formula: (rem_duration / total_sleep_duration) * 100
        
        Args:
            rem_duration: Total REM sleep in minutes
            total_sleep_duration: Total sleep time in minutes
            
        Returns:
            REM percentage (0-100)
        """
        if total_sleep_duration == 0:
            return 0.0
        return (rem_duration / total_sleep_duration) * 100
    
    @staticmethod
    def daily_deep_sleep_percentage(deep_duration: float, total_sleep_duration: float) -> float:
        """
        Percentage of total sleep that was deep
        
        Formula: (deep_duration / total_sleep_duration) * 100
        
        Args:
            deep_duration: Total deep sleep in minutes
            total_sleep_duration: Total sleep time in minutes
            
        Returns:
            Deep sleep percentage (0-100)
        """
        if total_sleep_duration == 0:
            return 0.0
        return (deep_duration / total_sleep_duration) * 100
    
    @staticmethod
    def daily_core_sleep_percentage(core_duration: float, total_sleep_duration: float) -> float:
        """
        Percentage of total sleep that was core/light
        
        Formula: (core_duration / total_sleep_duration) * 100
        
        Args:
            core_duration: Total core sleep in minutes
            total_sleep_duration: Total sleep time in minutes
            
        Returns:
            Core sleep percentage (0-100)
        """
        if total_sleep_duration == 0:
            return 0.0
        return (core_duration / total_sleep_duration) * 100
    
    # ==================================================================================
    # PERIOD CONSISTENCY METRICS
    # ==================================================================================
    
    @staticmethod
    def period_sleep_time_consistency(sleep_times: pd.Series) -> float:
        """
        Standard deviation of sleep times over analysis period
        Lower values indicate better sleep schedule consistency
        
        Args:
            sleep_times: Series of sleep onset times (datetime)
            
        Returns:
            Standard deviation in minutes
        """
        if len(sleep_times) < 2:
            return 0.0
        
        # Convert times to minutes from midnight for comparison
        minutes_from_midnight = sleep_times.apply(
            lambda x: x.hour * 60 + x.minute
        )
        return float(minutes_from_midnight.std())
    
    @staticmethod
    def period_wake_time_consistency(wake_times: pd.Series) -> float:
        """
        Standard deviation of wake times over analysis period
        Lower values indicate better wake schedule consistency
        
        Args:
            wake_times: Series of wake times (datetime)
            
        Returns:
            Standard deviation in minutes
        """
        if len(wake_times) < 2:
            return 0.0
        
        # Convert times to minutes from midnight for comparison
        minutes_from_midnight = wake_times.apply(
            lambda x: x.hour * 60 + x.minute
        )
        return float(minutes_from_midnight.std())
    
    # ==================================================================================
    # CYCLE COUNT METRICS
    # ==================================================================================
    
    @staticmethod
    def daily_rem_sleep_cycle_count(rem_starts: list) -> int:
        """
        Number of REM periods per night
        
        Args:
            rem_starts: List of REM period start times
            
        Returns:
            Count of REM cycles
        """
        return len(rem_starts)
    
    @staticmethod
    def daily_deep_sleep_cycle_count(deep_starts: list) -> int:
        """
        Number of deep sleep periods per night
        
        Args:
            deep_starts: List of deep sleep period start times
            
        Returns:
            Count of deep sleep cycles
        """
        return len(deep_starts)
    
    @staticmethod
    def daily_core_sleep_cycle_count(core_starts: list) -> int:
        """
        Number of core/light sleep periods per night
        
        Args:
            core_starts: List of core sleep period start times
            
        Returns:
            Count of core sleep cycles
        """
        return len(core_starts)
    
    @staticmethod
    def daily_awake_episode_count(awake_starts: list) -> int:
        """
        Number of awake periods during sleep
        
        Args:
            awake_starts: List of awake period start times
            
        Returns:
            Count of awake episodes
        """
        return len(awake_starts)


# ==================================================================================
# USAGE EXAMPLES
# ==================================================================================

def example_calculations():
    """Example usage of all sleep metric formulas"""
    
    metrics = SleepMetrics()
    
    # Example data
    sleep_time = datetime(2025, 10, 9, 23, 30)  # 11:30 PM
    wake_time = datetime(2025, 10, 10, 7, 0)    # 7:00 AM
    time_in_bed_start = datetime(2025, 10, 9, 23, 0)  # 11:00 PM
    time_in_bed_end = datetime(2025, 10, 10, 7, 15)   # 7:15 AM
    
    # REM periods (in minutes)
    rem_periods = [20, 25, 30, 35]  # 4 REM cycles
    deep_periods = [45, 30, 25]     # 3 deep sleep cycles
    core_periods = [60, 55, 50, 45] # 4 core sleep cycles
    awake_periods = [5, 3, 2]       # 3 brief awakenings
    
    # Calculate metrics
    print("=" * 80)
    print("SLEEP METRICS CALCULATIONS")
    print("=" * 80)
    
    # Total durations
    total_sleep = metrics.daily_total_sleep_duration(sleep_time, wake_time)
    print(f"\nTotal Sleep Duration: {total_sleep:.2f} hours")
    
    rem_total = metrics.daily_rem_sleep_duration(rem_periods)
    deep_total = metrics.daily_deep_sleep_duration(deep_periods)
    core_total = metrics.daily_core_sleep_duration(core_periods)
    awake_total = metrics.daily_awake_duration(awake_periods)
    
    print(f"REM Sleep: {rem_total:.0f} minutes")
    print(f"Deep Sleep: {deep_total:.0f} minutes")
    print(f"Core Sleep: {core_total:.0f} minutes")
    print(f"Awake Time: {awake_total:.0f} minutes")
    
    # Time in bed
    time_in_bed = metrics.daily_time_in_bed_duration(time_in_bed_start, time_in_bed_end)
    print(f"\nTime in Bed: {time_in_bed:.0f} minutes")
    
    # Sleep efficiency
    total_sleep_minutes = total_sleep * 60
    efficiency = metrics.daily_sleep_efficiency(total_sleep_minutes, time_in_bed)
    print(f"Sleep Efficiency: {efficiency:.1f}%")
    
    # Sleep latency
    latency = metrics.daily_sleep_latency(sleep_time, time_in_bed_start)
    print(f"Sleep Latency: {latency:.0f} minutes")
    
    # Sleep stage percentages
    rem_pct = metrics.daily_rem_sleep_percentage(rem_total, total_sleep_minutes)
    deep_pct = metrics.daily_deep_sleep_percentage(deep_total, total_sleep_minutes)
    core_pct = metrics.daily_core_sleep_percentage(core_total, total_sleep_minutes)
    
    print(f"\nSleep Stage Breakdown:")
    print(f"  REM: {rem_pct:.1f}%")
    print(f"  Deep: {deep_pct:.1f}%")
    print(f"  Core: {core_pct:.1f}%")
    
    # Cycle counts
    print(f"\nSleep Cycles:")
    print(f"  REM cycles: {metrics.daily_rem_sleep_cycle_count(rem_periods)}")
    print(f"  Deep cycles: {metrics.daily_deep_sleep_cycle_count(deep_periods)}")
    print(f"  Core cycles: {metrics.daily_core_sleep_cycle_count(core_periods)}")
    print(f"  Awake episodes: {metrics.daily_awake_episode_count(awake_periods)}")
    
    # Consistency example (using pandas)
    sleep_times = pd.Series([
        datetime(2025, 10, 1, 23, 30),
        datetime(2025, 10, 2, 23, 45),
        datetime(2025, 10, 3, 23, 15),
        datetime(2025, 10, 4, 23, 40),
        datetime(2025, 10, 5, 23, 25),
    ])
    
    consistency = metrics.period_sleep_time_consistency(sleep_times)
    print(f"\nSleep Time Consistency: {consistency:.1f} minutes std dev")
    print("  (Lower is better - indicates more consistent sleep schedule)")
    
    print("\n" + "=" * 80)


if __name__ == "__main__":
    example_calculations()
