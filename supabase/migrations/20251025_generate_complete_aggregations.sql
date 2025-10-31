-- =====================================================
-- Generate Complete Aggregations for All Reference Values
-- =====================================================
-- Auto-generated aggregations for all values in data_entry_fields_reference
-- =====================================================

BEGIN;


-- BBQ/Sweet Sauce
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_BBQ_SAUCE',
  'added_sugar_bbq_sauce',
  'BBQ/Sweet Sauce',
  'BBQ/Sweet Sauce aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_BBQ_SAUCE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_BBQ_SAUCE',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "bbq_sauce"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cake/Cupcake
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_CAKE',
  'added_sugar_cake',
  'Cake/Cupcake',
  'Cake/Cupcake aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_CAKE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_CAKE',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "cake"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Candy
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_CANDY',
  'added_sugar_candy',
  'Candy',
  'Candy aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_CANDY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_CANDY',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "candy"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cookies
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_COOKIE',
  'added_sugar_cookie',
  'Cookies',
  'Cookies aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_COOKIE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_COOKIE',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "cookie"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Energy Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_ENERGY_DRINK',
  'added_sugar_energy_drink',
  'Energy Drink',
  'Energy Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_ENERGY_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_ENERGY_DRINK',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "energy_drink"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Flavored Milk
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_FLAVORED_MILK',
  'added_sugar_flavored_milk',
  'Flavored Milk',
  'Flavored Milk aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_FLAVORED_MILK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_FLAVORED_MILK',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "flavored_milk"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Flavored/Sweetened Yogurt
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_YOGURT',
  'added_sugar_sweetened_yogurt',
  'Flavored/Sweetened Yogurt',
  'Flavored/Sweetened Yogurt aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_YOGURT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_YOGURT',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sweetened_yogurt"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Granola/Protein Bar
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_GRANOLA_BAR',
  'added_sugar_granola_bar',
  'Granola/Protein Bar',
  'Granola/Protein Bar aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_GRANOLA_BAR', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_GRANOLA_BAR',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "granola_bar"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Ice Cream/Frozen Dessert
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_ICE_CREAM',
  'added_sugar_ice_cream',
  'Ice Cream/Frozen Dessert',
  'Ice Cream/Frozen Dessert aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_ICE_CREAM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_ICE_CREAM',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "ice_cream"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Juice Cocktail/Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_JUICE_COCKTAIL',
  'added_sugar_juice_cocktail',
  'Juice Cocktail/Drink',
  'Juice Cocktail/Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_JUICE_COCKTAIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_JUICE_COCKTAIL',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "juice_cocktail"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_OTHER',
  'added_sugar_other',
  'Other',
  'Other aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_OTHER',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pancakes/Waffles with Syrup
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_PANCAKE_SYRUP',
  'added_sugar_pancake_syrup',
  'Pancakes/Waffles with Syrup',
  'Pancakes/Waffles with Syrup aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_PANCAKE_SYRUP', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_PANCAKE_SYRUP',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "pancake_syrup"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pastry/Donut
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_PASTRY',
  'added_sugar_pastry',
  'Pastry/Donut',
  'Pastry/Donut aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_PASTRY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_PASTRY',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "pastry"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Regular Soda
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SODA',
  'added_sugar_soda',
  'Regular Soda',
  'Regular Soda aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SODA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SODA',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "soda"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sports Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SPORTS_DRINK',
  'added_sugar_sports_drink',
  'Sports Drink',
  'Sports Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SPORTS_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SPORTS_DRINK',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sports_drink"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sweet Condiment
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_CONDIMENT',
  'added_sugar_sweetened_condiment',
  'Sweet Condiment',
  'Sweet Condiment aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CONDIMENT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_CONDIMENT',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sweetened_condiment"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sweetened Cereal
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_CEREAL',
  'added_sugar_sweetened_cereal',
  'Sweetened Cereal',
  'Sweetened Cereal aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEETENED_CEREAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SWEETENED_CEREAL',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sweetened_cereal"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sweetened Coffee Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_COFFEE_DRINK',
  'added_sugar_coffee_drink',
  'Sweetened Coffee Drink',
  'Sweetened Coffee Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_COFFEE_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_COFFEE_DRINK',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "coffee_drink"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sweetened Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ADDED_SUGAR_SWEET_TEA',
  'added_sugar_sweet_tea',
  'Sweetened Tea',
  'Sweetened Tea aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ADDED_SUGAR_SWEET_TEA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_ADDED_SUGAR_SWEET_TEA',
  'DEF_ADDED_SUGAR_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_ADDED_SUGAR_TYPE", "reference_value": "sweet_tea"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Beer (12 oz)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_BEER',
  'beverage_beer',
  'Beer (12 oz)',
  'Beer (12 oz) aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BEER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_BEER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_BEER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_BEER',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Black Coffee
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_COFFEE_BLACK',
  'beverage_coffee_black',
  'Black Coffee',
  'Black Coffee aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_COFFEE_BLACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_COFFEE_BLACK',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Black Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_BLACK_TEA',
  'beverage_black_tea',
  'Black Tea',
  'Black Tea aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_BLACK_TEA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_BLACK_TEA',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Espresso
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_ESPRESSO',
  'beverage_espresso',
  'Espresso',
  'Espresso aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_ESPRESSO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_ESPRESSO',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Green Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_GREEN_TEA',
  'beverage_green_tea',
  'Green Tea',
  'Green Tea aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_GREEN_TEA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_GREEN_TEA',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Herbal Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_HERBAL_TEA',
  'beverage_herbal_tea',
  'Herbal Tea',
  'Herbal Tea aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_HERBAL_TEA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_HERBAL_TEA',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Latte
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_LATTE',
  'beverage_latte',
  'Latte',
  'Latte aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_LATTE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_LATTE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_LATTE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_LATTE',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Red Wine (5 oz)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_WINE_RED',
  'beverage_wine_red',
  'Red Wine (5 oz)',
  'Red Wine (5 oz) aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WINE_RED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_WINE_RED',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sparkling Water
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_SPARKLING_WATER',
  'beverage_sparkling_water',
  'Sparkling Water',
  'Sparkling Water aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_SPARKLING_WATER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_SPARKLING_WATER',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Spirits (1.5 oz)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_SPIRITS',
  'beverage_spirits',
  'Spirits (1.5 oz)',
  'Spirits (1.5 oz) aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_SPIRITS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_SPIRITS',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Water
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_WATER',
  'beverage_water',
  'Water',
  'Water aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WATER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WATER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WATER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_WATER',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- White Wine (5 oz)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_BEVERAGE_WINE_WHITE',
  'beverage_wine_white',
  'White Wine (5 oz)',
  'White Wine (5 oz) aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_BEVERAGE_WINE_WHITE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_BEVERAGE_WINE_WHITE',
  'DEF_BEVERAGE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Black Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_TEA_BLACK',
  'caffeine_tea_black',
  'Black Tea',
  'Black Tea aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_BLACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_TEA_BLACK',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "tea_black"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Brewed Coffee
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_COFFEE_BREWED',
  'caffeine_coffee_brewed',
  'Brewed Coffee',
  'Brewed Coffee aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_BREWED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_COFFEE_BREWED',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "coffee_brewed"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Caffeinated Soda
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_SODA_CAFFEINATED',
  'caffeine_soda_caffeinated',
  'Caffeinated Soda',
  'Caffeinated Soda aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_SODA_CAFFEINATED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_SODA_CAFFEINATED',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "soda_caffeinated"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Caffeine Pill
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_CAFFEINE_PILL',
  'caffeine_caffeine_pill',
  'Caffeine Pill',
  'Caffeine Pill aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_CAFFEINE_PILL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_CAFFEINE_PILL',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "caffeine_pill"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Energy Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_ENERGY_DRINK',
  'caffeine_energy_drink',
  'Energy Drink',
  'Energy Drink aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_ENERGY_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_ENERGY_DRINK',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "energy_drink"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Espresso
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_COFFEE_ESPRESSO',
  'caffeine_coffee_espresso',
  'Espresso',
  'Espresso aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_ESPRESSO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_COFFEE_ESPRESSO',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "coffee_espresso"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Green Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_TEA_GREEN',
  'caffeine_tea_green',
  'Green Tea',
  'Green Tea aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_GREEN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_TEA_GREEN',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "tea_green"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Instant Coffee
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_COFFEE_INSTANT',
  'caffeine_coffee_instant',
  'Instant Coffee',
  'Instant Coffee aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_COFFEE_INSTANT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_COFFEE_INSTANT',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "coffee_instant"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Matcha
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_MATCHA',
  'caffeine_matcha',
  'Matcha',
  'Matcha aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_MATCHA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_MATCHA',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "matcha"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Oolong Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_TEA_OOLONG',
  'caffeine_tea_oolong',
  'Oolong Tea',
  'Oolong Tea aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_OOLONG', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_TEA_OOLONG',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "tea_oolong"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pre-Workout Supplement
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_PRE_WORKOUT',
  'caffeine_pre_workout',
  'Pre-Workout Supplement',
  'Pre-Workout Supplement aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_PRE_WORKOUT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_PRE_WORKOUT',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "pre_workout"}'::jsonb
) ON CONFLICT DO NOTHING;


-- White Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CAFFEINE_TEA_WHITE',
  'caffeine_tea_white',
  'White Tea',
  'White Tea aggregation',
  'milligram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CAFFEINE_TEA_WHITE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CAFFEINE_TEA_WHITE',
  'DEF_CAFFEINE_QUANTITY',
  'data_field',
  '{"reference_field": "DEF_CAFFEINE_TYPE", "reference_value": "tea_white"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Active Play
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_PLAY',
  'cardio_play',
  'Active Play',
  'Active Play aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PLAY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PLAY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PLAY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_PLAY',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "play"}'::jsonb
) ON CONFLICT DO NOTHING;


-- American Football
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_AMERICAN_FOOTBALL',
  'cardio_american_football',
  'American Football',
  'American Football aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_AMERICAN_FOOTBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_AMERICAN_FOOTBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "american_football"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Archery
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_ARCHERY',
  'cardio_archery',
  'Archery',
  'Archery aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ARCHERY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ARCHERY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ARCHERY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_ARCHERY',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "archery"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Australian Football
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_AUSTRALIAN_FOOTBALL',
  'cardio_australian_football',
  'Australian Football',
  'Australian Football aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_AUSTRALIAN_FOOTBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_AUSTRALIAN_FOOTBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "australian_football"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Badminton
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_BADMINTON',
  'cardio_badminton',
  'Badminton',
  'Badminton aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BADMINTON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BADMINTON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BADMINTON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_BADMINTON',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "badminton"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Baseball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_BASEBALL',
  'cardio_baseball',
  'Baseball',
  'Baseball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASEBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BASEBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BASEBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_BASEBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "baseball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Basketball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_BASKETBALL',
  'cardio_basketball',
  'Basketball',
  'Basketball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BASKETBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_BASKETBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "basketball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Bowling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_BOWLING',
  'cardio_bowling',
  'Bowling',
  'Bowling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOWLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BOWLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BOWLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_BOWLING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "bowling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Boxing (Cardio)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_BOXING_CARDIO',
  'cardio_boxing_cardio',
  'Boxing (Cardio)',
  'Boxing (Cardio) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_BOXING_CARDIO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_BOXING_CARDIO',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "boxing_cardio"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Climbing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_CLIMBING',
  'cardio_climbing',
  'Climbing',
  'Climbing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CLIMBING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CLIMBING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CLIMBING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_CLIMBING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "climbing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cricket
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_CRICKET',
  'cardio_cricket',
  'Cricket',
  'Cricket aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CRICKET', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CRICKET', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CRICKET', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_CRICKET',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "cricket"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cross Country Skiing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_CROSS_COUNTRY_SKIING',
  'cardio_cross_country_skiing',
  'Cross Country Skiing',
  'Cross Country Skiing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CROSS_COUNTRY_SKIING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_CROSS_COUNTRY_SKIING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "cross_country_skiing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Curling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_CURLING',
  'cardio_curling',
  'Curling',
  'Curling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CURLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CURLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CURLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_CURLING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "curling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cycling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_CYCLING',
  'cardio_cycling',
  'Cycling',
  'Cycling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_CYCLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CYCLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_CYCLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_CYCLING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "cycling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Dancing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_DANCING',
  'cardio_dancing',
  'Dancing',
  'Dancing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DANCING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DANCING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DANCING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_DANCING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "dancing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Disc Sports
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_DISC_SPORTS',
  'cardio_disc_sports',
  'Disc Sports',
  'Disc Sports aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DISC_SPORTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_DISC_SPORTS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "disc_sports"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Downhill Skiing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_DOWNHILL_SKIING',
  'cardio_downhill_skiing',
  'Downhill Skiing',
  'Downhill Skiing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_DOWNHILL_SKIING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_DOWNHILL_SKIING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "downhill_skiing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Elliptical
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_ELLIPTICAL',
  'cardio_elliptical',
  'Elliptical',
  'Elliptical aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ELLIPTICAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_ELLIPTICAL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "elliptical"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Equestrian
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_EQUESTRIAN',
  'cardio_equestrian',
  'Equestrian',
  'Equestrian aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_EQUESTRIAN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_EQUESTRIAN',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "equestrian"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fencing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_FENCING',
  'cardio_fencing',
  'Fencing',
  'Fencing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FENCING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FENCING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FENCING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_FENCING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "fencing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fishing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_FISHING',
  'cardio_fishing',
  'Fishing',
  'Fishing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FISHING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FISHING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FISHING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_FISHING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "fishing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fitness Gaming
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_FITNESS_GAMING',
  'cardio_fitness_gaming',
  'Fitness Gaming',
  'Fitness Gaming aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_FITNESS_GAMING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_FITNESS_GAMING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "fitness_gaming"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Golf
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_GOLF',
  'cardio_golf',
  'Golf',
  'Golf aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GOLF', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_GOLF', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_GOLF', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_GOLF',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "golf"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Gymnastics
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_GYMNASTICS',
  'cardio_gymnastics',
  'Gymnastics',
  'Gymnastics aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_GYMNASTICS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_GYMNASTICS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "gymnastics"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Hand Cycling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HAND_CYCLING',
  'cardio_hand_cycling',
  'Hand Cycling',
  'Hand Cycling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HAND_CYCLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HAND_CYCLING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "hand_cycling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Handball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HANDBALL',
  'cardio_handball',
  'Handball',
  'Handball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HANDBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HANDBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HANDBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HANDBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "handball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HIIT',
  'cardio_hiit',
  'HIIT',
  'HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HIIT',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Hiking
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HIKING',
  'cardio_hiking',
  'Hiking',
  'Hiking aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HIKING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HIKING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HIKING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HIKING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "hiking"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Hockey
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HOCKEY',
  'cardio_hockey',
  'Hockey',
  'Hockey aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HOCKEY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HOCKEY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HOCKEY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HOCKEY',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "hockey"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Hunting
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_HUNTING',
  'cardio_hunting',
  'Hunting',
  'Hunting aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_HUNTING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HUNTING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_HUNTING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_HUNTING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "hunting"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Jump Rope
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_JUMP_ROPE',
  'cardio_jump_rope',
  'Jump Rope',
  'Jump Rope aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_JUMP_ROPE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_JUMP_ROPE',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "jump_rope"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Kickboxing (Cardio)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_KICKBOXING_CARDIO',
  'cardio_kickboxing_cardio',
  'Kickboxing (Cardio)',
  'Kickboxing (Cardio) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_KICKBOXING_CARDIO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_KICKBOXING_CARDIO',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "kickboxing_cardio"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lacrosse
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_LACROSSE',
  'cardio_lacrosse',
  'Lacrosse',
  'Lacrosse aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_LACROSSE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_LACROSSE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_LACROSSE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_LACROSSE',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "lacrosse"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Martial Arts (Cardio)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_MARTIAL_ARTS_CARDIO',
  'cardio_martial_arts_cardio',
  'Martial Arts (Cardio)',
  'Martial Arts (Cardio) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_MARTIAL_ARTS_CARDIO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_MARTIAL_ARTS_CARDIO',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "martial_arts_cardio"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Mixed Cardio
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_MIXED_CARDIO',
  'cardio_mixed_cardio',
  'Mixed Cardio',
  'Mixed Cardio aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_MIXED_CARDIO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_MIXED_CARDIO',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "mixed_cardio"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_OTHER',
  'cardio_other',
  'Other',
  'Other aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_OTHER',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Paddle Sports
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_PADDLE_SPORTS',
  'cardio_paddle_sports',
  'Paddle Sports',
  'Paddle Sports aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PADDLE_SPORTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_PADDLE_SPORTS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "paddle_sports"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pickleball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_PICKLEBALL',
  'cardio_pickleball',
  'Pickleball',
  'Pickleball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_PICKLEBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_PICKLEBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "pickleball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Racquetball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_RACQUETBALL',
  'cardio_racquetball',
  'Racquetball',
  'Racquetball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RACQUETBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_RACQUETBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "racquetball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Rowing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_ROWING',
  'cardio_rowing',
  'Rowing',
  'Rowing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_ROWING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ROWING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_ROWING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_ROWING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "rowing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Rugby
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_RUGBY',
  'cardio_rugby',
  'Rugby',
  'Rugby aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUGBY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RUGBY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RUGBY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_RUGBY',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "rugby"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Running
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_RUNNING',
  'cardio_running',
  'Running',
  'Running aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_RUNNING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RUNNING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_RUNNING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_RUNNING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "running"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sailing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SAILING',
  'cardio_sailing',
  'Sailing',
  'Sailing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SAILING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SAILING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SAILING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SAILING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "sailing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Skating
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SKATING',
  'cardio_skating',
  'Skating',
  'Skating aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SKATING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SKATING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SKATING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SKATING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "skating"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Snow Sports
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SNOW_SPORTS',
  'cardio_snow_sports',
  'Snow Sports',
  'Snow Sports aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SNOW_SPORTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SNOW_SPORTS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "snow_sports"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Snowboarding
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SNOWBOARDING',
  'cardio_snowboarding',
  'Snowboarding',
  'Snowboarding aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SNOWBOARDING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SNOWBOARDING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "snowboarding"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Soccer
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SOCCER',
  'cardio_soccer',
  'Soccer',
  'Soccer aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCCER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOCCER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOCCER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SOCCER',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "soccer"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Social Dance
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SOCIAL_DANCE',
  'cardio_social_dance',
  'Social Dance',
  'Social Dance aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOCIAL_DANCE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SOCIAL_DANCE',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "social_dance"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Softball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SOFTBALL',
  'cardio_softball',
  'Softball',
  'Softball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SOFTBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SOFTBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "softball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Squash
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SQUASH',
  'cardio_squash',
  'Squash',
  'Squash aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SQUASH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SQUASH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SQUASH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SQUASH',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "squash"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Stair Climbing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_STAIR_CLIMBING',
  'cardio_stair_climbing',
  'Stair Climbing',
  'Stair Climbing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STAIR_CLIMBING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_STAIR_CLIMBING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "stair_climbing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Stair Climbing (Outdoor)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_STAIRS_OUTDOOR',
  'cardio_stairs_outdoor',
  'Stair Climbing (Outdoor)',
  'Stair Climbing (Outdoor) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STAIRS_OUTDOOR', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_STAIRS_OUTDOOR',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "stairs_outdoor"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Step Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_STEP_TRAINING',
  'cardio_step_training',
  'Step Training',
  'Step Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_STEP_TRAINING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_STEP_TRAINING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "step_training"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Surfing
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SURFING',
  'cardio_surfing',
  'Surfing',
  'Surfing aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SURFING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SURFING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SURFING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SURFING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "surfing"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Swimming
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_SWIMMING',
  'cardio_swimming',
  'Swimming',
  'Swimming aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_SWIMMING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SWIMMING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_SWIMMING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_SWIMMING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "swimming"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Table Tennis
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_TABLE_TENNIS',
  'cardio_table_tennis',
  'Table Tennis',
  'Table Tennis aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TABLE_TENNIS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_TABLE_TENNIS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "table_tennis"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Tennis
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_TENNIS',
  'cardio_tennis',
  'Tennis',
  'Tennis aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TENNIS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TENNIS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TENNIS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_TENNIS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "tennis"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Track & Field
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_TRACK_FIELD',
  'cardio_track_field',
  'Track & Field',
  'Track & Field aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRACK_FIELD', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_TRACK_FIELD',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "track_field"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Transition
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_TRANSITION',
  'cardio_transition',
  'Transition',
  'Transition aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRANSITION', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRANSITION', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRANSITION', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_TRANSITION',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "transition"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Triathlon (Swim-Bike-Run)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_TRIATHLON',
  'cardio_triathlon',
  'Triathlon (Swim-Bike-Run)',
  'Triathlon (Swim-Bike-Run) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_TRIATHLON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_TRIATHLON',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "triathlon"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Unassigned
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_UNASSIGNED',
  'cardio_unassigned',
  'Unassigned',
  'Unassigned aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_UNASSIGNED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_UNASSIGNED',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Underwater Diving
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_UNDERWATER_DIVING',
  'cardio_underwater_diving',
  'Underwater Diving',
  'Underwater Diving aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_UNDERWATER_DIVING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_UNDERWATER_DIVING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "underwater_diving"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Volleyball
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_VOLLEYBALL',
  'cardio_volleyball',
  'Volleyball',
  'Volleyball aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_VOLLEYBALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_VOLLEYBALL',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "volleyball"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Walking
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WALKING',
  'cardio_walking',
  'Walking',
  'Walking aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WALKING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WALKING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WALKING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WALKING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "walking"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Water Fitness
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WATER_FITNESS',
  'cardio_water_fitness',
  'Water Fitness',
  'Water Fitness aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_FITNESS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WATER_FITNESS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "water_fitness"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Water Polo
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WATER_POLO',
  'cardio_water_polo',
  'Water Polo',
  'Water Polo aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_POLO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WATER_POLO',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "water_polo"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Water Sports
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WATER_SPORTS',
  'cardio_water_sports',
  'Water Sports',
  'Water Sports aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WATER_SPORTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WATER_SPORTS',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "water_sports"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Wheelchair Running
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WHEELCHAIR_RUN',
  'cardio_wheelchair_run',
  'Wheelchair Running',
  'Wheelchair Running aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_RUN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WHEELCHAIR_RUN',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "wheelchair_run"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Wheelchair Walking
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WHEELCHAIR_WALK',
  'cardio_wheelchair_walk',
  'Wheelchair Walking',
  'Wheelchair Walking aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WHEELCHAIR_WALK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WHEELCHAIR_WALK',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "wheelchair_walk"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Wrestling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_CARDIO_WRESTLING',
  'cardio_wrestling',
  'Wrestling',
  'Wrestling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_CARDIO_WRESTLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WRESTLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_CARDIO_WRESTLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_CARDIO_WRESTLING',
  'DEF_CARDIO_DURATION',
  'data_field',
  '{"reference_field": "DEF_CARDIO_TYPE", "reference_value": "wrestling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Almonds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_NUTS_ALMONDS',
  'fat_nuts_almonds',
  'Almonds',
  'Almonds aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_NUTS_ALMONDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_NUTS_ALMONDS',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "nuts_almonds"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Avocado
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_AVOCADO',
  'fat_avocado',
  'Avocado',
  'Avocado aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_AVOCADO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_AVOCADO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_AVOCADO',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "avocado"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Avocado Oil
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_AVOCADO_OIL',
  'fat_avocado_oil',
  'Avocado Oil',
  'Avocado Oil aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_AVOCADO_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_AVOCADO_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "avocado_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Butter
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_BUTTER',
  'fat_butter',
  'Butter',
  'Butter aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_BUTTER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_BUTTER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_BUTTER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_BUTTER',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "butter"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Chia Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_CHIA_SEEDS',
  'fat_chia_seeds',
  'Chia Seeds',
  'Chia Seeds aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_CHIA_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_CHIA_SEEDS',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "chia_seeds"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Coconut Oil
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_COCONUT_OIL',
  'fat_coconut_oil',
  'Coconut Oil',
  'Coconut Oil aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_COCONUT_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_COCONUT_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "coconut_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fatty Fish (Omega-3)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_FATTY_FISH_OIL',
  'fat_fatty_fish_oil',
  'Fatty Fish (Omega-3)',
  'Fatty Fish (Omega-3) aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_FATTY_FISH_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_FATTY_FISH_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "fatty_fish_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Flax Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_FLAX_SEEDS',
  'fat_flax_seeds',
  'Flax Seeds',
  'Flax Seeds aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_FLAX_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_FLAX_SEEDS',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "flax_seeds"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lard
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_LARD',
  'fat_lard',
  'Lard',
  'Lard aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_LARD', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_LARD', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_LARD', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_LARD',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "lard"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Olive Oil
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_OLIVE_OIL',
  'fat_olive_oil',
  'Olive Oil',
  'Olive Oil aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_OLIVE_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_OLIVE_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "olive_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Palm Oil
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_PALM_OIL',
  'fat_palm_oil',
  'Palm Oil',
  'Palm Oil aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_PALM_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_PALM_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_PALM_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_PALM_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "palm_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Vegetable Oil
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_VEGETABLE_OIL',
  'fat_vegetable_oil',
  'Vegetable Oil',
  'Vegetable Oil aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_VEGETABLE_OIL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_VEGETABLE_OIL',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "vegetable_oil"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Walnuts
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FAT_NUTS_WALNUTS',
  'fat_nuts_walnuts',
  'Walnuts',
  'Walnuts aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FAT_NUTS_WALNUTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FAT_NUTS_WALNUTS',
  'DEF_FAT_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FAT_TYPE", "reference_value": "nuts_walnuts"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fiber Supplements
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_SUPPLEMENTS',
  'fiber_supplements',
  'Fiber Supplements',
  'Fiber Supplements aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_SUPPLEMENTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_SUPPLEMENTS',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "supplements"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fruits
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_FRUITS',
  'fiber_fruits',
  'Fruits',
  'Fruits aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_FRUITS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_FRUITS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_FRUITS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_FRUITS',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "fruits"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Legumes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_LEGUMES',
  'fiber_legumes',
  'Legumes',
  'Legumes aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_LEGUMES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_LEGUMES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_LEGUMES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_LEGUMES',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "legumes"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Nuts & Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_NUTS_SEEDS',
  'fiber_nuts_seeds',
  'Nuts & Seeds',
  'Nuts & Seeds aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_NUTS_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_NUTS_SEEDS',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "nuts_seeds"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Vegetables
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_VEGETABLES',
  'fiber_vegetables',
  'Vegetables',
  'Vegetables aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_VEGETABLES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_VEGETABLES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_VEGETABLES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_VEGETABLES',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "vegetables"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Whole Grains
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FIBER_WHOLE_GRAINS',
  'fiber_whole_grains',
  'Whole Grains',
  'Whole Grains aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FIBER_WHOLE_GRAINS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_FIBER_WHOLE_GRAINS',
  'DEF_FIBER_GRAMS',
  'data_field',
  '{"reference_field": "DEF_FIBER_TYPE", "reference_value": "whole_grains"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Alliums
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_ALLIUMS',
  'food_alliums',
  'Alliums',
  'Alliums aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALLIUMS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ALLIUMS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ALLIUMS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_ALLIUMS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Almonds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_ALMONDS',
  'food_almonds',
  'Almonds',
  'Almonds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ALMONDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ALMONDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ALMONDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_ALMONDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Apples & Pears
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_APPLES_PEARS',
  'food_apples_pears',
  'Apples & Pears',
  'Apples & Pears aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_APPLES_PEARS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_APPLES_PEARS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Barley
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BARLEY',
  'food_barley',
  'Barley',
  'Barley aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BARLEY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BARLEY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BARLEY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BARLEY',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Berries
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BERRIES',
  'food_berries',
  'Berries',
  'Berries aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BERRIES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BERRIES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BERRIES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BERRIES',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Black Beans
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BLACK_BEANS',
  'food_black_beans',
  'Black Beans',
  'Black Beans aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BLACK_BEANS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BLACK_BEANS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Black-Eyed Peas
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BLACK_EYED_PEAS',
  'food_black_eyed_peas',
  'Black-Eyed Peas',
  'Black-Eyed Peas aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BLACK_EYED_PEAS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BLACK_EYED_PEAS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Brazil Nuts
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BRAZIL_NUTS',
  'food_brazil_nuts',
  'Brazil Nuts',
  'Brazil Nuts aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BRAZIL_NUTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BRAZIL_NUTS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Broccoli
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BROCCOLI',
  'food_broccoli',
  'Broccoli',
  'Broccoli aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROCCOLI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BROCCOLI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BROCCOLI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BROCCOLI',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Brown Rice
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BROWN_RICE',
  'food_brown_rice',
  'Brown Rice',
  'Brown Rice aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BROWN_RICE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BROWN_RICE',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Buckwheat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_BUCKWHEAT',
  'food_buckwheat',
  'Buckwheat',
  'Buckwheat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_BUCKWHEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_BUCKWHEAT',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Carrots
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CARROTS',
  'food_carrots',
  'Carrots',
  'Carrots aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CARROTS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CARROTS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CARROTS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CARROTS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cashews
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CASHEWS',
  'food_cashews',
  'Cashews',
  'Cashews aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CASHEWS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CASHEWS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CASHEWS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CASHEWS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chia Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CHIA_SEEDS',
  'food_chia_seeds',
  'Chia Seeds',
  'Chia Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CHIA_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CHIA_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chickpeas
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CHICKPEAS',
  'food_chickpeas',
  'Chickpeas',
  'Chickpeas aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CHICKPEAS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CHICKPEAS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Citrus Fruits
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CITRUS',
  'food_citrus',
  'Citrus Fruits',
  'Citrus Fruits aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CITRUS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CITRUS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CITRUS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CITRUS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Colorful Peppers
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_COLORFUL_PEPPERS',
  'food_colorful_peppers',
  'Colorful Peppers',
  'Colorful Peppers aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_COLORFUL_PEPPERS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_COLORFUL_PEPPERS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cruciferous Vegetables
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_CRUCIFEROUS',
  'food_cruciferous',
  'Cruciferous Vegetables',
  'Cruciferous Vegetables aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_CRUCIFEROUS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_CRUCIFEROUS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Dried Fruits
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_DRIED_FRUITS',
  'food_dried_fruits',
  'Dried Fruits',
  'Dried Fruits aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_DRIED_FRUITS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_DRIED_FRUITS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Edamame
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_EDAMAME',
  'food_edamame',
  'Edamame',
  'Edamame aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_EDAMAME', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_EDAMAME', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_EDAMAME', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_EDAMAME',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Farro
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_FARRO',
  'food_farro',
  'Farro',
  'Farro aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FARRO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_FARRO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_FARRO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_FARRO',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Flax Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_FLAX_SEEDS',
  'food_flax_seeds',
  'Flax Seeds',
  'Flax Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_FLAX_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_FLAX_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Grapes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_GRAPES',
  'food_grapes',
  'Grapes',
  'Grapes aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GRAPES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_GRAPES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_GRAPES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_GRAPES',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Green Peas
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_GREEN_PEAS',
  'food_green_peas',
  'Green Peas',
  'Green Peas aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_GREEN_PEAS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_GREEN_PEAS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Hemp Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_HEMP_SEEDS',
  'food_hemp_seeds',
  'Hemp Seeds',
  'Hemp Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_HEMP_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_HEMP_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Kidney Beans
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_KIDNEY_BEANS',
  'food_kidney_beans',
  'Kidney Beans',
  'Kidney Beans aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_KIDNEY_BEANS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_KIDNEY_BEANS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Leafy Greens
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_LEAFY_GREENS',
  'food_leafy_greens',
  'Leafy Greens',
  'Leafy Greens aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_LEAFY_GREENS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_LEAFY_GREENS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Lentils
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_LENTILS',
  'food_lentils',
  'Lentils',
  'Lentils aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_LENTILS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_LENTILS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_LENTILS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_LENTILS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Macadamia Nuts
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_MACADAMIA',
  'food_macadamia',
  'Macadamia Nuts',
  'Macadamia Nuts aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MACADAMIA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MACADAMIA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MACADAMIA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_MACADAMIA',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Melons
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_MELONS',
  'food_melons',
  'Melons',
  'Melons aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MELONS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MELONS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MELONS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_MELONS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Millet
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_MILLET',
  'food_millet',
  'Millet',
  'Millet aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MILLET', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MILLET', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MILLET', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_MILLET',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Mushrooms
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_MUSHROOMS',
  'food_mushrooms',
  'Mushrooms',
  'Mushrooms aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_MUSHROOMS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_MUSHROOMS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Navy Beans
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_NAVY_BEANS',
  'food_navy_beans',
  'Navy Beans',
  'Navy Beans aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_NAVY_BEANS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_NAVY_BEANS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Oats
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_OATS',
  'food_oats',
  'Oats',
  'Oats aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_OATS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_OATS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_OATS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_OATS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pecans
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_PECANS',
  'food_pecans',
  'Pecans',
  'Pecans aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PECANS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PECANS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PECANS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_PECANS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pinto Beans
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_PINTO_BEANS',
  'food_pinto_beans',
  'Pinto Beans',
  'Pinto Beans aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PINTO_BEANS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_PINTO_BEANS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pistachios
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_PISTACHIOS',
  'food_pistachios',
  'Pistachios',
  'Pistachios aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PISTACHIOS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_PISTACHIOS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pumpkin Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_PUMPKIN_SEEDS',
  'food_pumpkin_seeds',
  'Pumpkin Seeds',
  'Pumpkin Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_PUMPKIN_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_PUMPKIN_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Quinoa
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_QUINOA',
  'food_quinoa',
  'Quinoa',
  'Quinoa aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_QUINOA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_QUINOA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_QUINOA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_QUINOA',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Root Vegetables
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_ROOT_VEGETABLES',
  'food_root_vegetables',
  'Root Vegetables',
  'Root Vegetables aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_ROOT_VEGETABLES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_ROOT_VEGETABLES',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sesame Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_SESAME_SEEDS',
  'food_sesame_seeds',
  'Sesame Seeds',
  'Sesame Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SESAME_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_SESAME_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Spinach
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_SPINACH',
  'food_spinach',
  'Spinach',
  'Spinach aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPINACH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SPINACH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SPINACH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_SPINACH',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Split Peas
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_SPLIT_PEAS',
  'food_split_peas',
  'Split Peas',
  'Split Peas aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SPLIT_PEAS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_SPLIT_PEAS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Squash & Zucchini
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_SQUASH_ZUCCHINI',
  'food_squash_zucchini',
  'Squash & Zucchini',
  'Squash & Zucchini aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SQUASH_ZUCCHINI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_SQUASH_ZUCCHINI',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Starchy Vegetables
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_STARCHY_VEGETABLES',
  'food_starchy_vegetables',
  'Starchy Vegetables',
  'Starchy Vegetables aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_STARCHY_VEGETABLES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_STARCHY_VEGETABLES',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Stone Fruits
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_STONE_FRUITS',
  'food_stone_fruits',
  'Stone Fruits',
  'Stone Fruits aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_STONE_FRUITS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_STONE_FRUITS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sunflower Seeds
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_SUNFLOWER_SEEDS',
  'food_sunflower_seeds',
  'Sunflower Seeds',
  'Sunflower Seeds aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_SUNFLOWER_SEEDS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_SUNFLOWER_SEEDS',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Tomatoes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_TOMATOES',
  'food_tomatoes',
  'Tomatoes',
  'Tomatoes aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TOMATOES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_TOMATOES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_TOMATOES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_TOMATOES',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Tropical Fruits
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_TROPICAL',
  'food_tropical',
  'Tropical Fruits',
  'Tropical Fruits aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_TROPICAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_TROPICAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_TROPICAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_TROPICAL',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Whole Grain Bread
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_WHOLE_GRAIN_BREAD',
  'food_whole_grain_bread',
  'Whole Grain Bread',
  'Whole Grain Bread aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_WHOLE_GRAIN_BREAD', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_WHOLE_GRAIN_BREAD',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Whole Wheat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_FOOD_WHOLE_WHEAT',
  'food_whole_wheat',
  'Whole Wheat',
  'Whole Wheat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_FOOD_WHOLE_WHEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_FOOD_WHOLE_WHEAT',
  'DEF_FOOD_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- AMRAP (As Many Rounds As Possible)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_AMRAP',
  'hiit_amrap',
  'AMRAP (As Many Rounds As Possible)',
  'AMRAP (As Many Rounds As Possible) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_AMRAP', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_AMRAP', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_AMRAP', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_AMRAP',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "amrap"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Battle Ropes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_BATTLE_ROPES',
  'hiit_battle_ropes',
  'Battle Ropes',
  'Battle Ropes aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BATTLE_ROPES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_BATTLE_ROPES',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "battle_ropes"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Bodyweight HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_BODYWEIGHT_HIIT',
  'hiit_bodyweight_hiit',
  'Bodyweight HIIT',
  'Bodyweight HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BODYWEIGHT_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_BODYWEIGHT_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "bodyweight_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Boxing HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_BOXING_HIIT',
  'hiit_boxing_hiit',
  'Boxing HIIT',
  'Boxing HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BOXING_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_BOXING_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "boxing_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Boxing Intervals
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_BOXING_INTERVALS',
  'hiit_boxing_intervals',
  'Boxing Intervals',
  'Boxing Intervals aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BOXING_INTERVALS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_BOXING_INTERVALS',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "boxing_intervals"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Burpee Challenge
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_BURPEE_CHALLENGE',
  'hiit_burpee_challenge',
  'Burpee Challenge',
  'Burpee Challenge aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_BURPEE_CHALLENGE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_BURPEE_CHALLENGE',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "burpee_challenge"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Circuit Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_CIRCUIT_TRAINING',
  'hiit_circuit_training',
  'Circuit Training',
  'Circuit Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_CIRCUIT_TRAINING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_CIRCUIT_TRAINING',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "circuit_training"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Custom HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_CUSTOM_HIIT',
  'hiit_custom_hiit',
  'Custom HIIT',
  'Custom HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_CUSTOM_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_CUSTOM_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "custom_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- EMOM (Every Minute On the Minute)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_EMOM',
  'hiit_emom',
  'EMOM (Every Minute On the Minute)',
  'EMOM (Every Minute On the Minute) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_EMOM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_EMOM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_EMOM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_EMOM',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "emom"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fartlek Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_FARTLEK',
  'hiit_fartlek',
  'Fartlek Training',
  'Fartlek Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_FARTLEK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_FARTLEK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_FARTLEK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_FARTLEK',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "fartlek"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Jump Rope Intervals
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_JUMP_ROPE_INTERVALS',
  'hiit_jump_rope_intervals',
  'Jump Rope Intervals',
  'Jump Rope Intervals aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_JUMP_ROPE_INTERVALS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_JUMP_ROPE_INTERVALS',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "jump_rope_intervals"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Kettlebell HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_KETTLEBELL_HIIT',
  'hiit_kettlebell_hiit',
  'Kettlebell HIIT',
  'Kettlebell HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_KETTLEBELL_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_KETTLEBELL_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "kettlebell_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Kickboxing HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_KICKBOXING_HIIT',
  'hiit_kickboxing_hiit',
  'Kickboxing HIIT',
  'Kickboxing HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_KICKBOXING_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_KICKBOXING_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "kickboxing_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Martial Arts HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_MARTIAL_ARTS_HIIT',
  'hiit_martial_arts_hiit',
  'Martial Arts HIIT',
  'Martial Arts HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_MARTIAL_ARTS_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_MARTIAL_ARTS_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "martial_arts_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_OTHER',
  'hiit_other',
  'Other HIIT',
  'Other HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_OTHER',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pyramid Intervals
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_PYRAMID',
  'hiit_pyramid',
  'Pyramid Intervals',
  'Pyramid Intervals aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_PYRAMID', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_PYRAMID', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_PYRAMID', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_PYRAMID',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "pyramid"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Spin/Cycling HIIT
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_SPIN_HIIT',
  'hiit_spin_hiit',
  'Spin/Cycling HIIT',
  'Spin/Cycling HIIT aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_SPIN_HIIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_SPIN_HIIT',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "spin_hiit"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Sprint Intervals
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_SPRINT_INTERVALS',
  'hiit_sprint_intervals',
  'Sprint Intervals',
  'Sprint Intervals aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_SPRINT_INTERVALS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_SPRINT_INTERVALS',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "sprint_intervals"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Tabata
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_TABATA',
  'hiit_tabata',
  'Tabata',
  'Tabata aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_TABATA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_TABATA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_TABATA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_TABATA',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "tabata"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Unassigned
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_HIIT_UNASSIGNED',
  'hiit_unassigned',
  'Unassigned',
  'Unassigned aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_HIIT_UNASSIGNED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_HIIT_UNASSIGNED',
  'DEF_HIIT_DURATION',
  'data_field',
  '{"reference_field": "DEF_HIIT_TYPE", "reference_value": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Active Isolated Stretching
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_ACTIVE_ISOLATED',
  'mobility_active_isolated',
  'Active Isolated Stretching',
  'Active Isolated Stretching aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_ACTIVE_ISOLATED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_ACTIVE_ISOLATED',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "active_isolated"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Dynamic Stretching
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_DYNAMIC_STRETCHING',
  'mobility_dynamic_stretching',
  'Dynamic Stretching',
  'Dynamic Stretching aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_DYNAMIC_STRETCHING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_DYNAMIC_STRETCHING',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "dynamic_stretching"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Foam Rolling
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_FOAM_ROLLING',
  'mobility_foam_rolling',
  'Foam Rolling',
  'Foam Rolling aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_FOAM_ROLLING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_FOAM_ROLLING',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "foam_rolling"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Mobility Drills
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_MOBILITY_DRILLS',
  'mobility_mobility_drills',
  'Mobility Drills',
  'Mobility Drills aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_MOBILITY_DRILLS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_MOBILITY_DRILLS',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "mobility_drills"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_OTHER',
  'mobility_other',
  'Other',
  'Other aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_OTHER',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Pilates
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_PILATES',
  'mobility_pilates',
  'Pilates',
  'Pilates aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PILATES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_PILATES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_PILATES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_PILATES',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "pilates"}'::jsonb
) ON CONFLICT DO NOTHING;


-- PNF Stretching
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_PNF_STRETCHING',
  'mobility_pnf_stretching',
  'PNF Stretching',
  'PNF Stretching aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_PNF_STRETCHING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_PNF_STRETCHING',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "pnf_stretching"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Resistance Band Stretching
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_RESISTANCE_BAND',
  'mobility_resistance_band',
  'Resistance Band Stretching',
  'Resistance Band Stretching aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_RESISTANCE_BAND', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_RESISTANCE_BAND',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "resistance_band"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Static Stretching
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_STATIC_STRETCHING',
  'mobility_static_stretching',
  'Static Stretching',
  'Static Stretching aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_STATIC_STRETCHING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_STATIC_STRETCHING',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "static_stretching"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Tai Chi
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_TAI_CHI',
  'mobility_tai_chi',
  'Tai Chi',
  'Tai Chi aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_TAI_CHI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_TAI_CHI',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "tai_chi"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Unassigned
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_UNASSIGNED',
  'mobility_unassigned',
  'Unassigned',
  'Unassigned aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_UNASSIGNED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_UNASSIGNED',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Yoga
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MOBILITY_YOGA',
  'mobility_yoga',
  'Yoga',
  'Yoga aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MOBILITY_YOGA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_YOGA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MOBILITY_YOGA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_MOBILITY_YOGA',
  'DEF_MOBILITY_DURATION',
  'data_field',
  '{"reference_field": "DEF_MOBILITY_TYPE", "reference_value": "yoga"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Abs
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_ABS',
  'muscle_groups_abs',
  'Abs',
  'Abs aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_ABS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_ABS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Back
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_BACK',
  'muscle_groups_back',
  'Back',
  'Back aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_BACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_BACK',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Biceps
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_BICEPS',
  'muscle_groups_biceps',
  'Biceps',
  'Biceps aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_BICEPS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_BICEPS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Calves
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_CALVES',
  'muscle_groups_calves',
  'Calves',
  'Calves aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CALVES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_CALVES',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chest
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_CHEST',
  'muscle_groups_chest',
  'Chest',
  'Chest aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CHEST', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_CHEST',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Core (General)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_CORE',
  'muscle_groups_core',
  'Core (General)',
  'Core (General) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_CORE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_CORE',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Forearms
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_FOREARMS',
  'muscle_groups_forearms',
  'Forearms',
  'Forearms aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_FOREARMS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_FOREARMS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Full Body
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_FULL_BODY',
  'muscle_groups_full_body',
  'Full Body',
  'Full Body aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_FULL_BODY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_FULL_BODY',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Glutes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_GLUTES',
  'muscle_groups_glutes',
  'Glutes',
  'Glutes aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_GLUTES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_GLUTES',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Hamstrings
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_HAMSTRINGS',
  'muscle_groups_hamstrings',
  'Hamstrings',
  'Hamstrings aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_HAMSTRINGS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_HAMSTRINGS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Lower Back
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_LOWER_BACK',
  'muscle_groups_lower_back',
  'Lower Back',
  'Lower Back aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_LOWER_BACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_LOWER_BACK',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Quadriceps
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_QUADS',
  'muscle_groups_quads',
  'Quadriceps',
  'Quadriceps aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_QUADS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_QUADS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Shoulders
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_SHOULDERS',
  'muscle_groups_shoulders',
  'Shoulders',
  'Shoulders aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_SHOULDERS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_SHOULDERS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Triceps
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_MUSCLE_GROUPS_TRICEPS',
  'muscle_groups_triceps',
  'Triceps',
  'Triceps aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_MUSCLE_GROUPS_TRICEPS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_MUSCLE_GROUPS_TRICEPS',
  'DEF_STRENGTH_MUSCLE_GROUPS',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Bacon
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_BACON',
  'processed_meat_bacon',
  'Bacon',
  'Bacon aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_BACON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_BACON',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Canned Meat Product
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_SPAM',
  'processed_meat_spam',
  'Canned Meat Product',
  'Canned Meat Product aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SPAM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_SPAM',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chorizo
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_CHORIZO',
  'processed_meat_chorizo',
  'Chorizo',
  'Chorizo aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_CHORIZO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_CHORIZO',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Deli/Lunch Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_DELI_MEAT',
  'processed_meat_deli_meat',
  'Deli/Lunch Meat',
  'Deli/Lunch Meat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_DELI_MEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_DELI_MEAT',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Hot Dog
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_HOT_DOG',
  'processed_meat_hot_dog',
  'Hot Dog',
  'Hot Dog aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_HOT_DOG', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_HOT_DOG',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Jerky/Dried Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_JERKY',
  'processed_meat_jerky',
  'Jerky/Dried Meat',
  'Jerky/Dried Meat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_JERKY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_JERKY',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Nitrate-Free Deli Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_NITRATE_FREE_DELI',
  'processed_meat_nitrate_free_deli',
  'Nitrate-Free Deli Meat',
  'Nitrate-Free Deli Meat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_NITRATE_FREE_DELI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_NITRATE_FREE_DELI',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pepperoni
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_PEPPERONI',
  'processed_meat_pepperoni',
  'Pepperoni',
  'Pepperoni aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_PEPPERONI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_PEPPERONI',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Prosciutto/Cured Ham
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_PROSCIUTTO',
  'processed_meat_prosciutto',
  'Prosciutto/Cured Ham',
  'Prosciutto/Cured Ham aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_PROSCIUTTO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_PROSCIUTTO',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Salami
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_SALAMI',
  'processed_meat_salami',
  'Salami',
  'Salami aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SALAMI', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_SALAMI',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sausage
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_SAUSAGE',
  'processed_meat_sausage',
  'Sausage',
  'Sausage aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SAUSAGE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_SAUSAGE',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Smoked Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROCESSED_MEAT_SMOKED_MEAT',
  'processed_meat_smoked_meat',
  'Smoked Meat',
  'Smoked Meat aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROCESSED_MEAT_SMOKED_MEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_PROCESSED_MEAT_SMOKED_MEAT',
  'DEF_PROCESSED_MEAT_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Afternoon Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_AFTERNOON_SNACK',
  'protein_timing_afternoon_snack',
  'Afternoon Snack',
  'Afternoon Snack aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_AFTERNOON_SNACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_AFTERNOON_SNACK',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "afternoon_snack"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Breakfast
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_BREAKFAST',
  'protein_timing_breakfast',
  'Breakfast',
  'Breakfast aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_BREAKFAST', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_BREAKFAST',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "breakfast"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Dinner
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_DINNER',
  'protein_timing_dinner',
  'Dinner',
  'Dinner aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_DINNER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_DINNER',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "dinner"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Evening Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_EVENING_SNACK',
  'protein_timing_evening_snack',
  'Evening Snack',
  'Evening Snack aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_EVENING_SNACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_EVENING_SNACK',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "evening_snack"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lunch
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_LUNCH',
  'protein_timing_lunch',
  'Lunch',
  'Lunch aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_LUNCH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_LUNCH',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "lunch"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Morning Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_MORNING_SNACK',
  'protein_timing_morning_snack',
  'Morning Snack',
  'Morning Snack aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_MORNING_SNACK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_MORNING_SNACK',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "morning_snack"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TIMING_OTHER',
  'protein_timing_other',
  'Other',
  'Other aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TIMING_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TIMING_OTHER',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TIMING", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cottage Cheese
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_COTTAGE_CHEESE',
  'protein_cottage_cheese',
  'Cottage Cheese',
  'Cottage Cheese aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_COTTAGE_CHEESE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_COTTAGE_CHEESE',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "cottage_cheese"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Eggs
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_EGGS',
  'protein_eggs',
  'Eggs',
  'Eggs aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_EGGS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_EGGS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_EGGS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_EGGS',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "eggs"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fatty Fish
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_FATTY_FISH',
  'protein_fatty_fish',
  'Fatty Fish',
  'Fatty Fish aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_FATTY_FISH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_FATTY_FISH',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "fatty_fish"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Fish
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_FISH',
  'protein_fish',
  'Fish',
  'Fish aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_FISH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_FISH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_FISH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_FISH',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "fish"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Greek Yogurt
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_GREEK_YOGURT',
  'protein_greek_yogurt',
  'Greek Yogurt',
  'Greek Yogurt aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_GREEK_YOGURT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_GREEK_YOGURT',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "greek_yogurt"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lean Beef
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_LEAN_BEEF',
  'protein_lean_beef',
  'Lean Beef',
  'Lean Beef aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_BEEF', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_LEAN_BEEF',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "lean_beef"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lean Poultry
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_LEAN_POULTRY',
  'protein_lean_poultry',
  'Lean Poultry',
  'Lean Poultry aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_POULTRY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_LEAN_POULTRY',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "lean_poultry"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Lean Protein
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_LEAN_PROTEIN',
  'protein_lean_protein',
  'Lean Protein',
  'Lean Protein aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_LEAN_PROTEIN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_LEAN_PROTEIN',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "lean_protein"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Plant Protein Powder
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_PROTEIN_POWDER_PLANT',
  'protein_protein_powder_plant',
  'Plant Protein Powder',
  'Plant Protein Powder aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_PLANT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_PROTEIN_POWDER_PLANT',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "protein_powder_plant"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Plant-based
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_PLANT_BASED',
  'protein_plant_based',
  'Plant-based',
  'Plant-based aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PLANT_BASED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_PLANT_BASED',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "plant_based"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Plant-Based Protein
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_PLANT_PROTEIN',
  'protein_plant_protein',
  'Plant-Based Protein',
  'Plant-Based Protein aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PLANT_PROTEIN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_PLANT_PROTEIN',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "plant_protein"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Processed Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_PROCESSED_MEAT',
  'protein_processed_meat',
  'Processed Meat',
  'Processed Meat aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROCESSED_MEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_PROCESSED_MEAT',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "processed_meat"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Red Meat
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_RED_MEAT',
  'protein_red_meat',
  'Red Meat',
  'Red Meat aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_RED_MEAT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_RED_MEAT',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "red_meat"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Seitan
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_SEITAN',
  'protein_seitan',
  'Seitan',
  'Seitan aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SEITAN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_SEITAN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_SEITAN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_SEITAN',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "seitan"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Supplement
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_SUPPLEMENT',
  'protein_supplement',
  'Supplement',
  'Supplement aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_SUPPLEMENT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_SUPPLEMENT',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "supplement"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Tempeh
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TEMPEH',
  'protein_tempeh',
  'Tempeh',
  'Tempeh aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TEMPEH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TEMPEH',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "tempeh"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Tofu
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_TOFU',
  'protein_tofu',
  'Tofu',
  'Tofu aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_TOFU', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TOFU', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_TOFU', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_TOFU',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "tofu"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Whey Protein Powder
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_PROTEIN_PROTEIN_POWDER_WHEY',
  'protein_protein_powder_whey',
  'Whey Protein Powder',
  'Whey Protein Powder aggregation',
  'gram',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_PROTEIN_PROTEIN_POWDER_WHEY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_PROTEIN_PROTEIN_POWDER_WHEY',
  'DEF_PROTEIN_GRAMS',
  'data_field',
  '{"reference_field": "DEF_PROTEIN_TYPE", "reference_value": "protein_powder_whey"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Computer
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_COMPUTER',
  'screen_time_computer',
  'Computer',
  'Computer aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_COMPUTER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_COMPUTER',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Gaming
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_GAMING',
  'screen_time_gaming',
  'Gaming',
  'Gaming aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_GAMING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_GAMING',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Phone
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_PHONE',
  'screen_time_phone',
  'Phone',
  'Phone aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_PHONE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_PHONE',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Tablet
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_TABLET',
  'screen_time_tablet',
  'Tablet',
  'Tablet aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TABLET', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_TABLET',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Total (All Screens)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_TOTAL',
  'screen_time_total',
  'Total (All Screens)',
  'Total (All Screens) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TOTAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_TOTAL',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- TV
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SCREEN_TIME_TV',
  'screen_time_tv',
  'TV',
  'TV aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SCREEN_TIME_TV', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TV', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SCREEN_TIME_TV', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SCREEN_TIME_TV',
  'DEF_SCREEN_TIME_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cleanse
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_CLEANSE',
  'skincare_steps_cleanse',
  'Cleanse',
  'Cleanse aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_CLEANSE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_CLEANSE',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Eye Cream
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_EYE_CREAM',
  'skincare_steps_eye_cream',
  'Eye Cream',
  'Eye Cream aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_EYE_CREAM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_EYE_CREAM',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Face Mask
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_MASK',
  'skincare_steps_mask',
  'Face Mask',
  'Face Mask aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_MASK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_MASK',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Moisturize
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_MOISTURIZE',
  'skincare_steps_moisturize',
  'Moisturize',
  'Moisturize aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_MOISTURIZE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_MOISTURIZE',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Retinol (PM)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_RETINOL',
  'skincare_steps_retinol',
  'Retinol (PM)',
  'Retinol (PM) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_RETINOL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_RETINOL',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Serum
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_SERUM',
  'skincare_steps_serum',
  'Serum',
  'Serum aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_SERUM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_SERUM',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sunscreen (AM)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_SUNSCREEN',
  'skincare_steps_sunscreen',
  'Sunscreen (AM)',
  'Sunscreen (AM) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_SUNSCREEN', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_SUNSCREEN',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Tone
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SKINCARE_STEPS_TONE',
  'skincare_steps_tone',
  'Tone',
  'Tone aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SKINCARE_STEPS_TONE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SKINCARE_STEPS_TONE',
  'DEF_SKINCARE_STEP',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Asleep (Unspecified)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_UNSPECIFIED',
  'sleep_period_unspecified',
  'Asleep (Unspecified)',
  'Asleep (Unspecified) aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_UNSPECIFIED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_UNSPECIFIED',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Awake
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_AWAKE',
  'sleep_period_awake',
  'Awake',
  'Awake aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_AWAKE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_AWAKE',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Core Sleep
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_CORE',
  'sleep_period_core',
  'Core Sleep',
  'Core Sleep aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_CORE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_CORE',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Deep Sleep
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_DEEP',
  'sleep_period_deep',
  'Deep Sleep',
  'Deep Sleep aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_DEEP', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_DEEP',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- In Bed
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_IN_BED',
  'sleep_period_in_bed',
  'In Bed',
  'In Bed aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_IN_BED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_IN_BED',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- REM Sleep
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SLEEP_PERIOD_REM',
  'sleep_period_rem',
  'REM Sleep',
  'REM Sleep aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SLEEP_PERIOD_REM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SLEEP_PERIOD_REM',
  'DEF_SLEEP_PERIOD_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Community Event
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_COMMUNITY_EVENT',
  'social_event_community_event',
  'Community Event',
  'Community Event aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_COMMUNITY_EVENT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_COMMUNITY_EVENT',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Family Gathering
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_FAMILY_GATHERING',
  'social_event_family_gathering',
  'Family Gathering',
  'Family Gathering aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_FAMILY_GATHERING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_FAMILY_GATHERING',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Friend Meetup
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_FRIEND_MEETUP',
  'social_event_friend_meetup',
  'Friend Meetup',
  'Friend Meetup aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_FRIEND_MEETUP', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_FRIEND_MEETUP',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Phone/Video Call
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_PHONE_CALL',
  'social_event_phone_call',
  'Phone/Video Call',
  'Phone/Video Call aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_PHONE_CALL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_PHONE_CALL',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Social Meal
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_SOCIAL_MEAL',
  'social_event_social_meal',
  'Social Meal',
  'Social Meal aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_SOCIAL_MEAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_SOCIAL_MEAL',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Volunteer Work
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SOCIAL_EVENT_VOLUNTEER',
  'social_event_volunteer',
  'Volunteer Work',
  'Volunteer Work aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SOCIAL_EVENT_VOLUNTEER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SOCIAL_EVENT_VOLUNTEER',
  'DEF_SOCIAL_EVENT_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Barre
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_BARRE',
  'strength_barre',
  'Barre',
  'Barre aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BARRE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_BARRE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_BARRE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_BARRE',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "barre"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Bodyweight Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_BODYWEIGHT',
  'strength_bodyweight',
  'Bodyweight Training',
  'Bodyweight Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_BODYWEIGHT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_BODYWEIGHT',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "bodyweight"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Calisthenics
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_CALISTHENICS',
  'strength_calisthenics',
  'Calisthenics',
  'Calisthenics aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CALISTHENICS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_CALISTHENICS',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "calisthenics"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Core Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_CORE_TRAINING',
  'strength_core_training',
  'Core Training',
  'Core Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CORE_TRAINING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_CORE_TRAINING',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "core_training"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Cross Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_CROSS_TRAINING',
  'strength_cross_training',
  'Cross Training',
  'Cross Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_CROSS_TRAINING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_CROSS_TRAINING',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "cross_training"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Functional Strength Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_FUNCTIONAL',
  'strength_functional',
  'Functional Strength Training',
  'Functional Strength Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_FUNCTIONAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_FUNCTIONAL',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "functional"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Kettlebell Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_KETTLEBELL',
  'strength_kettlebell',
  'Kettlebell Training',
  'Kettlebell Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_KETTLEBELL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_KETTLEBELL',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "kettlebell"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Olympic Weightlifting
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_OLYMPIC_LIFTING',
  'strength_olympic_lifting',
  'Olympic Weightlifting',
  'Olympic Weightlifting aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_OLYMPIC_LIFTING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_OLYMPIC_LIFTING',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "olympic_lifting"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Other
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_OTHER',
  'strength_other',
  'Other',
  'Other aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_OTHER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_OTHER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_OTHER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_OTHER',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "other"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Powerlifting
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_POWERLIFTING',
  'strength_powerlifting',
  'Powerlifting',
  'Powerlifting aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_POWERLIFTING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_POWERLIFTING',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "powerlifting"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Resistance Band Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_RESISTANCE_BAND',
  'strength_resistance_band',
  'Resistance Band Training',
  'Resistance Band Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_RESISTANCE_BAND', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_RESISTANCE_BAND',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "resistance_band"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Traditional Strength Training
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_TRADITIONAL',
  'strength_traditional',
  'Traditional Strength Training',
  'Traditional Strength Training aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_TRADITIONAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_TRADITIONAL',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "traditional"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Unassigned
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_STRENGTH_UNASSIGNED',
  'strength_unassigned',
  'Unassigned',
  'Unassigned aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_STRENGTH_UNASSIGNED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type, filter_conditions
) VALUES (
  'AGG_STRENGTH_UNASSIGNED',
  'DEF_STRENGTH_DURATION',
  'data_field',
  '{"reference_field": "DEF_STRENGTH_TYPE", "reference_value": "unassigned"}'::jsonb
) ON CONFLICT DO NOTHING;


-- Alcohol
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_ALCOHOL',
  'substance_alcohol',
  'Alcohol',
  'Alcohol aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_ALCOHOL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_ALCOHOL',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cannabis (Edibles)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_EDIBLES',
  'substance_cannabis_edibles',
  'Cannabis (Edibles)',
  'Cannabis (Edibles) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_EDIBLES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_EDIBLES',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cannabis (Smoking)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_SMOKING',
  'substance_cannabis_smoking',
  'Cannabis (Smoking)',
  'Cannabis (Smoking) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_SMOKING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_SMOKING',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cannabis (Vaping)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_VAPING',
  'substance_cannabis_vaping',
  'Cannabis (Vaping)',
  'Cannabis (Vaping) aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CANNABIS_VAPING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_CANNABIS_VAPING',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chewing Tobacco/Dip
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_CHEWING_TOBACCO',
  'substance_chewing_tobacco',
  'Chewing Tobacco/Dip',
  'Chewing Tobacco/Dip aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CHEWING_TOBACCO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_CHEWING_TOBACCO',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cigars
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_CIGARS',
  'substance_cigars',
  'Cigars',
  'Cigars aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_CIGARS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_CIGARS',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Nicotine Gum
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_GUM',
  'substance_nicotine_gum',
  'Nicotine Gum',
  'Nicotine Gum aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_GUM', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_GUM',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Nicotine Lozenge
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_LOZENGE',
  'substance_nicotine_lozenge',
  'Nicotine Lozenge',
  'Nicotine Lozenge aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_LOZENGE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_LOZENGE',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Nicotine Patch
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_PATCH',
  'substance_nicotine_patch',
  'Nicotine Patch',
  'Nicotine Patch aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_NICOTINE_PATCH', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_NICOTINE_PATCH',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Other Substance
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_OTHER_SUBSTANCE',
  'substance_other_substance',
  'Other Substance',
  'Other Substance aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_OTHER_SUBSTANCE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_OTHER_SUBSTANCE',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pipe Tobacco
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_PIPE_TOBACCO',
  'substance_pipe_tobacco',
  'Pipe Tobacco',
  'Pipe Tobacco aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_PIPE_TOBACCO', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_PIPE_TOBACCO',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Vaping/E-cigarettes
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUBSTANCE_VAPING',
  'substance_vaping',
  'Vaping/E-cigarettes',
  'Vaping/E-cigarettes aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUBSTANCE_VAPING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUBSTANCE_VAPING',
  'DEF_SUBSTANCE_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Afternoon Sunlight
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNLIGHT_AFTERNOON',
  'sunlight_afternoon',
  'Afternoon Sunlight',
  'Afternoon Sunlight aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_AFTERNOON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNLIGHT_AFTERNOON',
  'DEF_SUNLIGHT_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Early Morning Light
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNLIGHT_EARLY_MORNING',
  'sunlight_early_morning',
  'Early Morning Light',
  'Early Morning Light aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_EARLY_MORNING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNLIGHT_EARLY_MORNING',
  'DEF_SUNLIGHT_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Midday Sunlight
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNLIGHT_MIDDAY',
  'sunlight_midday',
  'Midday Sunlight',
  'Midday Sunlight aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_MIDDAY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNLIGHT_MIDDAY',
  'DEF_SUNLIGHT_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Morning Sunlight
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNLIGHT_MORNING',
  'sunlight_morning',
  'Morning Sunlight',
  'Morning Sunlight aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_MORNING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNLIGHT_MORNING',
  'DEF_SUNLIGHT_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Outdoor Activity
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNLIGHT_OUTDOOR_ACTIVITY',
  'sunlight_outdoor_activity',
  'Outdoor Activity',
  'Outdoor Activity aggregation',
  'minute',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNLIGHT_OUTDOOR_ACTIVITY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNLIGHT_OUTDOOR_ACTIVITY',
  'DEF_SUNLIGHT_DURATION',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Morning Application
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNSCREEN_MORNING',
  'sunscreen_morning',
  'Morning Application',
  'Morning Application aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_MORNING', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNSCREEN_MORNING',
  'DEF_SUNSCREEN_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pre-Outdoor Activity
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNSCREEN_PRE_OUTDOOR',
  'sunscreen_pre_outdoor',
  'Pre-Outdoor Activity',
  'Pre-Outdoor Activity aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_PRE_OUTDOOR', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNSCREEN_PRE_OUTDOOR',
  'DEF_SUNSCREEN_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Reapplication
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_SUNSCREEN_REAPPLICATION',
  'sunscreen_reapplication',
  'Reapplication',
  'Reapplication aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_SUNSCREEN_REAPPLICATION', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_SUNSCREEN_REAPPLICATION',
  'DEF_SUNSCREEN_TIME',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Breakfast/Cereal Bar
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_BREAKFAST_BAR',
  'ultra_processed_breakfast_bar',
  'Breakfast/Cereal Bar',
  'Breakfast/Cereal Bar aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_BAR', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_BREAKFAST_BAR',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Candy/Chocolate Bars
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE',
  'ultra_processed_candy_chocolate',
  'Candy/Chocolate Bars',
  'Candy/Chocolate Bars aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_CANDY_CHOCOLATE',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Chips/Crisps
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_CHIPS_CRISPS',
  'ultra_processed_chips_crisps',
  'Chips/Crisps',
  'Chips/Crisps aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_CHIPS_CRISPS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_CHIPS_CRISPS',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Energy Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_ENERGY_DRINK',
  'ultra_processed_energy_drink',
  'Energy Drink',
  'Energy Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_ENERGY_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_ENERGY_DRINK',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Frozen Appetizer/Snack
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_FROZEN_APPETIZER',
  'ultra_processed_frozen_appetizer',
  'Frozen Appetizer/Snack',
  'Frozen Appetizer/Snack aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_APPETIZER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_FROZEN_APPETIZER',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Frozen Dinner/Entree
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_FROZEN_DINNER',
  'ultra_processed_frozen_dinner',
  'Frozen Dinner/Entree',
  'Frozen Dinner/Entree aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FROZEN_DINNER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_FROZEN_DINNER',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Fruit Drink/Punch
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_FRUIT_DRINK',
  'ultra_processed_fruit_drink',
  'Fruit Drink/Punch',
  'Fruit Drink/Punch aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_FRUIT_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_FRUIT_DRINK',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Instant Meal Mix
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_INSTANT_MEAL',
  'ultra_processed_instant_meal',
  'Instant Meal Mix',
  'Instant Meal Mix aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_MEAL', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_INSTANT_MEAL',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Instant Noodles/Ramen
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_INSTANT_NOODLES',
  'ultra_processed_instant_noodles',
  'Instant Noodles/Ramen',
  'Instant Noodles/Ramen aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_INSTANT_NOODLES', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_INSTANT_NOODLES',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Meal Replacement Shake/Bar
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT',
  'ultra_processed_meal_replacement',
  'Meal Replacement Shake/Bar',
  'Meal Replacement Shake/Bar aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_MEAL_REPLACEMENT',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Packaged Cake/Pastry
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_CAKE',
  'ultra_processed_packaged_cake',
  'Packaged Cake/Pastry',
  'Packaged Cake/Pastry aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CAKE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_CAKE',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Packaged Cookies
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_COOKIES_PACKAGED',
  'ultra_processed_cookies_packaged',
  'Packaged Cookies',
  'Packaged Cookies aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_COOKIES_PACKAGED', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_COOKIES_PACKAGED',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Packaged Crackers
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS',
  'ultra_processed_packaged_crackers',
  'Packaged Crackers',
  'Packaged Crackers aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_CRACKERS',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Pre-Made Deli Salad
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_DELI_SALAD',
  'ultra_processed_deli_salad',
  'Pre-Made Deli Salad',
  'Pre-Made Deli Salad aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_DELI_SALAD', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_DELI_SALAD',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Soda/Soft Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_SODA',
  'ultra_processed_soda',
  'Soda/Soft Drink',
  'Soda/Soft Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_SODA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_SODA',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sugary Breakfast Cereal
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY',
  'ultra_processed_breakfast_cereal_sugary',
  'Sugary Breakfast Cereal',
  'Sugary Breakfast Cereal aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_BREAKFAST_CEREAL_SUGARY',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Toaster Pastries
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_TOASTER_PASTRY',
  'ultra_processed_toaster_pastry',
  'Toaster Pastries',
  'Toaster Pastries aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_TOASTER_PASTRY', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_TOASTER_PASTRY',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Ultra-Processed Bread
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_BREAD',
  'ultra_processed_packaged_bread',
  'Ultra-Processed Bread',
  'Ultra-Processed Bread aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PACKAGED_BREAD', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_PACKAGED_BREAD',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Ultra-Processed Protein Bar
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF',
  'ultra_processed_protein_bar_upf',
  'Ultra-Processed Protein Bar',
  'Ultra-Processed Protein Bar aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_ULTRA_PROCESSED_PROTEIN_BAR_UPF',
  'DEF_ULTRA_PROCESSED_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Diet Soda
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SODA_DIET',
  'unhealthy_beverage_soda_diet',
  'Diet Soda',
  'Diet Soda aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_DIET', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SODA_DIET',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Flavored Water (Sweetened)
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER',
  'unhealthy_beverage_flavored_water',
  'Flavored Water (Sweetened)',
  'Flavored Water (Sweetened) aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_FLAVORED_WATER',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Fruit Juice
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT',
  'unhealthy_beverage_juice_fruit',
  'Fruit Juice',
  'Fruit Juice aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_JUICE_FRUIT',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Lemonade
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_LEMONADE',
  'unhealthy_beverage_lemonade',
  'Lemonade',
  'Lemonade aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_LEMONADE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_LEMONADE',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Milkshake
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_MILKSHAKE',
  'unhealthy_beverage_milkshake',
  'Milkshake',
  'Milkshake aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_MILKSHAKE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_MILKSHAKE',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Regular Soda
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR',
  'unhealthy_beverage_soda_regular',
  'Regular Soda',
  'Regular Soda aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SODA_REGULAR',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sports Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK',
  'unhealthy_beverage_sports_drink',
  'Sports Drink',
  'Sports Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SPORTS_DRINK',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sweetened Coffee Drink
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE',
  'unhealthy_beverage_sweet_coffee',
  'Sweetened Coffee Drink',
  'Sweetened Coffee Drink aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SWEET_COFFEE',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Sweetened Iced Tea
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA',
  'unhealthy_beverage_sweetened_tea',
  'Sweetened Iced Tea',
  'Sweetened Iced Tea aggregation',
  'serving',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_UNHEALTHY_BEVERAGE_SWEETENED_TEA',
  'DEF_UNHEALTHY_BEV_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Cups
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_CUP',
  'water_units_cup',
  'Cups',
  'Cups aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_CUP', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_CUP', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_CUP', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_CUP',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Fluid Ounces
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_FLUID_OUNCE',
  'water_units_fluid_ounce',
  'Fluid Ounces',
  'Fluid Ounces aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_FLUID_OUNCE', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_FLUID_OUNCE',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Liters
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_LITER',
  'water_units_liter',
  'Liters',
  'Liters aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_LITER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_LITER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_LITER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_LITER',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Milliliters
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_MILLILITER',
  'water_units_milliliter',
  'Milliliters',
  'Milliliters aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_MILLILITER', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_MILLILITER',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Tablespoons
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_TABLESPOON',
  'water_units_tablespoon',
  'Tablespoons',
  'Tablespoons aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_TABLESPOON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_TABLESPOON',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- Teaspoons
INSERT INTO aggregation_metrics (
  agg_id, metric_name, display_name, description,
  output_unit, is_active
) VALUES (
  'AGG_WATER_UNITS_TEASPOON',
  'water_units_teaspoon',
  'Teaspoons',
  'Teaspoons aggregation',
  'count',
  true
) ON CONFLICT (agg_id) DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'hourly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'daily')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'weekly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'monthly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', '6month')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_periods (agg_metric_id, period_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'yearly')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'SUM')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_calculation_types (aggregation_metric_id, calculation_type_id)
VALUES ('AGG_WATER_UNITS_TEASPOON', 'AVG')
ON CONFLICT DO NOTHING;


INSERT INTO aggregation_metrics_dependencies (
  agg_metric_id, data_entry_field_id, dependency_type
) VALUES (
  'AGG_WATER_UNITS_TEASPOON',
  'DEF_WATER_QUANTITY',
  'data_field'
) ON CONFLICT DO NOTHING;


-- =====================================================
-- Summary
-- =====================================================

DO $$
DECLARE
  v_total_aggs INTEGER;
BEGIN
  SELECT COUNT(*) INTO v_total_aggs FROM aggregation_metrics;

  RAISE NOTICE '';
  RAISE NOTICE '✅ Generated Complete Aggregations!';
  RAISE NOTICE '';
  RAISE NOTICE 'Summary:';
  RAISE NOTICE '  Total aggregations: %', v_total_aggs;
  RAISE NOTICE '  New aggregations added: 359';
  RAISE NOTICE '';
  RAISE NOTICE 'All reference values now have aggregations';
  RAISE NOTICE '';
END $$;

COMMIT;
