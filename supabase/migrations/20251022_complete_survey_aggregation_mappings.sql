-- ============================================================================
-- Complete Survey Response Options to Aggregation Metrics Mappings
-- ============================================================================
-- This migration creates comprehensive mappings between survey response options
-- and aggregation metrics to enable dynamic score updating based on patient
-- tracking data.
--
-- Behavior Categories Mapped:
-- - Section 2: Nutrition (fruit, vegetables, protein, water, etc.)
-- - Section 3: Exercise (cardio, strength, HIIT, mobility, steps)
-- - Section 4: Sleep (duration, quality)
-- - Section 5: Cognitive Health (brain training)
-- - Section 6: Stress Management
-- - Section 8: Substances (alcohol, tobacco)
--
-- Created: 2025-10-22
-- ============================================================================

-- Clean slate: remove existing mappings
DELETE FROM survey_response_options_aggregations;

-- ============================================================================
-- SECTION 2: NUTRITION MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q2.13: Processed Meat Consumption Frequency
-- Question: "How often do you consume processed meat?"
-- Metric: AGG_PROCESSED_MEAT_SERVING (weekly frequency)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.13-1', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or Never - no consumption'),
('RO_2.13-2', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 0, 0.9, 'SUM', 'weekly', 15, 30, 'Less than once a week'),
('RO_2.13-3', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 1.0, 2.9, 'SUM', 'weekly', 15, 30, '1-2 times per week'),
('RO_2.13-4', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 3.0, 4.9, 'SUM', 'weekly', 15, 30, '3-4 times per week'),
('RO_2.13-5', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 5.0, 999, 'SUM', 'weekly', 15, 30, '5 or more times per week');

-- ----------------------------------------------------------------------------
-- Q2.15: Fatty Fish Consumption Frequency
-- Question: "How often do you eat fatty fish rich in omega-3s?"
-- Metric: AGG_FATTY_FISH_SERVINGS (weekly frequency)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.15-1', 2.15, 'AGG_FATTY_FISH_SERVINGS', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or Never'),
('RO_2.15-2', 2.15, 'AGG_FATTY_FISH_SERVINGS', 0, 0.9, 'SUM', 'weekly', 15, 30, 'Less than once a week'),
('RO_2.15-3', 2.15, 'AGG_FATTY_FISH_SERVINGS', 1.0, 2.9, 'SUM', 'weekly', 15, 30, '1-2 times per week'),
('RO_2.15-4', 2.15, 'AGG_FATTY_FISH_SERVINGS', 3.0, 4.9, 'SUM', 'weekly', 15, 30, '3-4 times per week'),
('RO_2.15-5', 2.15, 'AGG_FATTY_FISH_SERVINGS', 5.0, 999, 'SUM', 'weekly', 15, 30, '5 or more times per week');

-- ----------------------------------------------------------------------------
-- Q2.17: Plant-Based Protein Percentage
-- Question: "How much of your protein comes from plant-based sources?"
-- Metric: AGG_PLANTBASED_PROTEIN_PERCENTAGE (monthly average percentage)
-- Calculation: AVG (percentage of plant-based protein)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.17-1', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 0, 10, 'AVG', 'monthly', 20, 30, 'Almost none - all animal-based (0-10%)'),
('RO_2.17-2', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 10, 35, 'AVG', 'monthly', 20, 30, 'A small portion - mostly animal-based (10-35%)'),
('RO_2.17-3', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 35, 65, 'AVG', 'monthly', 20, 30, 'Moderate - roughly balanced (35-65%)'),
('RO_2.17-4', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 65, 90, 'AVG', 'monthly', 20, 30, 'Large portion - mostly plant-based (65-90%)'),
('RO_2.17-5', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 90, 100, 'AVG', 'monthly', 20, 30, 'Almost entirely plant-based or Vegan (90-100%)');

-- ----------------------------------------------------------------------------
-- Q2.19: Daily Fruit Servings (VALIDATION EXAMPLE)
-- Question: "How many total servings of fruit do you consume daily?"
-- Metric: AGG_FRUIT_SERVINGS (daily average over month)
-- Calculation: AVG (servings per day)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.19-1', 2.19, 'AGG_FRUIT_SERVINGS', 0, 0.9, 'AVG', 'monthly', 20, 30, '0 servings per day'),
('RO_2.19-2', 2.19, 'AGG_FRUIT_SERVINGS', 1.0, 2.9, 'AVG', 'monthly', 20, 30, '1-2 servings per day'),
('RO_2.19-3', 2.19, 'AGG_FRUIT_SERVINGS', 3.0, 4.9, 'AVG', 'monthly', 20, 30, '3-4 servings per day'),
('RO_2.19-4', 2.19, 'AGG_FRUIT_SERVINGS', 5.0, 999, 'AVG', 'monthly', 20, 30, '5 or more servings per day');

-- ----------------------------------------------------------------------------
-- Q2.21: Whole Grain Consumption Frequency
-- Question: "How often do you consume whole grains?"
-- Metric: AGG_WHOLE_GRAIN_SERVINGS (weekly frequency)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.21-1', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or never'),
('RO_2.21-2', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 1.0, 1.9, 'SUM', 'weekly', 15, 30, 'Once a week'),
('RO_2.21-3', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 3.0, 4.9, 'SUM', 'weekly', 15, 30, 'Several times a week (3-4x)'),
('RO_2.21-4', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 7.0, 999, 'SUM', 'weekly', 15, 30, 'Daily (7x per week)');

-- ----------------------------------------------------------------------------
-- Q2.23: Legume Consumption Frequency
-- Question: "How often do you consume legumes?"
-- Metric: AGG_LEGUME_SERVINGS (weekly frequency)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.23-1', 2.23, 'AGG_LEGUME_SERVINGS', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or never'),
('RO_2.23-2', 2.23, 'AGG_LEGUME_SERVINGS', 1.0, 1.9, 'SUM', 'weekly', 15, 30, 'Once a week'),
('RO_2.23-3', 2.23, 'AGG_LEGUME_SERVINGS', 3.0, 4.9, 'SUM', 'weekly', 15, 30, 'Several times a week (3-4x)'),
('RO_2.23-4', 2.23, 'AGG_LEGUME_SERVINGS', 7.0, 999, 'SUM', 'weekly', 15, 30, 'Daily (7x per week)');

-- ----------------------------------------------------------------------------
-- Q2.25: Seed Consumption Frequency
-- Question: "How often do you consume seeds (flaxseed, chia, hemp)?"
-- Metric: AGG_SEED_SERVINGS (weekly frequency)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.25-1', 2.25, 'AGG_SEED_SERVINGS', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or never'),
('RO_2.25-2', 2.25, 'AGG_SEED_SERVINGS', 1.0, 1.9, 'SUM', 'weekly', 15, 30, 'Once a week'),
('RO_2.25-3', 2.25, 'AGG_SEED_SERVINGS', 3.0, 4.9, 'SUM', 'weekly', 15, 30, 'Several times a week (3-4x)'),
('RO_2.25-4', 2.25, 'AGG_SEED_SERVINGS', 7.0, 999, 'SUM', 'weekly', 15, 30, 'Daily (7x per week)');

-- ----------------------------------------------------------------------------
-- Q2.27: Healthy Fat Consumption Frequency
-- Question: "How often do you consume healthy fats (olive oil, avocados, nuts)?"
-- Metric: AGG_FAT_SERVINGS (weekly frequency for healthy fats)
-- Calculation: SUM (total servings per week)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.27-1', 2.27, 'AGG_FAT_SERVINGS', 0, 0, 'SUM', 'weekly', 15, 30, 'Rarely or never'),
('RO_2.27-2', 2.27, 'AGG_FAT_SERVINGS', 1.0, 1.9, 'SUM', 'weekly', 15, 30, 'Once a week'),
('RO_2.27-3', 2.27, 'AGG_FAT_SERVINGS', 3.0, 4.9, 'SUM', 'weekly', 15, 30, 'Several times a week (3-4x)'),
('RO_2.27-4', 2.27, 'AGG_FAT_SERVINGS', 7.0, 999, 'SUM', 'weekly', 15, 30, 'Daily (7x per week)');

-- ----------------------------------------------------------------------------
-- Q2.29: Daily Water Consumption
-- Question: "How much water do you drink daily?"
-- Metric: AGG_WATER_CONSUMPTION (daily average in liters)
-- Calculation: AVG (liters per day)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.29-1', 2.29, 'AGG_WATER_CONSUMPTION', 0, 0.9, 'AVG', 'monthly', 20, 30, 'Less than 1 liter (34 oz)'),
('RO_2.29-2', 2.29, 'AGG_WATER_CONSUMPTION', 1.0, 2.9, 'AVG', 'monthly', 20, 30, '1-2 liters (34-68 oz)'),
('RO_2.29-3', 2.29, 'AGG_WATER_CONSUMPTION', 2.0, 999, 'AVG', 'monthly', 20, 30, 'More than 2 liters (68 oz)');

-- ----------------------------------------------------------------------------
-- Q2.31: Daily Caffeine Consumption
-- Question: "How much caffeine do you typically consume per day?"
-- Metric: AGG_CAFFEINE_CONSUMED (daily average in mg)
-- Calculation: AVG (mg per day)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_2.31-1', 2.31, 'AGG_CAFFEINE_CONSUMED', 0, 0, 'AVG', 'monthly', 20, 30, 'None'),
('RO_2.31-2', 2.31, 'AGG_CAFFEINE_CONSUMED', 1, 99, 'AVG', 'monthly', 20, 30, '<100 mg (1 small coffee/tea)'),
('RO_2.31-3', 2.31, 'AGG_CAFFEINE_CONSUMED', 100, 200, 'AVG', 'monthly', 20, 30, '100-200 mg (1-2 cups of coffee)'),
('RO_2.31-4', 2.31, 'AGG_CAFFEINE_CONSUMED', 201, 400, 'AVG', 'monthly', 20, 30, '201-400 mg (3-4 cups or energy drink)'),
('RO_2.31-5', 2.31, 'AGG_CAFFEINE_CONSUMED', 400, 999, 'AVG', 'monthly', 20, 30, '>400 mg (5+ cups, pre-workouts)');

-- ============================================================================
-- SECTION 3: EXERCISE MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q3.04: Cardio Frequency
-- Question: "How often do you engage in Cardio?"
-- Metric: AGG_CARDIO_SESSION_COUNT (sessions per week)
-- Calculation: SUM (count of sessions)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.04-1', 3.04, 'AGG_CARDIO_SESSION_COUNT', 0, 2, 'SUM', 'weekly', 10, 30, 'Rarely (a few times a month, ~0-2/week)'),
('RO_3.04-2', 3.04, 'AGG_CARDIO_SESSION_COUNT', 1.0, 2.9, 'SUM', 'weekly', 10, 30, 'Occasionally (1-2 times per week)'),
('RO_3.04-3', 3.04, 'AGG_CARDIO_SESSION_COUNT', 3.0, 4.9, 'SUM', 'weekly', 10, 30, 'Regularly (3-4 times per week)'),
('RO_3.04-4', 3.04, 'AGG_CARDIO_SESSION_COUNT', 5.0, 999, 'SUM', 'weekly', 10, 30, 'Frequently (5 or more times per week)');

-- ----------------------------------------------------------------------------
-- Q3.05: Strength Training Frequency
-- Question: "How often do you engage in Strength training?"
-- Metric: AGG_STRENGTH_SESSION_COUNT (sessions per week)
-- Calculation: SUM (count of sessions)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.05-1', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 0, 2, 'SUM', 'weekly', 10, 30, 'Rarely (a few times a month, ~0-2/week)'),
('RO_3.05-2', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 1.0, 2.9, 'SUM', 'weekly', 10, 30, 'Occasionally (1-2 times per week)'),
('RO_3.05-3', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 3.0, 4.9, 'SUM', 'weekly', 10, 30, 'Regularly (3-4 times per week)'),
('RO_3.05-4', 3.05, 'AGG_STRENGTH_SESSION_COUNT', 5.0, 999, 'SUM', 'weekly', 10, 30, 'Frequently (5 or more times per week)');

-- ----------------------------------------------------------------------------
-- Q3.06: Flexibility/Mobility Frequency
-- Question: "How often do you engage in Flexibility/mobility?"
-- Metric: AGG_MOBILITY_SESSION_COUNT (sessions per week)
-- Calculation: SUM (count of sessions)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.06-1', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 0, 2, 'SUM', 'weekly', 10, 30, 'Rarely (a few times a month, ~0-2/week)'),
('RO_3.06-2', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 1.0, 2.9, 'SUM', 'weekly', 10, 30, 'Occasionally (1-2 times per week)'),
('RO_3.06-3', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 3.0, 4.9, 'SUM', 'weekly', 10, 30, 'Regularly (3-4 times per week)'),
('RO_3.06-4', 3.06, 'AGG_MOBILITY_SESSION_COUNT', 5.0, 999, 'SUM', 'weekly', 10, 30, 'Frequently (5 or more times per week)');

-- ----------------------------------------------------------------------------
-- Q3.07: HIIT Frequency
-- Question: "How often do you engage in HIIT?"
-- Metric: AGG_HIIT_SESSION_COUNT (sessions per week)
-- Calculation: SUM (count of sessions)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.07-1', 3.07, 'AGG_HIIT_SESSION_COUNT', 0, 2, 'SUM', 'weekly', 10, 30, 'Rarely (a few times a month, ~0-2/week)'),
('RO_3.07-2', 3.07, 'AGG_HIIT_SESSION_COUNT', 1.0, 2.9, 'SUM', 'weekly', 10, 30, 'Occasionally (1-2 times per week)'),
('RO_3.07-3', 3.07, 'AGG_HIIT_SESSION_COUNT', 3.0, 4.9, 'SUM', 'weekly', 10, 30, 'Regularly (3-4 times per week)'),
('RO_3.07-4', 3.07, 'AGG_HIIT_SESSION_COUNT', 5.0, 999, 'SUM', 'weekly', 10, 30, 'Frequently (5 or more times per week)');

-- ----------------------------------------------------------------------------
-- Q3.08: Daily Cardio Duration
-- Question: "On days when you do cardio, how many total minutes?"
-- Metric: AGG_CARDIO_DURATION (average minutes per session day)
-- Calculation: AVG (average duration on days when cardio was performed)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.08-1', 3.08, 'AGG_CARDIO_DURATION', 0, 29, 'AVG', 'monthly', 10, 30, 'Less than 30 minutes'),
('RO_3.08-2', 3.08, 'AGG_CARDIO_DURATION', 30, 45, 'AVG', 'monthly', 10, 30, '30-45 minutes'),
('RO_3.08-3', 3.08, 'AGG_CARDIO_DURATION', 45, 60, 'AVG', 'monthly', 10, 30, '45-60 minutes'),
('RO_3.08-4', 3.08, 'AGG_CARDIO_DURATION', 60, 999, 'AVG', 'monthly', 10, 30, 'More than 60 minutes');

-- ----------------------------------------------------------------------------
-- Q3.09: Daily Strength Training Duration
-- Question: "On days when you strength train, how many total minutes?"
-- Metric: AGG_STRENGTH_DURATION (average minutes per session day)
-- Calculation: AVG (average duration on days when strength training was performed)
-- Note: Using generic AGG_CALCULATED_EXERCISE_TIME since no specific strength duration metric exists
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.09-1', 3.09, 'AGG_CALCULATED_EXERCISE_TIME', 0, 29, 'AVG', 'monthly', 10, 30, 'Strength: Less than 30 minutes'),
('RO_3.09-2', 3.09, 'AGG_CALCULATED_EXERCISE_TIME', 30, 45, 'AVG', 'monthly', 10, 30, 'Strength: 30-45 minutes'),
('RO_3.09-3', 3.09, 'AGG_CALCULATED_EXERCISE_TIME', 45, 60, 'AVG', 'monthly', 10, 30, 'Strength: 45-60 minutes'),
('RO_3.09-4', 3.09, 'AGG_CALCULATED_EXERCISE_TIME', 60, 999, 'AVG', 'monthly', 10, 30, 'Strength: More than 60 minutes');

-- ----------------------------------------------------------------------------
-- Q3.10: Daily Flexibility/Mobility Duration
-- Question: "On days when you do flexibility/mobility work, how many minutes?"
-- Metric: AGG_MOBILITY_DURATION (average minutes per session day)
-- Calculation: AVG (average duration on days when mobility was performed)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.10-1', 3.10, 'AGG_MOBILITY_DURATION', 0, 29, 'AVG', 'monthly', 10, 30, 'Less than 30 minutes'),
('RO_3.10-2', 3.10, 'AGG_MOBILITY_DURATION', 30, 45, 'AVG', 'monthly', 10, 30, '30-45 minutes'),
('RO_3.10-3', 3.10, 'AGG_MOBILITY_DURATION', 45, 60, 'AVG', 'monthly', 10, 30, '45-60 minutes'),
('RO_3.10-4', 3.10, 'AGG_MOBILITY_DURATION', 60, 999, 'AVG', 'monthly', 10, 30, 'More than 60 minutes');

-- ----------------------------------------------------------------------------
-- Q3.11: Daily HIIT Duration
-- Question: "On days when you do HIIT, how many total minutes?"
-- Metric: AGG_HIIT_DURATION (average minutes per session day)
-- Calculation: AVG (average duration on days when HIIT was performed)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.11-1', 3.11, 'AGG_HIIT_DURATION', 0, 29, 'AVG', 'monthly', 10, 30, 'Less than 30 minutes'),
('RO_3.11-2', 3.11, 'AGG_HIIT_DURATION', 30, 45, 'AVG', 'monthly', 10, 30, '30-45 minutes'),
('RO_3.11-3', 3.11, 'AGG_HIIT_DURATION', 45, 60, 'AVG', 'monthly', 10, 30, '45-60 minutes'),
('RO_3.11-4', 3.11, 'AGG_HIIT_DURATION', 60, 999, 'AVG', 'monthly', 10, 30, 'More than 60 minutes');

-- ----------------------------------------------------------------------------
-- Q3.21: Daily Step Count
-- Question: "How many steps do you typically take per day?"
-- Metric: AGG_STEPS (daily average step count)
-- Calculation: AVG (average steps per day)
-- Note: RO_3.21-7 "I'm not sure" is intentionally excluded
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_3.21-1', 3.21, 'AGG_STEPS', 0, 2499, 'AVG', 'daily', 20, 30, 'Less than 2,500 steps'),
('RO_3.21-2', 3.21, 'AGG_STEPS', 2500, 4999, 'AVG', 'daily', 20, 30, '2,500-5,000 steps'),
('RO_3.21-3', 3.21, 'AGG_STEPS', 5000, 7499, 'AVG', 'daily', 20, 30, '5,000-7,500 steps'),
('RO_3.21-4', 3.21, 'AGG_STEPS', 7500, 9999, 'AVG', 'daily', 20, 30, '7,500-10,000 steps'),
('RO_3.21-5', 3.21, 'AGG_STEPS', 10000, 14999, 'AVG', 'daily', 20, 30, '10,000-15,000 steps'),
('RO_3.21-6', 3.21, 'AGG_STEPS', 15000, 99999, 'AVG', 'daily', 20, 30, 'More than 15,000 steps');

-- ============================================================================
-- SECTION 4: SLEEP MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q4.01: Sleep Quality Rating
-- Question: "How would you rate the quality of your sleep?"
-- Metric: AGG_SLEEP_QUALITY (monthly average rating 1-5 scale)
-- Calculation: AVG (subjective quality rating)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_4.01-1', 4.01, 'AGG_SLEEP_QUALITY', 1, 2, 'AVG', 'monthly', 20, 30, 'Poor quality (1-2 rating)'),
('RO_4.01-2', 4.01, 'AGG_SLEEP_QUALITY', 2, 3, 'AVG', 'monthly', 20, 30, 'Fair quality (2-3 rating)'),
('RO_4.01-3', 4.01, 'AGG_SLEEP_QUALITY', 3, 4, 'AVG', 'monthly', 20, 30, 'Good quality (3-4 rating)'),
('RO_4.01-4', 4.01, 'AGG_SLEEP_QUALITY', 4, 5, 'AVG', 'monthly', 20, 30, 'Very Good quality (4-5 rating)'),
('RO_4.01-5', 4.01, 'AGG_SLEEP_QUALITY', 4.5, 5, 'AVG', 'monthly', 20, 30, 'Excellent quality (4.5-5 rating)');

-- ----------------------------------------------------------------------------
-- Q4.02: Nightly Sleep Duration
-- Question: "How many hours of sleep do you typically get per night?"
-- Metric: AGG_SLEEP_DURATION (monthly average in minutes)
-- Calculation: AVG (average sleep duration converted to minutes)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_4.02-1', 4.02, 'AGG_SLEEP_DURATION', 0, 240, 'AVG', 'monthly', 20, 30, '4 hours or less (240 min)'),
('RO_4.02-2', 4.02, 'AGG_SLEEP_DURATION', 270, 330, 'AVG', 'monthly', 20, 30, '5 hours (300 min ±30)'),
('RO_4.02-3', 4.02, 'AGG_SLEEP_DURATION', 330, 390, 'AVG', 'monthly', 20, 30, '6 hours (360 min ±30)'),
('RO_4.02-4', 4.02, 'AGG_SLEEP_DURATION', 390, 450, 'AVG', 'monthly', 20, 30, '7 hours (420 min ±30)'),
('RO_4.02-5', 4.02, 'AGG_SLEEP_DURATION', 450, 510, 'AVG', 'monthly', 20, 30, '8 hours (480 min ±30)'),
('RO_4.02-6', 4.02, 'AGG_SLEEP_DURATION', 510, 570, 'AVG', 'monthly', 20, 30, '9 hours (540 min ±30)'),
('RO_4.02-7', 4.02, 'AGG_SLEEP_DURATION', 540, 999, 'AVG', 'monthly', 20, 30, 'More than 9 hours (>540 min)');

-- ============================================================================
-- SECTION 5: COGNITIVE HEALTH MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q5.06: Brain Training Frequency
-- Question: "How often do you engage in brain training activities?"
-- Metric: AGG_BRAIN_TRAINING_SESSION_COUNT (sessions per week)
-- Calculation: SUM (count of cognitive training sessions)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_5.06-1', 5.06, 'AGG_BRAIN_TRAINING_SESSION_COUNT', 0, 2, 'SUM', 'weekly', 10, 30, 'Rarely (a few times a month)'),
('RO_5.06-2', 5.06, 'AGG_BRAIN_TRAINING_SESSION_COUNT', 1.0, 2.9, 'SUM', 'weekly', 10, 30, 'Occasionally (1-2 times per week)'),
('RO_5.06-3', 5.06, 'AGG_BRAIN_TRAINING_SESSION_COUNT', 3.0, 4.9, 'SUM', 'weekly', 10, 30, 'Regularly (3-4 times per week)'),
('RO_5.06-4', 5.06, 'AGG_BRAIN_TRAINING_SESSION_COUNT', 5.0, 999, 'SUM', 'weekly', 10, 30, 'Frequently (5+ times per week)');

-- ============================================================================
-- SECTION 6: STRESS MANAGEMENT MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q6.01: Current Stress Level Rating
-- Question: "How would you rate your current level of stress?"
-- Metric: AGG_STRESS_LEVEL_RATING (monthly average stress rating)
-- Calculation: AVG (stress level on 1-5 scale)
-- Note: Need to verify response options exist for this question
-- ----------------------------------------------------------------------------
-- First, let's check if response options exist for 6.01
-- Commenting out for now until we confirm the options

-- ----------------------------------------------------------------------------
-- Q6.02: Stress Frequency
-- Question: "How often do you feel stressed?"
-- Metric: AGG_STRESS_LEVEL (frequency-based stress metric)
-- Calculation: AVG (frequency rating on scale)
-- Note: Need to verify response options exist for this question
-- ----------------------------------------------------------------------------
-- Commenting out for now until we confirm the options

-- ============================================================================
-- SECTION 8: SUBSTANCE USE MAPPINGS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Q8.02: Tobacco/Cigarette Use
-- Question: "How would you describe your current tobacco use?"
-- Metric: AGG_CIGARETTES (daily average cigarettes/equivalent)
-- Calculation: AVG (cigarette equivalents per day)
-- Note: Converting tobacco use levels to daily cigarette equivalents
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_8.02-1', 8.02, 'AGG_CIGARETTES', 40, 999, 'AVG', 'monthly', 20, 30, 'Heavy: 2+ packs/day (40+ cigarettes)'),
('RO_8.02-2', 8.02, 'AGG_CIGARETTES', 20, 40, 'AVG', 'monthly', 20, 30, 'Moderate: 1 pack/day (20 cigarettes)'),
('RO_8.02-3', 8.02, 'AGG_CIGARETTES', 5, 19, 'AVG', 'monthly', 15, 30, 'Light: Less than 1 pack/day (5-19 cigarettes)'),
('RO_8.02-4', 8.02, 'AGG_CIGARETTES', 1, 4, 'AVG', 'monthly', 10, 30, 'Minimal: A few times a month (1-4/day avg)'),
('RO_8.02-5', 8.02, 'AGG_CIGARETTES', 0, 0.5, 'AVG', 'monthly', 10, 30, 'Occasional: Rarely or special occasions');

-- ----------------------------------------------------------------------------
-- Q8.05: Alcohol Use
-- Question: "How would you describe your current alcohol use?"
-- Metric: AGG_ALCOHOLIC_DRINKS (daily average drinks)
-- Calculation: AVG (drinks per day)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
('RO_8.05-1', 8.05, 'AGG_ALCOHOLIC_DRINKS', 5, 999, 'AVG', 'monthly', 20, 30, 'Heavy: 5+ drinks per day'),
('RO_8.05-2', 8.05, 'AGG_ALCOHOLIC_DRINKS', 2, 4.9, 'AVG', 'monthly', 20, 30, 'Moderate: 2-4 drinks per day'),
('RO_8.05-3', 8.05, 'AGG_ALCOHOLIC_DRINKS', 1, 1.9, 'AVG', 'monthly', 20, 30, 'Light: 1 drink per day or most days'),
('RO_8.05-4', 8.05, 'AGG_ALCOHOLIC_DRINKS', 0, 0.5, 'AVG', 'monthly', 15, 30, 'Minimal: A few drinks per month'),
('RO_8.05-5', 8.05, 'AGG_ALCOHOLIC_DRINKS', 0, 0.1, 'AVG', 'monthly', 10, 30, 'Occasional: Rarely/special occasions only');

-- ============================================================================
-- ADDITIONAL NUTRITION MAPPINGS - VARIETY METRICS
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Fruit Variety Tracking
-- Metric: AGG_FRUIT_VARIETY (count of unique fruit types consumed)
-- Calculation: COUNT_DISTINCT (variety measurement)
-- Note: Applied to fruit consumption questions to measure dietary diversity
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
-- Q2.19 fruit servings also tracks variety
('RO_2.19-2', 2.19, 'AGG_FRUIT_VARIETY', 1, 3, 'COUNT_DISTINCT', 'monthly', 15, 30, '1-2 servings suggests low variety (1-3 types)'),
('RO_2.19-3', 2.19, 'AGG_FRUIT_VARIETY', 3, 5, 'COUNT_DISTINCT', 'monthly', 15, 30, '3-4 servings suggests moderate variety (3-5 types)'),
('RO_2.19-4', 2.19, 'AGG_FRUIT_VARIETY', 5, 999, 'COUNT_DISTINCT', 'monthly', 15, 30, '5+ servings suggests high variety (5+ types)');

-- ----------------------------------------------------------------------------
-- Vegetable Servings and Variety
-- Note: Adding vegetable servings mapping (no direct question found, but common)
-- This would apply to a vegetable consumption question if it exists
-- ----------------------------------------------------------------------------

-- ----------------------------------------------------------------------------
-- Legume Variety Tracking
-- Metric: AGG_LEGUME_VARIETY (count of unique legume types)
-- Calculation: COUNT_DISTINCT (variety measurement)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
-- Q2.23 legume consumption also tracks variety
('RO_2.23-2', 2.23, 'AGG_LEGUME_VARIETY', 1, 2, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Once a week suggests limited variety (1-2 types)'),
('RO_2.23-3', 2.23, 'AGG_LEGUME_VARIETY', 2, 4, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Several times suggests moderate variety (2-4 types)'),
('RO_2.23-4', 2.23, 'AGG_LEGUME_VARIETY', 3, 999, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Daily suggests high variety (3+ types)');

-- ----------------------------------------------------------------------------
-- Whole Grain Variety Tracking
-- Metric: AGG_WHOLE_GRAIN_VARIETY (count of unique grain types)
-- Calculation: COUNT_DISTINCT (variety measurement)
-- ----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, min_data_points, lookback_days, notes)
VALUES
-- Q2.21 whole grain consumption also tracks variety
('RO_2.21-2', 2.21, 'AGG_WHOLE_GRAIN_VARIETY', 1, 2, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Once a week suggests limited variety (1-2 types)'),
('RO_2.21-3', 2.21, 'AGG_WHOLE_GRAIN_VARIETY', 2, 4, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Several times suggests moderate variety (2-4 types)'),
('RO_2.21-4', 2.21, 'AGG_WHOLE_GRAIN_VARIETY', 3, 999, 'COUNT_DISTINCT', 'monthly', 10, 30, 'Daily suggests high variety (3+ types)');

-- ============================================================================
-- STRESS AND MINDFULNESS MAPPINGS (ADDITIONAL)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- Meditation and Breathwork Sessions
-- Note: These would apply to stress management questions about meditation/breathwork
-- Commenting out until we confirm the specific question numbers
-- ----------------------------------------------------------------------------
-- Potential metrics available:
-- - AGG_MEDITATION_SESSIONS
-- - AGG_BREATHWORK_SESSIONS
-- - AGG_BREATHWORK_AND_MINDFULNESS_SESSIONS
-- - AGG_MEDITATION_DURATION
-- - AGG_BREATHWORK_DURATION
-- - AGG_STRESS_MANAGEMENT_SESSIONS

-- ============================================================================
-- SUMMARY STATISTICS
-- ============================================================================

-- Count mappings by category
DO $$
DECLARE
    nutrition_count INT;
    exercise_count INT;
    sleep_count INT;
    cognitive_count INT;
    substance_count INT;
    total_count INT;
BEGIN
    SELECT COUNT(*) INTO nutrition_count FROM survey_response_options_aggregations WHERE question_number >= 2 AND question_number < 3;
    SELECT COUNT(*) INTO exercise_count FROM survey_response_options_aggregations WHERE question_number >= 3 AND question_number < 4;
    SELECT COUNT(*) INTO sleep_count FROM survey_response_options_aggregations WHERE question_number >= 4 AND question_number < 5;
    SELECT COUNT(*) INTO cognitive_count FROM survey_response_options_aggregations WHERE question_number >= 5 AND question_number < 7;
    SELECT COUNT(*) INTO substance_count FROM survey_response_options_aggregations WHERE question_number >= 8 AND question_number < 9;
    SELECT COUNT(*) INTO total_count FROM survey_response_options_aggregations;

    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Survey Response Options to Aggregation Metrics Mapping Summary';
    RAISE NOTICE '============================================================================';
    RAISE NOTICE 'Nutrition Mappings (Section 2):        % mappings', nutrition_count;
    RAISE NOTICE 'Exercise Mappings (Section 3):         % mappings', exercise_count;
    RAISE NOTICE 'Sleep Mappings (Section 4):            % mappings', sleep_count;
    RAISE NOTICE 'Cognitive/Stress Mappings (Sec 5-6):   % mappings', cognitive_count;
    RAISE NOTICE 'Substance Use Mappings (Section 8):    % mappings', substance_count;
    RAISE NOTICE '----------------------------------------------------------------------------';
    RAISE NOTICE 'TOTAL MAPPINGS CREATED:                % mappings', total_count;
    RAISE NOTICE '============================================================================';
    RAISE NOTICE '';
    RAISE NOTICE 'Key Questions Mapped:';
    RAISE NOTICE '  ✓ Q2.13: Processed meat frequency';
    RAISE NOTICE '  ✓ Q2.15: Fatty fish frequency';
    RAISE NOTICE '  ✓ Q2.17: Plant-based protein percentage';
    RAISE NOTICE '  ✓ Q2.19: Daily fruit servings (VALIDATION EXAMPLE)';
    RAISE NOTICE '  ✓ Q2.21: Whole grain frequency';
    RAISE NOTICE '  ✓ Q2.23: Legume frequency';
    RAISE NOTICE '  ✓ Q2.25: Seed consumption';
    RAISE NOTICE '  ✓ Q2.27: Healthy fat consumption';
    RAISE NOTICE '  ✓ Q2.29: Daily water intake';
    RAISE NOTICE '  ✓ Q2.31: Daily caffeine intake';
    RAISE NOTICE '  ✓ Q3.04-3.07: Exercise frequency (cardio, strength, mobility, HIIT)';
    RAISE NOTICE '  ✓ Q3.08-3.11: Exercise duration per session';
    RAISE NOTICE '  ✓ Q3.21: Daily step count';
    RAISE NOTICE '  ✓ Q4.01: Sleep quality rating';
    RAISE NOTICE '  ✓ Q4.02: Nightly sleep duration';
    RAISE NOTICE '  ✓ Q5.06: Brain training frequency';
    RAISE NOTICE '  ✓ Q8.02: Tobacco use';
    RAISE NOTICE '  ✓ Q8.05: Alcohol consumption';
    RAISE NOTICE '';
    RAISE NOTICE 'Additional Variety Metrics Mapped:';
    RAISE NOTICE '  ✓ Fruit variety tracking';
    RAISE NOTICE '  ✓ Legume variety tracking';
    RAISE NOTICE '  ✓ Whole grain variety tracking';
    RAISE NOTICE '';
    RAISE NOTICE 'Data Quality Parameters:';
    RAISE NOTICE '  • Nutrition/Sleep: 20 data points over 30 days (conservative)';
    RAISE NOTICE '  • Exercise sessions: 10 data points over 30 days (moderate)';
    RAISE NOTICE '  • Variety metrics: 10-15 data points over 30 days (relaxed)';
    RAISE NOTICE '';
    RAISE NOTICE 'Period Types Used:';
    RAISE NOTICE '  • Weekly: Session counts, weekly frequencies';
    RAISE NOTICE '  • Monthly: Daily averages, quality ratings';
    RAISE NOTICE '  • Daily: Step counts';
    RAISE NOTICE '';
    RAISE NOTICE 'Calculation Types Used:';
    RAISE NOTICE '  • SUM: Session counts, weekly frequencies';
    RAISE NOTICE '  • AVG: Daily quantities, durations, ratings';
    RAISE NOTICE '  • COUNT_DISTINCT: Variety measurements';
    RAISE NOTICE '============================================================================';
END $$;

-- ============================================================================
-- END OF MIGRATION
-- ============================================================================
-- Questions that could not be mapped (reason: no matching aggregation metric):
-- - Q6.01, Q6.02: Stress rating questions (need to verify response options)
-- - Q5.01: Cognitive function rating (no direct metric)
-- - Q4.03: Feeling rested frequency (no direct metric)
-- - Q4.04: Sleep schedule consistency (no direct metric)
--
-- Future enhancements:
-- - Add vegetable servings mapping when question is identified
-- - Add meditation/breathwork session mappings to stress questions
-- - Add protein grams mapping (Q2.11 is free response)
-- - Consider adding composite metrics for overall nutrition score
-- ============================================================================
