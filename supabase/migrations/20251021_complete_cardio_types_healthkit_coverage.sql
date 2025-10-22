-- =====================================================
-- Complete Cardio Types with Full HealthKit Coverage
-- =====================================================
-- Adds 40+ missing HealthKit cardio workout types
-- Organized by category for Zone 2 tracking and comprehensive coverage
--
-- Categories: Walking/Running, Water Sports, Snow/Ice Sports,
-- Team Sports, Racket Sports, Outdoor, Multisport
--
-- Created: 2025-10-21
-- =====================================================

BEGIN;

-- =====================================================
-- PART 1: Walking & Running Variations
-- =====================================================

INSERT INTO def_ref_cardio_types (
  cardio_name,
  display_name,
  description,
  healthkit_identifier,
  met_score,
  typical_intensity,
  tracks_distance,
  tracks_elevation,
  typical_indoor,
  supports_distance,
  supports_intensity
) VALUES
('wheelchair_walk', 'Wheelchair Walking', 'Wheelchair walking pace', 'HKWorkoutActivityTypeWheelchairWalkPace', 3.0, 'moderate', true, false, false, true, true),
('wheelchair_run', 'Wheelchair Running', 'Wheelchair running pace', 'HKWorkoutActivityTypeWheelchairRunPace', 6.0, 'high', true, false, false, true, true),
('stairs_outdoor', 'Stair Climbing (Outdoor)', 'Climbing outdoor stairs', 'HKWorkoutActivityTypeStairs', 8.0, 'high', false, true, false, false, true),

-- =====================================================
-- PART 2: Water Sports
-- =====================================================

('paddle_sports', 'Paddle Sports', 'Kayaking, canoeing, SUP', 'HKWorkoutActivityTypePaddleSports', 5.0, 'moderate', true, false, false, true, true),
('sailing', 'Sailing', 'Sailing', 'HKWorkoutActivityTypeSailing', 3.0, 'low', true, false, false, true, false),
('surfing', 'Surfing', 'Surfing, kite surfing, wind surfing', 'HKWorkoutActivityTypeSurfingSports', 6.0, 'moderate', false, false, false, false, true),
('underwater_diving', 'Underwater Diving', 'Scuba diving, free diving', 'HKWorkoutActivityTypeUnderwaterDiving', 7.0, 'moderate', false, false, false, false, true),
('water_polo', 'Water Polo', 'Playing water polo', 'HKWorkoutActivityTypeWaterPolo', 10.0, 'very_high', false, false, false, false, true),
('water_sports', 'Water Sports', 'Water skiing, wake boarding', 'HKWorkoutActivityTypeWaterSports', 6.0, 'moderate', false, false, false, false, true),
('water_fitness', 'Water Fitness', 'Water aerobics, aqua fitness', 'HKWorkoutActivityTypeWaterFitness', 5.5, 'moderate', false, false, true, false, true),

-- =====================================================
-- PART 3: Snow & Ice Sports
-- =====================================================

('cross_country_skiing', 'Cross Country Skiing', 'Nordic skiing', 'HKWorkoutActivityTypeCrossCountrySkiing', 9.0, 'high', true, true, false, true, true),
('downhill_skiing', 'Downhill Skiing', 'Alpine skiing', 'HKWorkoutActivityTypeDownhillSkiing', 6.0, 'moderate', true, true, false, true, true),
('snowboarding', 'Snowboarding', 'Snowboarding', 'HKWorkoutActivityTypeSnowboarding', 6.0, 'moderate', true, true, false, true, true),
('skating', 'Skating', 'Ice skating, roller skating', 'HKWorkoutActivityTypeSkatingSports', 7.0, 'moderate', true, false, false, true, true),
('curling', 'Curling', 'Curling', 'HKWorkoutActivityTypeCurling', 4.0, 'low', false, false, true, false, false),
('snow_sports', 'Snow Sports', 'General snow activities', 'HKWorkoutActivityTypeSnowSports', 6.0, 'moderate', true, true, false, true, true),

-- =====================================================
-- PART 4: Team Sports
-- =====================================================

('soccer', 'Soccer', 'Football/soccer', 'HKWorkoutActivityTypeSoccer', 10.0, 'high', true, false, false, true, true),
('basketball', 'Basketball', 'Basketball', 'HKWorkoutActivityTypeBasketball', 8.0, 'high', false, false, false, false, true),
('american_football', 'American Football', 'American football', 'HKWorkoutActivityTypeAmericanFootball', 8.0, 'high', true, false, false, true, true),
('rugby', 'Rugby', 'Rugby', 'HKWorkoutActivityTypeRugby', 10.0, 'very_high', true, false, false, true, true),
('hockey', 'Hockey', 'Ice hockey, field hockey', 'HKWorkoutActivityTypeHockey', 10.0, 'very_high', true, false, false, true, true),
('lacrosse', 'Lacrosse', 'Lacrosse', 'HKWorkoutActivityTypeLacrosse', 8.0, 'high', true, false, false, true, true),
('volleyball', 'Volleyball', 'Volleyball', 'HKWorkoutActivityTypeVolleyball', 6.0, 'moderate', false, false, false, false, true),
('baseball', 'Baseball', 'Baseball', 'HKWorkoutActivityTypeBaseball', 5.0, 'moderate', true, false, false, true, false),
('softball', 'Softball', 'Softball', 'HKWorkoutActivityTypeSoftball', 5.0, 'moderate', true, false, false, true, false),
('cricket', 'Cricket', 'Cricket', 'HKWorkoutActivityTypeCricket', 5.0, 'moderate', true, false, false, true, false),
('handball', 'Handball', 'Team handball', 'HKWorkoutActivityTypeHandball', 8.0, 'high', true, false, false, true, true),
('australian_football', 'Australian Football', 'Aussie rules football', 'HKWorkoutActivityTypeAustralianFootball', 9.0, 'high', true, false, false, true, true),
('disc_sports', 'Disc Sports', 'Ultimate frisbee, disc golf', 'HKWorkoutActivityTypeDiscSports', 7.0, 'moderate', true, false, false, true, true),

-- =====================================================
-- PART 5: Racket Sports
-- =====================================================

('tennis', 'Tennis', 'Tennis', 'HKWorkoutActivityTypeTennis', 7.0, 'moderate', false, false, false, false, true),
('badminton', 'Badminton', 'Badminton', 'HKWorkoutActivityTypeBadminton', 6.0, 'moderate', false, false, true, false, true),
('pickleball', 'Pickleball', 'Pickleball', 'HKWorkoutActivityTypePickleball', 6.0, 'moderate', false, false, false, false, true),
('squash', 'Squash', 'Squash', 'HKWorkoutActivityTypeSquash', 12.0, 'very_high', false, false, true, false, true),
('racquetball', 'Racquetball', 'Racquetball', 'HKWorkoutActivityTypeRacquetball', 10.0, 'high', false, false, true, false, true),
('table_tennis', 'Table Tennis', 'Ping pong', 'HKWorkoutActivityTypeTableTennis', 4.0, 'moderate', false, false, true, false, true),

-- =====================================================
-- PART 6: Outdoor & Recreation
-- =====================================================

('climbing', 'Climbing', 'Rock climbing, bouldering', 'HKWorkoutActivityTypeClimbing', 8.0, 'high', false, true, false, false, true),
('equestrian', 'Equestrian', 'Horse riding', 'HKWorkoutActivityTypeEquestrianSports', 5.5, 'moderate', true, false, false, true, false),
('golf', 'Golf', 'Golf (walking course)', 'HKWorkoutActivityTypeGolf', 4.5, 'low', true, false, false, true, false),
('fishing', 'Fishing', 'Fishing', 'HKWorkoutActivityTypeFishing', 3.0, 'low', false, false, false, false, false),
('hunting', 'Hunting', 'Hunting', 'HKWorkoutActivityTypeHunting', 5.0, 'moderate', true, true, false, true, false),
('track_field', 'Track & Field', 'Track and field events', 'HKWorkoutActivityTypeTrackAndField', 8.0, 'high', true, false, false, true, true),
('gymnastics', 'Gymnastics', 'Gymnastics training', 'HKWorkoutActivityTypeGymnastics', 6.0, 'moderate', false, false, true, false, true),

-- =====================================================
-- PART 7: Dance & Studio
-- =====================================================

('social_dance', 'Social Dance', 'Partner dancing, ballroom', 'HKWorkoutActivityTypeSocialDance', 4.5, 'moderate', false, false, true, false, true),

-- =====================================================
-- PART 8: Other Cardio Activities
-- =====================================================

('step_training', 'Step Training', 'Step aerobics', 'HKWorkoutActivityTypeStepTraining', 7.0, 'moderate', false, false, true, false, true),
('mixed_cardio', 'Mixed Cardio', 'Mixed cardio activities', 'HKWorkoutActivityTypeMixedCardio', 7.0, 'moderate', false, false, false, false, true),
('fitness_gaming', 'Fitness Gaming', 'Active video games, VR fitness', 'HKWorkoutActivityTypeFitnessGaming', 5.0, 'moderate', false, false, true, false, true),
('hand_cycling', 'Hand Cycling', 'Hand-powered cycling', 'HKWorkoutActivityTypeHandCycling', 6.0, 'moderate', true, false, false, true, true),
('archery', 'Archery', 'Archery', 'HKWorkoutActivityTypeArchery', 3.5, 'low', false, false, false, false, false),
('bowling', 'Bowling', 'Bowling', 'HKWorkoutActivityTypeBowling', 3.0, 'low', false, false, true, false, false),
('play', 'Active Play', 'Recreational play, active games', 'HKWorkoutActivityTypePlay', 5.0, 'moderate', false, false, false, false, true),

-- =====================================================
-- PART 9: Multisport & Transitions
-- =====================================================

('triathlon', 'Triathlon (Swim-Bike-Run)', 'Triathlon training or race', 'HKWorkoutActivityTypeSwimBikeRun', 10.0, 'very_high', true, true, false, true, true),
('transition', 'Transition', 'Multisport transition', 'HKWorkoutActivityTypeTransition', 5.0, 'moderate', false, false, false, false, false)

ON CONFLICT (cardio_name) DO NOTHING;


-- =====================================================
-- PART 10: Update Comments
-- =====================================================

COMMENT ON TABLE def_ref_cardio_types IS
'Complete cardio workout types with full HealthKit coverage (50+ types). Includes all HealthKit workout activities categorized as cardio for Zone 2 tracking and comprehensive activity logging.';

COMMENT ON COLUMN def_ref_cardio_types.healthkit_identifier IS
'Direct mapping to HealthKit workout activity type for automatic sync. Enables Zone 2 cardio tracking via heart rate zone analysis.';

COMMIT;
