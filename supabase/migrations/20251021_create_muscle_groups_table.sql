-- =====================================================
-- Create Muscle Groups Reference Table
-- =====================================================
-- Optional muscle group selection for strength training
-- Supports multi-select to track which muscles were targeted
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Create Muscle Groups Table
-- =====================================================

CREATE TABLE IF NOT EXISTS def_ref_muscle_groups (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  muscle_group_key TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  category TEXT, -- 'upper_body', 'lower_body', 'core', 'full_body'
  description TEXT,
  primary_muscles TEXT, -- e.g., "quadriceps, hamstrings, glutes"
  is_compound BOOLEAN DEFAULT false, -- True for groups involving multiple muscles
  typical_exercises TEXT, -- Examples: "squats, lunges, leg press"
  display_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_muscle_groups_active ON def_ref_muscle_groups(is_active);
CREATE INDEX IF NOT EXISTS idx_muscle_groups_category ON def_ref_muscle_groups(category);


-- =====================================================
-- PART 2: Seed Muscle Groups
-- =====================================================

INSERT INTO def_ref_muscle_groups (
  muscle_group_key,
  display_name,
  category,
  description,
  primary_muscles,
  is_compound,
  typical_exercises,
  display_order
) VALUES
-- Upper Body - Push
('chest', 'Chest', 'upper_body', 'Pectoral muscles', 'pectoralis major, pectoralis minor', true, 'bench press, push-ups, chest fly', 1),
('shoulders', 'Shoulders', 'upper_body', 'Deltoid muscles', 'anterior deltoid, medial deltoid, posterior deltoid', true, 'shoulder press, lateral raises, front raises', 2),
('triceps', 'Triceps', 'upper_body', 'Triceps muscles', 'triceps brachii', false, 'tricep dips, overhead extension, close-grip press', 3),

-- Upper Body - Pull
('back', 'Back', 'upper_body', 'Latissimus dorsi and upper back', 'latissimus dorsi, rhomboids, trapezius', true, 'pull-ups, rows, lat pulldown', 4),
('biceps', 'Biceps', 'upper_body', 'Biceps muscles', 'biceps brachii, brachialis', false, 'bicep curls, hammer curls, chin-ups', 5),
('forearms', 'Forearms', 'upper_body', 'Forearm and grip muscles', 'wrist flexors, wrist extensors', false, 'wrist curls, farmer carries, dead hangs', 6),

-- Lower Body
('quads', 'Quadriceps', 'lower_body', 'Front thigh muscles', 'rectus femoris, vastus lateralis, vastus medialis, vastus intermedius', true, 'squats, lunges, leg extension', 7),
('hamstrings', 'Hamstrings', 'lower_body', 'Back thigh muscles', 'biceps femoris, semitendinosus, semimembranosus', true, 'deadlifts, leg curls, Romanian deadlifts', 8),
('glutes', 'Glutes', 'lower_body', 'Buttocks muscles', 'gluteus maximus, gluteus medius, gluteus minimus', true, 'squats, hip thrusts, lunges', 9),
('calves', 'Calves', 'lower_body', 'Calf muscles', 'gastrocnemius, soleus', false, 'calf raises, jump rope', 10),

-- Core
('abs', 'Abs', 'core', 'Abdominal muscles', 'rectus abdominis, external obliques, internal obliques', true, 'crunches, planks, leg raises', 11),
('core', 'Core (General)', 'core', 'All core stabilizing muscles', 'transverse abdominis, rectus abdominis, obliques, erector spinae', true, 'planks, dead bug, bird dog, anti-rotation exercises', 12),
('lower_back', 'Lower Back', 'core', 'Erector spinae and lower back', 'erector spinae, multifidus', true, 'deadlifts, back extensions, good mornings', 13),

-- Full Body
('full_body', 'Full Body', 'full_body', 'Multiple muscle groups worked simultaneously', 'all major muscle groups', true, 'burpees, thrusters, cleans, snatches', 14)

ON CONFLICT (muscle_group_key) DO NOTHING;


-- =====================================================
-- PART 3: Link DEF_STRENGTH_MUSCLE_GROUPS Field
-- =====================================================

UPDATE data_entry_fields
SET
  reference_table = 'def_ref_muscle_groups',
  data_type = 'jsonb', -- JSONB array to support multiple muscle groups
  description = 'Muscle groups targeted (optional, multi-select). Stores JSONB array of muscle_group_keys.'
WHERE field_id = 'DEF_STRENGTH_MUSCLE_GROUPS';


-- =====================================================
-- PART 4: Add Helper Function
-- =====================================================

-- Function to check if workout targeted a specific muscle group
CREATE OR REPLACE FUNCTION workout_targets_muscle(muscle_groups JSONB, muscle_key TEXT)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN muscle_groups ? muscle_key;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION workout_targets_muscle IS
'Helper function to check if a workout entry targeted a specific muscle group. Usage: WHERE workout_targets_muscle(value_reference::jsonb, ''chest'')';


-- =====================================================
-- PART 5: Add Comments
-- =====================================================

COMMENT ON TABLE def_ref_muscle_groups IS
'Reference table for muscle groups. Optional multi-select for strength training to track which muscles were targeted.';

COMMENT ON COLUMN def_ref_muscle_groups.is_compound IS
'True for muscle groups involving multiple muscles working together (e.g., back, legs). False for isolation (e.g., biceps, calves).';

-- Example usage comment
COMMENT ON COLUMN data_entry_fields.reference_table IS
E'Reference table name. For muscle_groups: stores JSONB array of muscle_group_keys.\n\nExample stored value: ["chest", "shoulders", "triceps"]\n\nQuery example: SELECT * FROM patient_data_entries WHERE value_reference::jsonb ? ''chest''';

COMMIT;
