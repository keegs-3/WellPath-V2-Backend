-- =====================================================
-- Phase 1: Measurement Field Aggregations
-- =====================================================
-- Creates aggregation_metrics for 14 standalone measurement fields
-- Pattern 1: Direct aggregation
--
-- Created: 2025-10-19
-- =====================================================

BEGIN;

-- Body Fat (DEF_113)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_BODY_FAT', 'Body Fat Percentage', 'Body Fat %', 'Body fat percentage measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_BODY_FAT', 'DEF_113', 'data_field');


-- Lean Body Mass (DEF_099)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_LEAN_MASS', 'Lean Body Mass', 'Lean Body Mass', 'Lean body mass measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_LEAN_MASS', 'DEF_099', 'data_field');


-- Visceral Fat (DEF_100)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_VISCERAL_FAT', 'Visceral Fat', 'Visceral Fat', 'Visceral fat measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_VISCERAL_FAT', 'DEF_100', 'data_field');


-- Skeletal Muscle Mass (DEF_209)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_MUSCLE_MASS', 'Skeletal Muscle Mass', 'Skeletal Muscle Mass', 'Skeletal muscle mass measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_MUSCLE_MASS', 'DEF_209', 'data_field');


-- Resting Heart Rate (DEF_107)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_RHR', 'Resting Heart Rate', 'Resting Heart Rate', 'Resting heart rate measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_RHR', 'DEF_107', 'data_field');


-- HRV (DEF_111)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_HRV', 'Heart Rate Variability', 'Heart Rate Variability', 'HRV measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_HRV', 'DEF_111', 'data_field');


-- Systolic BP (DEF_208)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_SYS_BP', 'Systolic Blood Pressure', 'Systolic Blood Pressure', 'Systolic blood pressure measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_SYS_BP', 'DEF_208', 'data_field');


-- Diastolic BP (DEF_207)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_DIA_BP', 'Diastolic Blood Pressure', 'Diastolic Blood Pressure', 'Diastolic blood pressure measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_DIA_BP', 'DEF_207', 'data_field');


-- VO2 Max (DEF_112)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_VO2_MAX', 'VO2 Max', 'VO2 Max', 'VO2 max measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_VO2_MAX', 'DEF_112', 'data_field');


-- Grip Strength (DEF_106)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_GRIP_STRENGTH', 'Grip Strength', 'Grip Strength', 'Grip strength measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_GRIP_STRENGTH', 'DEF_106', 'data_field');


-- Height (DEF_108)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_HEIGHT', 'Height', 'Height', 'Height measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_HEIGHT', 'DEF_108', 'data_field');


-- Waist Circumference (DEF_206)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_WAIST', 'Waist Circumference', 'Waist Circumference', 'Waist circumference measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_WAIST', 'DEF_206', 'data_field');


-- Hip Circumference (DEF_205)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_HIP', 'Hip Circumference', 'Hip Circumference', 'Hip circumference measurements', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_HIP', 'DEF_205', 'data_field');


-- Steps (DEF_036)
INSERT INTO aggregation_metrics (agg_id, metric_name, display_name, description, is_active)
VALUES ('AGG_STEPS', 'Daily Steps', 'Daily Steps', 'Daily step count', true)
ON CONFLICT (agg_id) DO NOTHING;

INSERT INTO aggregation_metrics_dependencies (agg_metric_id, data_entry_field_id, dependency_type)
VALUES ('AGG_STEPS', 'DEF_036', 'data_field');


COMMIT;
