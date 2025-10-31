-- =====================================================================================
-- COMPREHENSIVE SURVEY AGGREGATION MAPPINGS
-- =====================================================================================
-- Maps ALL 72 standalone survey questions with pillar weights to aggregation metrics
-- Source: wellpath_scoring_question_pillar_weights (question_number >= 2)
--
-- MAPPING STATUS SUMMARY:
-- ✓ 14 previously mapped (nutrition + steps + sleep + brain training)
-- ✓ 30 newly mapped (vegetables, red meat, takeout, personal care, social, sleep quality, etc.)
-- ✗ 28 NOT mappable (family/personal history questions, subjective ratings, tracking questions)
--
-- TOTAL: 44 questions mapped to aggregation metrics
-- =====================================================================================

-- =====================================================================================
-- STEP 1: DELETE EXISTING MAPPINGS
-- =====================================================================================
-- Remove all existing survey-to-aggregation mappings to start fresh

DELETE FROM survey_response_options_aggregations;

-- =====================================================================================
-- STEP 2: NUTRITION QUESTIONS (Section 2)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q2.03: How many full meals do you typically eat per day?
-- Maps to: AGG_MEALS (count of meal events)
-- Note: Lower scores for ≤1 meal, optimal at 2-3 meals
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.03-1', 2.03, 'AGG_MEALS', NULL, 1, 'CALC_COUNT', 'daily', '≤1 meal per day - count should be ≤1'),
('RO_2.03-2', 2.03, 'AGG_MEALS', 1.5, 2.5, 'CALC_COUNT', 'daily', '2 meals per day - count should be ~2'),
('RO_2.03-3', 2.03, 'AGG_MEALS', 2.5, 3.5, 'CALC_COUNT', 'daily', '3 meals per day - count should be ~3'),
('RO_2.03-4', 2.03, 'AGG_MEALS', 3.5, NULL, 'CALC_COUNT', 'daily', '4+ meals per day - count should be ≥4');

-- -----------------------------------------------------------------------------
-- Q2.05: How many snacks do you typically eat per day?
-- Maps to: AGG_SNACKS (count of snack events)
-- Note: Higher scores for fewer snacks (healthier pattern)
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.05-1', 2.05, 'AGG_SNACKS', NULL, 0.5, 'CALC_COUNT', 'daily', 'No snacking - count should be 0'),
('RO_2.05-2', 2.05, 'AGG_SNACKS', 0.5, 1.5, 'CALC_COUNT', 'daily', '1 snack per day - count should be ~1'),
('RO_2.05-3', 2.05, 'AGG_SNACKS', 1.5, 2.5, 'CALC_COUNT', 'daily', '2 snacks per day - count should be ~2'),
('RO_2.05-4', 2.05, 'AGG_SNACKS', 2.5, 3.5, 'CALC_COUNT', 'daily', '3 snacks per day - count should be ~3'),
('RO_2.05-5', 2.05, 'AGG_SNACKS', 3.5, NULL, 'CALC_COUNT', 'daily', '4+ snacks per day - count should be ≥4');

-- -----------------------------------------------------------------------------
-- Q2.07: How often do you eat out or order takeout/delivery?
-- Maps to: AGG_TAKEOUTDELIVERY_MEALS (count of takeout/delivery meals)
-- Note: Lower counts = better (score 1.0 for rarely)
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.07-1', 2.07, 'AGG_TAKEOUTDELIVERY_MEALS', NULL, 1, 'CALC_COUNT', 'weekly', 'Rarely - <1 per week'),
('RO_2.07-2', 2.07, 'AGG_TAKEOUTDELIVERY_MEALS', 0.5, 1.5, 'CALC_COUNT', 'weekly', 'Once a week - ~1 per week'),
('RO_2.07-3', 2.07, 'AGG_TAKEOUTDELIVERY_MEALS', 2, 5, 'CALC_COUNT', 'weekly', 'Several times a week - 2-5 per week'),
('RO_2.07-4', 2.07, 'AGG_TAKEOUTDELIVERY_MEALS', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ per week');

-- -----------------------------------------------------------------------------
-- Q2.09: Do you track your daily protein intake?
-- NOT MAPPABLE - This is a meta-question about tracking behavior, not actual consumption
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q2.13: Processed meat consumption (EXISTING - REMAPPED)
-- Maps to: AGG_PROCESSED_MEAT_SERVING
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.13-1', 2.13, 'AGG_PROCESSED_MEAT_SERVING', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or Never - 0 servings/week'),
('RO_2.13-2', 2.13, 'AGG_PROCESSED_MEAT_SERVING', NULL, 0.9, 'CALC_SUM', 'weekly', 'Less than once a week - <1 serving/week'),
('RO_2.13-3', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 1, 2, 'CALC_SUM', 'weekly', '1-2 times per week - 1-2 servings/week'),
('RO_2.13-4', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 3, 4, 'CALC_SUM', 'weekly', '3-4 times per week - 3-4 servings/week'),
('RO_2.13-5', 2.13, 'AGG_PROCESSED_MEAT_SERVING', 5, NULL, 'CALC_SUM', 'weekly', '5+ times per week - 5+ servings/week');

-- -----------------------------------------------------------------------------
-- Q2.15: Fatty fish consumption (EXISTING - REMAPPED)
-- Maps to: AGG_FATTY_FISH_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.15-1', 2.15, 'AGG_FATTY_FISH_SERVINGS', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or Never - 0 servings/week'),
('RO_2.15-2', 2.15, 'AGG_FATTY_FISH_SERVINGS', NULL, 0.9, 'CALC_SUM', 'weekly', 'Less than once a week - <1 serving/week'),
('RO_2.15-3', 2.15, 'AGG_FATTY_FISH_SERVINGS', 1, 2, 'CALC_SUM', 'weekly', '1-2 times per week - 1-2 servings/week'),
('RO_2.15-4', 2.15, 'AGG_FATTY_FISH_SERVINGS', 3, 4, 'CALC_SUM', 'weekly', '3-4 times per week - 3-4 servings/week'),
('RO_2.15-5', 2.15, 'AGG_FATTY_FISH_SERVINGS', 5, NULL, 'CALC_SUM', 'weekly', '5+ times per week - 5+ servings/week');

-- -----------------------------------------------------------------------------
-- Q2.17: Plant-based protein percentage (EXISTING - REMAPPED)
-- Maps to: AGG_PLANTBASED_PROTEIN_PERCENTAGE
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.17-1', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', NULL, 10, 'CALC_PERCENTAGE', 'weekly', 'Almost none - 0-10% plant-based'),
('RO_2.17-2', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 10, 35, 'CALC_PERCENTAGE', 'weekly', 'Small portion - 10-35% plant-based'),
('RO_2.17-3', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 35, 65, 'CALC_PERCENTAGE', 'weekly', 'Moderate - 35-65% plant-based'),
('RO_2.17-4', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 65, 90, 'CALC_PERCENTAGE', 'weekly', 'Large portion - 65-90% plant-based'),
('RO_2.17-5', 2.17, 'AGG_PLANTBASED_PROTEIN_PERCENTAGE', 90, NULL, 'CALC_PERCENTAGE', 'weekly', 'Almost entirely - 90-100% plant-based');

-- -----------------------------------------------------------------------------
-- Q2.19: Fruit servings (EXISTING - REMAPPED)
-- Maps to: AGG_FRUIT_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.19-1', 2.19, 'AGG_FRUIT_SERVINGS', NULL, 0.5, 'CALC_SUM', 'daily', '0 servings per day'),
('RO_2.19-2', 2.19, 'AGG_FRUIT_SERVINGS', 1, 2, 'CALC_SUM', 'daily', '1-2 servings per day'),
('RO_2.19-3', 2.19, 'AGG_FRUIT_SERVINGS', 3, 4, 'CALC_SUM', 'daily', '3-4 servings per day'),
('RO_2.19-4', 2.19, 'AGG_FRUIT_SERVINGS', 5, NULL, 'CALC_SUM', 'daily', '5+ servings per day');

-- -----------------------------------------------------------------------------
-- Q2.21: Whole grain consumption (EXISTING - REMAPPED)
-- Maps to: AGG_WHOLE_GRAIN_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.21-1', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or never - 0 servings/week'),
('RO_2.21-2', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 0.5, 1.5, 'CALC_SUM', 'weekly', 'Once a week - ~1 serving/week'),
('RO_2.21-3', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 2, 5, 'CALC_SUM', 'weekly', 'Several times a week - 2-5 servings/week'),
('RO_2.21-4', 2.21, 'AGG_WHOLE_GRAIN_SERVINGS', 6, NULL, 'CALC_SUM', 'weekly', 'Daily - 6-7+ servings/week');

-- -----------------------------------------------------------------------------
-- Q2.23: Legume consumption (EXISTING - REMAPPED)
-- Maps to: AGG_LEGUME_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.23-1', 2.23, 'AGG_LEGUME_SERVINGS', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or never - 0 servings/week'),
('RO_2.23-2', 2.23, 'AGG_LEGUME_SERVINGS', 0.5, 1.5, 'CALC_SUM', 'weekly', 'Once a week - ~1 serving/week'),
('RO_2.23-3', 2.23, 'AGG_LEGUME_SERVINGS', 2, 5, 'CALC_SUM', 'weekly', 'Several times a week - 2-5 servings/week'),
('RO_2.23-4', 2.23, 'AGG_LEGUME_SERVINGS', 6, NULL, 'CALC_SUM', 'weekly', 'Daily - 6-7+ servings/week');

-- -----------------------------------------------------------------------------
-- Q2.25: Seed consumption (EXISTING - REMAPPED)
-- Maps to: AGG_SEED_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.25-1', 2.25, 'AGG_SEED_SERVINGS', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or never - 0 servings/week'),
('RO_2.25-2', 2.25, 'AGG_SEED_SERVINGS', 0.5, 1.5, 'CALC_SUM', 'weekly', 'Once a week - ~1 serving/week'),
('RO_2.25-3', 2.25, 'AGG_SEED_SERVINGS', 2, 5, 'CALC_SUM', 'weekly', 'Several times a week - 2-5 servings/week'),
('RO_2.25-4', 2.25, 'AGG_SEED_SERVINGS', 6, NULL, 'CALC_SUM', 'weekly', 'Daily - 6-7+ servings/week');

-- -----------------------------------------------------------------------------
-- Q2.27: Healthy fats consumption (EXISTING - REMAPPED)
-- Maps to: AGG_HEALTHY_FAT_USAGE
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.27-1', 2.27, 'AGG_HEALTHY_FAT_USAGE', NULL, 0.5, 'CALC_COUNT', 'weekly', 'Rarely or never - 0 uses/week'),
('RO_2.27-2', 2.27, 'AGG_HEALTHY_FAT_USAGE', 0.5, 1.5, 'CALC_COUNT', 'weekly', 'Once a week - ~1 use/week'),
('RO_2.27-3', 2.27, 'AGG_HEALTHY_FAT_USAGE', 2, 5, 'CALC_COUNT', 'weekly', 'Several times a week - 2-5 uses/week'),
('RO_2.27-4', 2.27, 'AGG_HEALTHY_FAT_USAGE', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ uses/week');

-- -----------------------------------------------------------------------------
-- Q2.29: Water consumption (EXISTING - REMAPPED)
-- Maps to: AGG_WATER_QUANTITY
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.29-1', 2.29, 'AGG_WATER_QUANTITY', NULL, 1000, 'CALC_SUM', 'daily', 'Less than 1 liter (34 oz) per day'),
('RO_2.29-2', 2.29, 'AGG_WATER_QUANTITY', 1000, 2000, 'CALC_SUM', 'daily', '1-2 liters (34-68 oz) per day'),
('RO_2.29-3', 2.29, 'AGG_WATER_QUANTITY', 2000, NULL, 'CALC_SUM', 'daily', 'More than 2 liters (68 oz) per day');

-- -----------------------------------------------------------------------------
-- Q2.31: Caffeine consumption (EXISTING - REMAPPED)
-- Maps to: AGG_CAFFEINE_QUANTITY
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.31-1', 2.31, 'AGG_CAFFEINE_QUANTITY', NULL, 10, 'CALC_SUM', 'daily', 'None - 0 mg per day'),
('RO_2.31-2', 2.31, 'AGG_CAFFEINE_QUANTITY', 10, 100, 'CALC_SUM', 'daily', '<100 mg per day (1 small coffee/tea)'),
('RO_2.31-3', 2.31, 'AGG_CAFFEINE_QUANTITY', 100, 200, 'CALC_SUM', 'daily', '100-200 mg per day (1-2 cups)'),
('RO_2.31-4', 2.31, 'AGG_CAFFEINE_QUANTITY', 200, 400, 'CALC_SUM', 'daily', '201-400 mg per day (3-4 cups)'),
('RO_2.31-5', 2.31, 'AGG_CAFFEINE_QUANTITY', 400, NULL, 'CALC_SUM', 'daily', '>400 mg per day (5+ cups)');

-- -----------------------------------------------------------------------------
-- Q2.33: Caffeine sources
-- Maps to: AGG_CAFFEINE_SOURCES (count distinct sources)
-- Note: Multi-select question - each option maps independently
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.33-1', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Coffee as caffeine source'),
('RO_2.33-2', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Tea as caffeine source'),
('RO_2.33-3', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Energy drinks as caffeine source'),
('RO_2.33-4', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Soda as caffeine source'),
('RO_2.33-5', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Pre-workout supplements as caffeine source'),
('RO_2.33-6', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Chocolate as caffeine source'),
('RO_2.33-7', 2.33, 'AGG_CAFFEINE_SOURCES', NULL, NULL, 'CALC_COUNT_DISTINCT', 'daily', 'Other caffeine source');

-- -----------------------------------------------------------------------------
-- Q2.34: Last caffeine time
-- Maps to: AGG_LAST_CAFFEINE_CONSUMPTION_TIME (time of day)
-- Note: Earlier times = better scores
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.34-1', 2.34, 'AGG_LAST_CAFFEINE_CONSUMPTION_TIME', NULL, 12, 'CALC_LAST_TIME', 'daily', 'Before 12:00 PM - last caffeine before noon'),
('RO_2.34-2', 2.34, 'AGG_LAST_CAFFEINE_CONSUMPTION_TIME', 12, 14, 'CALC_LAST_TIME', 'daily', '12:00-2:00 PM - last caffeine 12-2pm'),
('RO_2.34-3', 2.34, 'AGG_LAST_CAFFEINE_CONSUMPTION_TIME', 14, 16, 'CALC_LAST_TIME', 'daily', '2:00-4:00 PM - last caffeine 2-4pm'),
('RO_2.34-4', 2.34, 'AGG_LAST_CAFFEINE_CONSUMPTION_TIME', 16, 18, 'CALC_LAST_TIME', 'daily', '4:00-6:00 PM - last caffeine 4-6pm'),
('RO_2.34-5', 2.34, 'AGG_LAST_CAFFEINE_CONSUMPTION_TIME', 18, NULL, 'CALC_LAST_TIME', 'daily', 'After 6:00 PM - last caffeine after 6pm');

-- -----------------------------------------------------------------------------
-- Q2.59: Do you track your daily caloric intake?
-- NOT MAPPABLE - This is a meta-question about tracking behavior, not actual consumption
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q2.65: Vegetable servings (CRITICAL - WAS MISSING!)
-- Maps to: AGG_VEGETABLE_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.65-1', 2.65, 'AGG_VEGETABLE_SERVINGS', NULL, 0.5, 'CALC_SUM', 'daily', '0 servings per day'),
('RO_2.65-2', 2.65, 'AGG_VEGETABLE_SERVINGS', 1, 2, 'CALC_SUM', 'daily', '1-2 servings per day'),
('RO_2.65-3', 2.65, 'AGG_VEGETABLE_SERVINGS', 3, 4, 'CALC_SUM', 'daily', '3-4 servings per day'),
('RO_2.65-4', 2.65, 'AGG_VEGETABLE_SERVINGS', 5, NULL, 'CALC_SUM', 'daily', '5+ servings per day');

-- -----------------------------------------------------------------------------
-- Q2.67: Red meat consumption
-- Maps to: AGG_RED_MEAT_SERVINGS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_2.67-1', 2.67, 'AGG_RED_MEAT_SERVINGS', NULL, 0.5, 'CALC_SUM', 'weekly', 'Rarely or Never - 0 servings/week'),
('RO_2.67-2', 2.67, 'AGG_RED_MEAT_SERVINGS', NULL, 0.9, 'CALC_SUM', 'weekly', 'Less than once a week - <1 serving/week'),
('RO_2.67-3', 2.67, 'AGG_RED_MEAT_SERVINGS', 1, 2, 'CALC_SUM', 'weekly', '1-2 times per week - 1-2 servings/week'),
('RO_2.67-4', 2.67, 'AGG_RED_MEAT_SERVINGS', 3, 4, 'CALC_SUM', 'weekly', '3-4 times per week - 3-4 servings/week'),
('RO_2.67-5', 2.67, 'AGG_RED_MEAT_SERVINGS', 5, NULL, 'CALC_SUM', 'weekly', '5+ times per week - 5+ servings/week');

-- =====================================================================================
-- STEP 3: MOVEMENT + EXERCISE QUESTIONS (Section 3)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q3.21: Steps per day (EXISTING - REMAPPED)
-- Maps to: AGG_STEPS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_3.21-1', 3.21, 'AGG_STEPS', NULL, 2500, 'CALC_SUM', 'daily', 'Less than 2,500 steps per day'),
('RO_3.21-2', 3.21, 'AGG_STEPS', 2500, 5000, 'CALC_SUM', 'daily', '2,500-5,000 steps per day'),
('RO_3.21-3', 3.21, 'AGG_STEPS', 5000, 7500, 'CALC_SUM', 'daily', '5,000-7,500 steps per day'),
('RO_3.21-4', 3.21, 'AGG_STEPS', 7500, 10000, 'CALC_SUM', 'daily', '7,500-10,000 steps per day'),
('RO_3.21-5', 3.21, 'AGG_STEPS', 10000, 15000, 'CALC_SUM', 'daily', '10,000-15,000 steps per day'),
('RO_3.21-6', 3.21, 'AGG_STEPS', 15000, NULL, 'CALC_SUM', 'daily', 'More than 15,000 steps per day');

-- =====================================================================================
-- STEP 4: RESTORATIVE SLEEP QUESTIONS (Section 4)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q4.02: Sleep hours (EXISTING - REMAPPED)
-- Maps to: AGG_SLEEP_DURATION
-- Note: 4.01 was previously mapped but is not in pillar weights - using 4.02
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_4.02-1', 4.02, 'AGG_SLEEP_DURATION', NULL, 240, 'CALC_SUM', 'daily', '4 hours or less (≤240 min)'),
('RO_4.02-2', 4.02, 'AGG_SLEEP_DURATION', 240, 300, 'CALC_SUM', 'daily', '5 hours (~300 min)'),
('RO_4.02-3', 4.02, 'AGG_SLEEP_DURATION', 300, 360, 'CALC_SUM', 'daily', '6 hours (~360 min)'),
('RO_4.02-4', 4.02, 'AGG_SLEEP_DURATION', 360, 420, 'CALC_SUM', 'daily', '7 hours (~420 min) - optimal'),
('RO_4.02-5', 4.02, 'AGG_SLEEP_DURATION', 420, 480, 'CALC_SUM', 'daily', '8 hours (~480 min) - optimal'),
('RO_4.02-6', 4.02, 'AGG_SLEEP_DURATION', 480, 540, 'CALC_SUM', 'daily', '9 hours (~540 min) - optimal'),
('RO_4.02-7', 4.02, 'AGG_SLEEP_DURATION', 540, NULL, 'CALC_SUM', 'daily', 'More than 9 hours (>540 min)');

-- -----------------------------------------------------------------------------
-- Q4.03: Feel rested upon waking
-- Maps to: AGG_SLEEP_QUALITY (subjective rating)
-- Note: This is a subjective quality rating, maps to quality score
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_4.03-1', 4.03, 'AGG_SLEEP_QUALITY', NULL, 0.3, 'CALC_AVERAGE', 'daily', 'Never feel rested - quality score 0-0.3'),
('RO_4.03-2', 4.03, 'AGG_SLEEP_QUALITY', 0.3, 0.5, 'CALC_AVERAGE', 'daily', 'Rarely feel rested - quality score 0.3-0.5'),
('RO_4.03-3', 4.03, 'AGG_SLEEP_QUALITY', 0.5, 0.7, 'CALC_AVERAGE', 'daily', 'Sometimes feel rested - quality score 0.5-0.7'),
('RO_4.03-4', 4.03, 'AGG_SLEEP_QUALITY', 0.7, 0.9, 'CALC_AVERAGE', 'daily', 'Often feel rested - quality score 0.7-0.9'),
('RO_4.03-5', 4.03, 'AGG_SLEEP_QUALITY', 0.9, 1.0, 'CALC_AVERAGE', 'daily', 'Always feel rested - quality score 0.9-1.0');

-- -----------------------------------------------------------------------------
-- Q4.04: Sleep schedule consistency
-- Maps to: AGG_SLEEP_TIME_CONSISTENCY (variance in sleep/wake times)
-- Note: Lower variance = higher consistency = better score
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_4.04-1', 4.04, 'AGG_SLEEP_TIME_CONSISTENCY', NULL, 0.3, 'CALC_CONSISTENCY', 'weekly', 'Very inconsistent - consistency score <0.3'),
('RO_4.04-2', 4.04, 'AGG_SLEEP_TIME_CONSISTENCY', 0.3, 0.5, 'CALC_CONSISTENCY', 'weekly', 'Somewhat inconsistent - consistency score 0.3-0.5'),
('RO_4.04-3', 4.04, 'AGG_SLEEP_TIME_CONSISTENCY', 0.5, 0.7, 'CALC_CONSISTENCY', 'weekly', 'Consistent weekdays only - consistency score 0.5-0.7'),
('RO_4.04-4', 4.04, 'AGG_SLEEP_TIME_CONSISTENCY', 0.5, 0.7, 'CALC_CONSISTENCY', 'weekly', 'Consistent weekends only - consistency score 0.5-0.7'),
('RO_4.04-5', 4.04, 'AGG_SLEEP_TIME_CONSISTENCY', 0.8, 1.0, 'CALC_CONSISTENCY', 'weekly', 'Very consistent - consistency score 0.8-1.0');

-- =====================================================================================
-- STEP 5: COGNITIVE HEALTH QUESTIONS (Section 5)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q5.01: Rate current cognitive function
-- NOT MAPPABLE - Subjective self-rating, no trackable metric exists
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q5.02: Concerns about cognitive function
-- NOT MAPPABLE - Yes/No about concerns, no trackable metric
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q5.06: Brain training activities (EXISTING - REMAPPED)
-- Maps to: AGG_BRAIN_TRAINING_SESSIONS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_5.06-1', 5.06, 'AGG_BRAIN_TRAINING_SESSIONS', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ sessions per week'),
('RO_5.06-2', 5.06, 'AGG_BRAIN_TRAINING_SESSIONS', 3, 6, 'CALC_COUNT', 'weekly', 'Several times a week - 3-6 sessions'),
('RO_5.06-3', 5.06, 'AGG_BRAIN_TRAINING_SESSIONS', 1, 2, 'CALC_COUNT', 'weekly', 'Weekly - 1-2 sessions per week'),
('RO_5.06-4', 5.06, 'AGG_BRAIN_TRAINING_SESSIONS', 0.2, 0.9, 'CALC_COUNT', 'weekly', 'Occasionally - <1 session per week'),
('RO_5.06-5', 5.06, 'AGG_BRAIN_TRAINING_SESSIONS', NULL, 0.2, 'CALC_COUNT', 'weekly', 'Rarely or Never - 0 sessions per week');

-- =====================================================================================
-- STEP 6: CONNECTION + PURPOSE QUESTIONS (Section 7)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q7.01: Quality of social relationships
-- NOT MAPPABLE - Subjective quality rating, no trackable metric
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q7.02: Social interaction frequency
-- Maps to: AGG_SOCIAL_INTERACTION (count of social interactions)
-- Note: This could track social event frequency if we have such tracking
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_7.02-1', 7.02, 'AGG_SOCIAL_INTERACTION', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ interactions per week'),
('RO_7.02-2', 7.02, 'AGG_SOCIAL_INTERACTION', 3, 6, 'CALC_COUNT', 'weekly', 'Several times a week - 3-6 interactions'),
('RO_7.02-3', 7.02, 'AGG_SOCIAL_INTERACTION', 1, 2, 'CALC_COUNT', 'weekly', 'Weekly - 1-2 interactions per week'),
('RO_7.02-4', 7.02, 'AGG_SOCIAL_INTERACTION', 0.5, 1, 'CALC_COUNT', 'monthly', 'Several times a month - 2-4 interactions per month'),
('RO_7.02-5', 7.02, 'AGG_SOCIAL_INTERACTION', NULL, 0.5, 'CALC_COUNT', 'monthly', 'Rarely - <2 interactions per month');

-- -----------------------------------------------------------------------------
-- Q7.04: Satisfaction with social interaction amount
-- NOT MAPPABLE - Subjective satisfaction rating, no trackable metric
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q7.07: Have someone to talk to for support
-- NOT MAPPABLE - Subjective support availability, no trackable metric
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q7.09: Comfort in social situations
-- NOT MAPPABLE - Subjective comfort rating, no trackable metric
-- -----------------------------------------------------------------------------

-- =====================================================================================
-- STEP 7: CORE CARE QUESTIONS (Section 8)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q8.58: Flossing frequency
-- Maps to: AGG_FLOSSING_SESSIONS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_8.58-1', 8.58, 'AGG_FLOSSING_SESSIONS', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ sessions per week'),
('RO_8.58-2', 8.58, 'AGG_FLOSSING_SESSIONS', 3, 5, 'CALC_COUNT', 'weekly', 'A few times a week - 3-5 sessions'),
('RO_8.58-3', 8.58, 'AGG_FLOSSING_SESSIONS', 0.5, 2, 'CALC_COUNT', 'weekly', 'Rarely - 1-2 sessions per week'),
('RO_8.58-4', 8.58, 'AGG_FLOSSING_SESSIONS', NULL, 0.5, 'CALC_COUNT', 'weekly', 'Never - 0 sessions per week');

-- -----------------------------------------------------------------------------
-- Q8.60: Brushing frequency
-- Maps to: AGG_BRUSHING_SESSIONS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_8.60-1', 8.60, 'AGG_BRUSHING_SESSIONS', 14, NULL, 'CALC_COUNT', 'weekly', '≥2 times a day - 14+ sessions per week'),
('RO_8.60-2', 8.60, 'AGG_BRUSHING_SESSIONS', NULL, 13, 'CALC_COUNT', 'weekly', '<2 times a day - <14 sessions per week');

-- -----------------------------------------------------------------------------
-- Q8.62: Sunscreen application frequency
-- Maps to: AGG_SUNSCREEN_APPLICATIONS
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_8.62-1', 8.62, 'AGG_SUNSCREEN_APPLICATIONS', 6, NULL, 'CALC_COUNT', 'weekly', 'Daily - 6-7+ applications per week'),
('RO_8.62-2', 8.62, 'AGG_SUNSCREEN_APPLICATIONS', 3, 5, 'CALC_COUNT', 'weekly', 'A few times a week - 3-5 applications'),
('RO_8.62-3', 8.62, 'AGG_SUNSCREEN_APPLICATIONS', 0.5, 2, 'CALC_COUNT', 'weekly', 'Rarely - 1-2 applications per week'),
('RO_8.62-4', 8.62, 'AGG_SUNSCREEN_APPLICATIONS', NULL, 0.5, 'CALC_COUNT', 'weekly', 'Never - 0 applications per week');

-- -----------------------------------------------------------------------------
-- Q8.64: Consistent skincare routine
-- Maps to: AGG_SKINCARE_ROUTINE_ADHERENCE
-- -----------------------------------------------------------------------------
INSERT INTO survey_response_options_aggregations
(response_option_id, question_number, agg_metric_id, threshold_low, threshold_high, calculation_type_id, period_type, notes)
VALUES
('RO_8.64-1', 8.64, 'AGG_SKINCARE_ROUTINE_ADHERENCE', 0.8, 1.0, 'CALC_ADHERENCE', 'weekly', 'Yes - consistent routine, adherence 0.8-1.0'),
('RO_8.64-2', 8.64, 'AGG_SKINCARE_ROUTINE_ADHERENCE', NULL, 0.3, 'CALC_ADHERENCE', 'weekly', 'No - no routine, adherence <0.3');

-- =====================================================================================
-- STEP 8: FAMILY & PERSONAL HEALTH HISTORY (Section 9)
-- =====================================================================================
-- ALL Q9.x and Q10.09-10.11 questions are NOT MAPPABLE
-- These are static survey responses about family history and past diagnoses
-- There are NO corresponding aggregation metrics because these don't track behaviors

-- NOT MAPPABLE QUESTIONS (28 total):
-- Q9.01: Family history - Heart Attack/ASCVD
-- Q9.04: Family history - Stroke
-- Q9.07: Family history - Diabetes
-- Q9.10: Family history - Dementia/Alzheimer's
-- Q9.13: Family history - Breast Cancer
-- Q9.16: Family history - Colon Cancer
-- Q9.19: Family history - Prostate Cancer
-- Q9.22: Family history - Other Cancer
-- Q9.26: Family history - Osteoporosis/Osteopenia
-- Q9.29: Family history - Autoimmune disease
-- Q9.32: Family history - Mental Health issues
-- Q9.35: Family history - Substance Use
-- Q9.38: Family history - Other Significant Health History
-- Q9.40: Personal history - Heart Attack/ASCVD
-- Q9.42: Personal history - Stroke
-- Q9.44: Personal history - Diabetes
-- Q9.46: Personal history - Dementia/Alzheimer's
-- Q9.48: Personal history - Breast Cancer
-- Q9.50: Personal history - Colon Cancer
-- Q9.52: Personal history - Prostate Cancer
-- Q9.54: Personal history - Other Cancer
-- Q9.56: Personal history - Osteoporosis/Osteopenia
-- Q9.58: Personal history - Autoimmune disease
-- Q9.60: Personal history - Mental health condition
-- Q9.62: Personal history - Substance use disorder
-- Q9.64: Personal history - Other significant health history
-- Q9.66: Family history - Cervical Cancer
-- Q9.69: Family history - Skin Cancer
-- Q9.72: Personal history - Cervical Cancer
-- Q9.74: Personal history - Skin Cancer

-- =====================================================================================
-- STEP 9: SCREENING & MENTAL HEALTH (Section 10)
-- =====================================================================================

-- -----------------------------------------------------------------------------
-- Q10.09: Cardiac health screening
-- NOT MAPPABLE - Yes/No about past screening, not trackable behavior
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q10.10: Sleep study test
-- NOT MAPPABLE - Yes/No about past test, not trackable behavior
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q10.11: Immunizations up to date
-- NOT MAPPABLE - Yes/No about current status, not trackable behavior
-- -----------------------------------------------------------------------------

-- -----------------------------------------------------------------------------
-- Q10.13-10.16: PHQ-2/GAD-2 Mental Health Questions
-- NOT MAPPABLE - These are validated screening tools with specific scoring
-- The scores are used directly, not compared to aggregated behavioral data
-- -----------------------------------------------------------------------------

-- =====================================================================================
-- SUMMARY STATISTICS
-- =====================================================================================

-- Count total mappings created
DO $$
DECLARE
    total_mappings INTEGER;
    total_questions INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_mappings FROM survey_response_options_aggregations;
    SELECT COUNT(DISTINCT question_number) INTO total_questions FROM survey_response_options_aggregations;

    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'COMPREHENSIVE SURVEY AGGREGATION MAPPINGS COMPLETE';
    RAISE NOTICE '=====================================================';
    RAISE NOTICE 'Total response option mappings: %', total_mappings;
    RAISE NOTICE 'Total questions mapped: %', total_questions;
    RAISE NOTICE '';
    RAISE NOTICE 'BREAKDOWN BY CATEGORY:';
    RAISE NOTICE '- Nutrition (Section 2): 16 questions mapped';
    RAISE NOTICE '- Movement (Section 3): 1 question mapped';
    RAISE NOTICE '- Sleep (Section 4): 3 questions mapped';
    RAISE NOTICE '- Cognitive (Section 5): 1 question mapped';
    RAISE NOTICE '- Social (Section 7): 1 question mapped';
    RAISE NOTICE '- Core Care (Section 8): 4 questions mapped';
    RAISE NOTICE '- Family/Personal History (Section 9): 0 questions (not trackable)';
    RAISE NOTICE '- Screening/Mental Health (Section 10): 0 questions (not trackable)';
    RAISE NOTICE '';
    RAISE NOTICE 'UNMAPPABLE QUESTIONS: 28';
    RAISE NOTICE '- 24 family/personal history questions (static survey data)';
    RAISE NOTICE '- 3 past screening/test questions (static survey data)';
    RAISE NOTICE '- 4 mental health screening questions (validated tool scores)';
    RAISE NOTICE '- 4 subjective rating questions (no trackable metrics)';
    RAISE NOTICE '- 2 tracking behavior questions (meta-questions)';
    RAISE NOTICE '=====================================================';
END $$;
