-- =====================================================
-- Add Remaining HealthKit Workout Activity Types
-- =====================================================
-- Adds all remaining HKWorkoutActivityType identifiers
-- including sports, outdoor activities, water sports, martial arts, etc.
--
-- Created: 2025-10-20
-- =====================================================

BEGIN;

-- =====================================================
-- Individual Sports
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeArchery', 'HKWorkoutActivityType', 'Archery', 'individual_sports', 'target', 'Shooting archery', 'iOS 8.0+', true),
('HKWorkoutActivityTypeBowling', 'HKWorkoutActivityType', 'Bowling', 'individual_sports', 'target', 'Bowling', 'iOS 8.0+', true),
('HKWorkoutActivityTypeFencing', 'HKWorkoutActivityType', 'Fencing', 'individual_sports', 'combat', 'Fencing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeGymnastics', 'HKWorkoutActivityType', 'Gymnastics', 'individual_sports', 'artistic', 'Performing gymnastics', 'iOS 8.0+', true),
('HKWorkoutActivityTypeTrackAndField', 'HKWorkoutActivityType', 'Track and Field', 'individual_sports', 'athletics', 'Track and field events', 'iOS 10.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Team Sports
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeAmericanFootball', 'HKWorkoutActivityType', 'American Football', 'team_sports', 'football', 'Playing American football', 'iOS 8.0+', true),
('HKWorkoutActivityTypeAustralianFootball', 'HKWorkoutActivityType', 'Australian Football', 'team_sports', 'football', 'Playing Australian football', 'iOS 8.0+', true),
('HKWorkoutActivityTypeBaseball', 'HKWorkoutActivityType', 'Baseball', 'team_sports', 'ball', 'Playing baseball', 'iOS 8.0+', true),
('HKWorkoutActivityTypeBasketball', 'HKWorkoutActivityType', 'Basketball', 'team_sports', 'ball', 'Playing basketball', 'iOS 8.0+', true),
('HKWorkoutActivityTypeCricket', 'HKWorkoutActivityType', 'Cricket', 'team_sports', 'ball', 'Playing cricket', 'iOS 8.0+', true),
('HKWorkoutActivityTypeDiscSports', 'HKWorkoutActivityType', 'Disc Sports', 'team_sports', 'disc', 'Ultimate, Disc Golf, etc.', 'iOS 10.0+', true),
('HKWorkoutActivityTypeHandball', 'HKWorkoutActivityType', 'Handball', 'team_sports', 'ball', 'Playing handball', 'iOS 8.0+', true),
('HKWorkoutActivityTypeHockey', 'HKWorkoutActivityType', 'Hockey', 'team_sports', 'stick', 'Ice hockey, field hockey, etc.', 'iOS 8.0+', true),
('HKWorkoutActivityTypeLacrosse', 'HKWorkoutActivityType', 'Lacrosse', 'team_sports', 'stick', 'Playing lacrosse', 'iOS 8.0+', true),
('HKWorkoutActivityTypeRugby', 'HKWorkoutActivityType', 'Rugby', 'team_sports', 'football', 'Playing rugby', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSoccer', 'HKWorkoutActivityType', 'Soccer', 'team_sports', 'football', 'Playing soccer/football', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSoftball', 'HKWorkoutActivityType', 'Softball', 'team_sports', 'ball', 'Playing softball', 'iOS 8.0+', true),
('HKWorkoutActivityTypeVolleyball', 'HKWorkoutActivityType', 'Volleyball', 'team_sports', 'ball', 'Playing volleyball', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Additional Exercise & Fitness
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeWheelchairWalkPace', 'HKWorkoutActivityType', 'Wheelchair Walk Pace', 'cardio', 'adaptive', 'Wheelchair at walking pace', 'iOS 10.0+', true),
('HKWorkoutActivityTypeWheelchairRunPace', 'HKWorkoutActivityType', 'Wheelchair Run Pace', 'cardio', 'adaptive', 'Wheelchair at running pace', 'iOS 10.0+', true),
('HKWorkoutActivityTypeCoreTraining', 'HKWorkoutActivityType', 'Core Training', 'strength', 'core', 'Core strength training', 'iOS 11.0+', true),
('HKWorkoutActivityTypeFitnessGaming', 'HKWorkoutActivityType', 'Fitness Gaming', 'other', 'gaming', 'Fitness-based video games', 'iOS 13.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Studio Activities
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeBarre', 'HKWorkoutActivityType', 'Barre', 'studio', 'dance_fitness', 'Barre workout', 'iOS 11.0+', true),
('HKWorkoutActivityTypeMindAndBody', 'HKWorkoutActivityType', 'Mind and Body', 'studio', 'mindful', 'Walking meditation, Gyrotonic, Qigong', 'iOS 11.0+', true),
('HKWorkoutActivityTypePilates', 'HKWorkoutActivityType', 'Pilates', 'studio', 'core', 'Pilates workout', 'iOS 11.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Racket Sports
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeBadminton', 'HKWorkoutActivityType', 'Badminton', 'racket_sports', 'net', 'Playing badminton', 'iOS 8.0+', true),
('HKWorkoutActivityTypePickleball', 'HKWorkoutActivityType', 'Pickleball', 'racket_sports', 'net', 'Playing pickleball', 'iOS 14.0+', true),
('HKWorkoutActivityTypeRacquetball', 'HKWorkoutActivityType', 'Racquetball', 'racket_sports', 'wall', 'Playing racquetball', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSquash', 'HKWorkoutActivityType', 'Squash', 'racket_sports', 'wall', 'Playing squash', 'iOS 8.0+', true),
('HKWorkoutActivityTypeTableTennis', 'HKWorkoutActivityType', 'Table Tennis', 'racket_sports', 'table', 'Playing table tennis', 'iOS 8.0+', true),
('HKWorkoutActivityTypeTennis', 'HKWorkoutActivityType', 'Tennis', 'racket_sports', 'net', 'Playing tennis', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Outdoor Activities
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeClimbing', 'HKWorkoutActivityType', 'Climbing', 'outdoor', 'climbing', 'Rock climbing, bouldering', 'iOS 8.0+', true),
('HKWorkoutActivityTypeEquestrianSports', 'HKWorkoutActivityType', 'Equestrian Sports', 'outdoor', 'equestrian', 'Horse riding, polo, racing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeFishing', 'HKWorkoutActivityType', 'Fishing', 'outdoor', 'recreation', 'Fishing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeGolf', 'HKWorkoutActivityType', 'Golf', 'outdoor', 'precision', 'Playing golf', 'iOS 8.0+', true),
('HKWorkoutActivityTypeHiking', 'HKWorkoutActivityType', 'Hiking', 'outdoor', 'trail', 'Hiking', 'iOS 8.0+', true),
('HKWorkoutActivityTypeHunting', 'HKWorkoutActivityType', 'Hunting', 'outdoor', 'recreation', 'Hunting', 'iOS 8.0+', true),
('HKWorkoutActivityTypePlay', 'HKWorkoutActivityType', 'Play', 'outdoor', 'recreation', 'Tag, dodgeball, jungle gym', 'iOS 11.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Snow and Ice Sports
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeCrossCountrySkiing', 'HKWorkoutActivityType', 'Cross Country Skiing', 'snow_ice', 'skiing', 'Cross country skiing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeCurling', 'HKWorkoutActivityType', 'Curling', 'snow_ice', 'ice', 'Curling', 'iOS 8.0+', true),
('HKWorkoutActivityTypeDownhillSkiing', 'HKWorkoutActivityType', 'Downhill Skiing', 'snow_ice', 'skiing', 'Downhill/alpine skiing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSnowSports', 'HKWorkoutActivityType', 'Snow Sports', 'snow_ice', 'snow', 'Sledding, snowmobiling', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSnowboarding', 'HKWorkoutActivityType', 'Snowboarding', 'snow_ice', 'snow', 'Snowboarding', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSkatingSports', 'HKWorkoutActivityType', 'Skating Sports', 'snow_ice', 'skating', 'Ice skating, inline skating, skateboarding', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Water Activities
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypePaddleSports', 'HKWorkoutActivityType', 'Paddle Sports', 'water', 'paddle', 'Kayaking, canoeing, SUP', 'iOS 10.0+', true),
('HKWorkoutActivityTypeSailing', 'HKWorkoutActivityType', 'Sailing', 'water', 'sailing', 'Sailing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeSurfingSports', 'HKWorkoutActivityType', 'Surfing Sports', 'water', 'surfing', 'Surfing, kite surfing, wind surfing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeUnderwaterDiving', 'HKWorkoutActivityType', 'Underwater Diving', 'water', 'diving', 'Scuba diving, free diving', 'iOS 10.0+', true),
('HKWorkoutActivityTypeWaterPolo', 'HKWorkoutActivityType', 'Water Polo', 'water', 'team', 'Playing water polo', 'iOS 8.0+', true),
('HKWorkoutActivityTypeWaterSports', 'HKWorkoutActivityType', 'Water Sports', 'water', 'general', 'Water skiing, wake boarding', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Martial Arts
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeBoxing', 'HKWorkoutActivityType', 'Boxing', 'martial_arts', 'striking', 'Boxing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeKickboxing', 'HKWorkoutActivityType', 'Kickboxing', 'martial_arts', 'striking', 'Kickboxing', 'iOS 8.0+', true),
('HKWorkoutActivityTypeMartialArts', 'HKWorkoutActivityType', 'Martial Arts', 'martial_arts', 'general', 'General martial arts', 'iOS 8.0+', true),
('HKWorkoutActivityTypeTaiChi', 'HKWorkoutActivityType', 'Tai Chi', 'martial_arts', 'mindful', 'Tai chi', 'iOS 8.0+', true),
('HKWorkoutActivityTypeWrestling', 'HKWorkoutActivityType', 'Wrestling', 'martial_arts', 'grappling', 'Wrestling', 'iOS 8.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Multisport Activities
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeTransition', 'HKWorkoutActivityType', 'Transition', 'multisport', 'transition', 'Transition between activities', 'iOS 16.0+', true)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  subcategory = EXCLUDED.subcategory,
  description = EXCLUDED.description;

-- =====================================================
-- Deprecated Activity Types (mark as inactive)
-- =====================================================
INSERT INTO healthkit_mapping (healthkit_identifier, healthkit_type_name, display_name, category, subcategory, description, available_ios_version, is_active) VALUES
('HKWorkoutActivityTypeDance', 'HKWorkoutActivityType', 'Dance (Deprecated)', 'deprecated', NULL, 'Deprecated - use CardioDance or SocialDance', 'iOS 8.0+', false),
('HKWorkoutActivityTypeDanceInspiredTraining', 'HKWorkoutActivityType', 'Dance Inspired Training (Deprecated)', 'deprecated', NULL, 'Deprecated - use Barre or Pilates', 'iOS 8.0+', false),
('HKWorkoutActivityTypeMixedMetabolicCardioTraining', 'HKWorkoutActivityType', 'Mixed Metabolic Cardio (Deprecated)', 'deprecated', NULL, 'Deprecated - use MixedCardio', 'iOS 8.0+', false)
ON CONFLICT (healthkit_identifier) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  category = EXCLUDED.category,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;


COMMIT;
