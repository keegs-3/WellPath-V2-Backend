-- =====================================================
-- Create All Display Metrics
-- =====================================================
-- Generated from display_metrics mapping
-- Creates display_metrics entries for all tracked metrics
--
-- Created: 2025-10-22
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Display Metrics
-- =====================================================

-- Cognitive Health (9 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_195', 'Brain Training Duration', 'Cognitive Health', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_194', 'Brain Training Sessions', 'Cognitive Health', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_207', 'Early Morning Light Exposure Duration', 'Cognitive Health', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_197', 'Focus Rating', 'Cognitive Health', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_196', 'Journaling Sessions', 'Cognitive Health', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_198', 'Memory Clarity Rating', 'Cognitive Health', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_186', 'Mood Rating', 'Cognitive Health', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_206', 'Sunlight Exposure Duration', 'Cognitive Health', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_205', 'Sunlight Exposure Sessions', 'Cognitive Health', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Connection + Purpose (11 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_188', 'Gratitude Sessions', 'Connection + Purpose', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_200', 'Mindfulness Duration', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_199', 'Mindfulness Sessions', 'Connection + Purpose', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_191', 'Morning Outdoor Time Duration', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_190', 'Outdoor Time Duration', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_189', 'Outdoor Time Sessions', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_193', 'Screen Time Duration', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_192', 'Screen Time Sessions', 'Connection + Purpose', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_187', 'Social Interaction', 'Connection + Purpose', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_185', 'Stress Level Rating', 'Connection + Purpose', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_184', 'Stress Management Duration', 'Connection + Purpose', 'chart', 'progress_bar', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Core Care (52 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_179', 'Alcoholic Drinks', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_180', 'Alcoholic Drinks vs. Baseline', 'Core Care', 'chart', 'comparison_view', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_212', 'BMI (Calculated)', 'Core Care', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_247', 'Body Fat Percentage', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_162', 'Breast MRI Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_171', 'Brushing Sessions', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_163', 'Cervical Screening Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_164', 'Cervical Screening Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_177', 'Cigarettes', 'Core Care', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_178', 'Cigarettes vs. Baseline', 'Core Care', 'chart', 'comparison_view', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_157', 'Colonoscopy Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_158', 'Colonoscopy Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_243', 'Current Weight', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_152', 'Dental Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_248', 'Diastolic Blood Pressure', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_139', 'Digital Shutoff Buffer', 'Core Care', 'chart', 'current_value', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_209', 'Evening Routine Adherence', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_170', 'Flossing Sessions', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_244', 'Height', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_213', 'Hip to Waist Ratio', 'Core Care', 'chart', 'trend_line', 'ratio', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_141', 'Last Caffeine Consumption Buffer', 'Core Care', 'chart', 'trend_line', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_140', 'Last Caffeine Consumption Time', 'Core Care', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_161', 'Mammogram Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_160', 'Mammogram Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_159', 'Mammogram Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_168', 'Medication Adherence', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_148', 'Months Since Last Breast MRI', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_142', 'Months Since Last Dental Exam', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_147', 'Months Since Last Mammogram', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_144', 'Months Since Last Skin Check', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_145', 'Months Since Last Vision Check', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_174', 'Morning Sunscreen Applications', 'Core Care', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_169', 'Peptide Adherence', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_153', 'Physical Exam Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_166', 'PSA Test Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_165', 'PSA Test Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_154', 'Skin Check Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_155', 'Skin Check Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_172', 'Skincare Routine Adherence', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_173', 'Sunscreen Applications', 'Core Care', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_175', 'Sunscreen Compliance Events', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_176', 'Sunscreen Compliance Rate', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_167', 'Supplement Adherence', 'Core Care', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_249', 'Systolic Blood Pressure', 'Core Care', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_211', 'User Age', 'Core Care', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_156', 'Vision Check Compliance Status', 'Core Care', 'chart', 'current_value', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_210', 'Walking Duration', 'Core Care', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_146', 'Years Since Last Colonoscopy', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_149', 'Years Since Last HPV Screening', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_150', 'Years Since Last Pap Test', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_143', 'Years Since Last Physical', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_151', 'Years Since Last PSA Test', 'Core Care', 'chart', 'current_value', 'months', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Healthful Nutrition (115 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_098', 'Added Sugar Consumed', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_097', 'Added Sugar Servings', 'Healthful Nutrition', 'chart', 'progress_bar', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_099', 'Added Sugar Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_101', 'Added Sugar Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_100', 'Added Sugar Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_002', 'Breakfast', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_070', 'Breakfast Total Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_102', 'Caffeine Consumed', 'Healthful Nutrition', 'chart', 'progress_bar', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_004', 'Dinner', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_072', 'Dinner Total Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_031', 'Eating Window Duration', 'Healthful Nutrition', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_087', 'Fat Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_088', 'Fat Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_215', 'Fatty Fish Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_051', 'Fiber Grams', 'Healthful Nutrition', 'chart', 'bar_vertical', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_052', 'Fiber Servings', 'Healthful Nutrition', 'chart', 'progress_bar', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_053', 'Fiber Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_055', 'Fiber Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_054', 'Fiber Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_056', 'Fiber Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_FIBER_SOURCE_VARIETY', 'Fiber Source Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_057', 'Fiber Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_011', 'First Meal Delay', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_012', 'First Meal Time', 'Healthful Nutrition', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_033', 'Fruit Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_034', 'Fruit Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_036', 'Fruit Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_035', 'Fruit Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_037', 'Fruit Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_038', 'Fruit Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_FRUIT_VARIETY', 'Fruit Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_073', 'Healthy Fat Ratio', 'Healthful Nutrition', 'chart', 'trend_line', 'ratio', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_081', 'Healthy Fat Swaps', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_082', 'Healthy Fat Swaps: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_084', 'Healthy Fat Swaps: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_083', 'Healthy Fat Swaps: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_085', 'Healthy Fat Usage', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_005', 'Large Meals', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_006', 'Large Meals: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_008', 'Large Meals: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_007', 'Large Meals: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_010', 'Last Large Meal Buffer', 'Healthful Nutrition', 'chart', 'current_value', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_009', 'Last Large Meal Time', 'Healthful Nutrition', 'chart', 'current_value', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_014', 'Last Meal Buffer', 'Healthful Nutrition', 'chart', 'current_value', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_013', 'Last Meal Time', 'Healthful Nutrition', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_064', 'Legume Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_065', 'Legume Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_067', 'Legume Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_066', 'Legume Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_068', 'Legume Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_069', 'Legume Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_LEGUME_VARIETY', 'Legume Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_003', 'Lunch', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_071', 'Lunch Total Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_001', 'Meals', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_015', 'Mindful Eating Episodes', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_016', 'Mindful Eating: Breakfast', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_018', 'Mindful Eating: Dinner', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_017', 'Mindful Eating: Lunch', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_075', 'Monounaturated Fat (g)', 'Healthful Nutrition', 'chart', 'trend_line', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_NUT_SEED_VARIETY', 'Nut/Seed Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_027', 'Plant Based Meal', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_028', 'Plant Based Meals: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_030', 'Plant Based Meals: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_029', 'Plant Based Meals: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_218', 'plant-based protein (grams)', 'Healthful Nutrition', 'chart', 'bar_vertical', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_217', 'Plant-Based Protein Percentage', 'Healthful Nutrition', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_074', 'Polyunsaturated Fat (g)', 'Healthful Nutrition', 'chart', 'trend_line', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_094', 'Process Meat: Breakfast', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_096', 'Process Meat: Dinner', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_095', 'Process Meat: Lunch', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_093', 'Processed Meat Serving', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_045', 'Protein Grams', 'Healthful Nutrition', 'chart', 'progress_bar', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_046', 'Protein per Kilogram Body Weight', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_050', 'Protein Servings', 'Healthful Nutrition', 'chart', 'progress_bar', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_047', 'Protein Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_049', 'Protein Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_048', 'Protein Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_PROTEIN_VARIETY', 'Protein Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_214', 'Red Meat Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_076', 'Saturated Fat (g)', 'Healthful Nutrition', 'chart', 'trend_line', 'gram', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_077', 'Saturated Fat Percentage', 'Healthful Nutrition', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_078', 'Saturated Fat: Breakfast', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_080', 'Saturated Fat: Dinner', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_079', 'Saturated Fat: Lunch', 'Healthful Nutrition', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_216', 'Seed Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_032', 'Snacks', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_023', 'Takeout/Delivery Meals', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_024', 'Takeout/Delivery Meals: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_026', 'Takeout/Delivery Meals: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_025', 'Takeout/Delivery Meals: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_089', 'Ultraprocessed Food Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_090', 'Ultraprocessed Food Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_092', 'Ultraprocessed Food Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_091', 'Ultraprocessed Food Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_086', 'Unhealthy Fat Usage', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_039', 'Vegetable Servings', 'Healthful Nutrition', 'chart', 'progress_bar', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_040', 'Vegetable Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_042', 'Vegetable Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_041', 'Vegetable Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_043', 'Vegetable Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_044', 'Vegetable Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_VEGETABLE_VARIETY', 'Vegetable Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_105', 'Water Consumption', 'Healthful Nutrition', 'chart', 'progress_bar', 'fluid_ounce', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_019', 'Whole Food Meals', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_020', 'Whole Food Meals: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_022', 'Whole Food Meals: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_021', 'Whole Food Meals: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_058', 'Whole Grain Servings', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_059', 'Whole Grain Servings: Breakfast', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_061', 'Whole Grain Servings: Dinner', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_060', 'Whole Grain Servings: Lunch', 'Healthful Nutrition', 'chart', 'bar_vertical', 'serving', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_062', 'Whole Grain Source Count', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_063', 'Whole Grain Sources', 'Healthful Nutrition', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_WHOLE_GRAIN_VARIETY', 'Whole Grain Variety', 'Healthful Nutrition', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Movement + Exercise (41 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_123', 'Active Time', 'Movement + Exercise', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_258', 'Active Time Session', 'Movement + Exercise', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_126', 'Active vs Calculated Time Difference', 'Movement + Exercise', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_122', 'Activity Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_103', 'Caffeine Source Count', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_104', 'Caffeine Sources', 'Movement + Exercise', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_124', 'Calculated Active Time', 'Movement + Exercise', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_125', 'Calculated Exercise Time', 'Movement + Exercise', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_121', 'Calories', 'Movement + Exercise', 'chart', 'trend_line', 'kilocalorie', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_CARDIO_SESSIONS', 'Cardio Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_257', 'Exercise Snack', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_113', 'Exercise Snacks', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_110', 'HIIT Duration', 'Movement + Exercise', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_255', 'HIIT Session', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_109', 'HIIT Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_112', 'Mobility Duration', 'Movement + Exercise', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_256', 'Mobility Session', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_111', 'Mobility Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_133', 'Post Meal Activity Duration', 'Movement + Exercise', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_129', 'Post Meal Activity Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_130', 'Post Meal Activity Sessions: Breakfast', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_132', 'Post Meal Activity Sessions: Dinner', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_131', 'Post Meal Activity Sessions: Lunch', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_117', 'Post Meal Exercise Snacks', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_114', 'Post Meal Exercise Snacks: Breakfast', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_116', 'Post Meal Exercise Snacks: Dinner', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_115', 'Post Meal Exercise Snacks: Lunch', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_245', 'Resting Heart Rate', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_259', 'Sedentary Period', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_127', 'Sedentary Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_128', 'Sedentary Time', 'Movement + Exercise', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_106', 'Steps', 'Movement + Exercise', 'chart', 'progress_bar', 'steps', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_STRENGTH_SESSIONS', 'Strength Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_108', 'Strength Training Duration', 'Movement + Exercise', 'chart', 'progress_bar', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_254', 'Strength Training Session', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_107', 'Strength Training Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_246', 'VO2 Max', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_208', 'Walking Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_120', 'Zone 2 Cardio Duration', 'Movement + Exercise', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_119', 'Zone 2 Cardio Session', 'Movement + Exercise', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_118', 'Zone 2 Cardio Sessions', 'Movement + Exercise', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- No Pillar (1 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_SLEEP_DURATION', 'Sleep Duration', NULL, 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Restorative Sleep (34 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_230', 'Awake Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_242', 'Awake Episode Count', 'Restorative Sleep', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_260', 'Awake Percentage', 'Restorative Sleep', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_253', 'Awake Period Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_236', 'Core Percentage', 'Restorative Sleep', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_229', 'Core Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_252', 'Core Sleep Period Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_235', 'Deep Percentage', 'Restorative Sleep', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_240', 'Deep Sleep Cycle Count', 'Restorative Sleep', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_228', 'Deep Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_251', 'Deep Sleep Period Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_137', 'Last Alcoholic Drink Time', 'Restorative Sleep', 'chart', 'current_value', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_138', 'Last Digital Device Time Usage', 'Restorative Sleep', 'chart', 'current_value', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_136', 'Last Drink Buffer', 'Restorative Sleep', 'chart', 'trend_line', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_224', 'Period Awake Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_223', 'Period Core Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_222', 'Period Deep Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_221', 'Period REM Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_234', 'REM Percentage', 'Restorative Sleep', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_241', 'REM Sleep Cycle Count', 'Restorative Sleep', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_239', 'REM Sleep Cycle Count', 'Restorative Sleep', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_227', 'REM Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_250', 'REM Sleep Period Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_232', 'Sleep Efficiency', 'Restorative Sleep', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_220', 'Sleep Environment Score', 'Restorative Sleep', 'chart', 'trend_line', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_233', 'Sleep Latency', 'Restorative Sleep', 'chart', 'current_value', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_219', 'Sleep Routine Adherence', 'Restorative Sleep', 'chart', 'trend_line', 'percentage', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_SLEEP_SESSIONS', 'Sleep Sessions', 'Restorative Sleep', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_237', 'Sleep Time Consistency', 'Restorative Sleep', 'chart', 'gauge', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_225', 'Time In Bed Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_231', 'Total Sleep Duration', 'Restorative Sleep', 'chart', 'bar_vertical', 'hours', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_226', 'Total Sleep Window', 'Restorative Sleep', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_238', 'Wake Time Consistency', 'Restorative Sleep', 'chart', 'trend_line', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_135', 'Wearable Usage', 'Restorative Sleep', 'chart', 'current_value', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;

-- Stress Management (7 metrics)
INSERT INTO display_metrics (display_metric_id, display_name, pillar, widget_type, chart_type_id, display_unit, supported_periods, default_period, is_active)
VALUES
('DISP_DM_203', 'Breathwork AND Mindfulness Duration', 'Stress Management', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_204', 'Breathwork AND Mindfulness Sessions', 'Stress Management', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_202', 'Breathwork Duration', 'Stress Management', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_201', 'Breathwork Sessions', 'Stress Management', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_182', 'Meditation Duration', 'Stress Management', 'chart', 'bar_vertical', 'minutes', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_181', 'Meditation Sessions', 'Stress Management', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true),
('DISP_DM_183', 'Stress Management Sessions', 'Stress Management', 'chart', 'bar_vertical', 'count', ARRAY['daily', 'weekly', 'monthly'], 'weekly', true)
ON CONFLICT (display_metric_id) DO UPDATE SET
    display_name = EXCLUDED.display_name,
    pillar = EXCLUDED.pillar,
    widget_type = EXCLUDED.widget_type,
    chart_type_id = EXCLUDED.chart_type_id,
    display_unit = EXCLUDED.display_unit,
    supported_periods = EXCLUDED.supported_periods,
    default_period = EXCLUDED.default_period,
    is_active = EXCLUDED.is_active;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  dm_count INT;
BEGIN
  SELECT COUNT(*) INTO dm_count FROM display_metrics;

  RAISE NOTICE '✅ Display Metrics Created';
  RAISE NOTICE '';
  RAISE NOTICE 'Total display_metrics: %', dm_count;
  RAISE NOTICE '';
  RAISE NOTICE 'Next: Link display_metrics to aggregation_metrics via display_metrics_aggregations';
END $$;

COMMIT;
