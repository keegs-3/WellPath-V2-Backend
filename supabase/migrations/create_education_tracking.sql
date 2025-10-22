-- Education Content Tracking Tables
-- Tracks patient engagement with educational articles for the education score component

-- Table: education_articles
-- Stores the catalog of available educational articles (4 per pillar = 28 total)
CREATE TABLE IF NOT EXISTS education_articles (
    id TEXT PRIMARY KEY,  -- e.g., "cognitive-health-sleep-quality"
    pillar TEXT NOT NULL,  -- e.g., "Cognitive Health", "Movement + Exercise", etc.
    title TEXT NOT NULL,
    description TEXT,
    content_url TEXT,  -- URL or path to article content
    min_engagement_seconds INTEGER DEFAULT 30,  -- Minimum time to count as "viewed"
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster pillar lookups
CREATE INDEX IF NOT EXISTS idx_education_articles_pillar ON education_articles(pillar);

-- Table: education_engagement
-- Tracks when patients view/engage with educational articles
CREATE TABLE IF NOT EXISTS education_engagement (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    patient_id UUID NOT NULL REFERENCES patient_details(id) ON DELETE CASCADE,
    article_id TEXT NOT NULL REFERENCES education_articles(id) ON DELETE CASCADE,
    pillar TEXT NOT NULL,  -- Denormalized for faster queries
    viewed_at TIMESTAMP DEFAULT NOW(),
    time_spent_seconds INTEGER DEFAULT 0,
    scroll_percentage INTEGER DEFAULT 0,  -- 0-100, how far they scrolled
    completed BOOLEAN DEFAULT FALSE,  -- True if scroll_percentage >= 80
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(patient_id, article_id)  -- Each patient can only view each article once
);

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_education_engagement_patient ON education_engagement(patient_id);
CREATE INDEX IF NOT EXISTS idx_education_engagement_pillar ON education_engagement(pillar);
CREATE INDEX IF NOT EXISTS idx_education_engagement_patient_pillar ON education_engagement(patient_id, pillar);

-- Insert the 28 core education articles (4 per pillar)
INSERT INTO education_articles (id, pillar, title, description) VALUES
-- Cognitive Health
('cognitive-health-sleep-quality', 'Cognitive Health', 'How Sleep Impacts Cognitive Function', 'Learn about the crucial connection between quality sleep and brain health'),
('cognitive-health-brain-training', 'Cognitive Health', 'Brain Training Exercises That Work', 'Evidence-based cognitive exercises to maintain mental sharpness'),
('cognitive-health-nutrition', 'Cognitive Health', 'Foods That Boost Brain Power', 'Nutritional strategies to support cognitive function'),
('cognitive-health-lifelong-learning', 'Cognitive Health', 'The Power of Lifelong Learning', 'How continuous learning keeps your mind sharp'),

-- Connection + Purpose
('connection-social-bonds', 'Connection + Purpose', 'Building Meaningful Social Connections', 'The health benefits of strong relationships'),
('connection-purpose-finding', 'Connection + Purpose', 'Finding Your Life Purpose', 'Strategies to discover and live your purpose'),
('connection-community', 'Connection + Purpose', 'The Power of Community Engagement', 'How community involvement enhances wellbeing'),
('connection-relationships', 'Connection + Purpose', 'Nurturing Deep Relationships', 'Building and maintaining strong bonds'),

-- Core Care
('core-care-preventive', 'Core Care', 'The Importance of Preventive Care', 'Why regular screenings and check-ups matter'),
('core-care-medications', 'Core Care', 'Managing Medications Safely', 'Best practices for medication adherence'),
('core-care-substance', 'Core Care', 'Understanding Substance Use and Health', 'The impact of alcohol and tobacco on wellness'),
('core-care-screenings', 'Core Care', 'Age-Appropriate Health Screenings', 'What screenings you need and when'),

-- Healthful Nutrition
('nutrition-whole-foods', 'Healthful Nutrition', 'The Power of Whole Foods', 'Building a diet based on minimally processed foods'),
('nutrition-plant-based', 'Healthful Nutrition', 'Plant-Based Eating Benefits', 'How plants support optimal health'),
('nutrition-meal-planning', 'Healthful Nutrition', 'Effective Meal Planning Strategies', 'Planning for nutritional success'),
('nutrition-mindful-eating', 'Healthful Nutrition', 'Mindful Eating Practices', 'Developing a healthy relationship with food'),

-- Movement + Exercise
('movement-cardio-benefits', 'Movement + Exercise', 'Cardiovascular Exercise Essentials', 'Building a strong heart and healthy circulation'),
('movement-strength-training', 'Movement + Exercise', 'Strength Training for All Ages', 'Why resistance exercise is crucial'),
('movement-flexibility', 'Movement + Exercise', 'Flexibility and Mobility Work', 'Maintaining range of motion and preventing injury'),
('movement-daily-activity', 'Movement + Exercise', 'The Power of Daily Movement', 'Incorporating activity into your routine'),

-- Restorative Sleep
('sleep-hygiene-basics', 'Restorative Sleep', 'Sleep Hygiene Fundamentals', 'Creating the ideal sleep environment'),
('sleep-circadian-rhythm', 'Restorative Sleep', 'Understanding Your Circadian Rhythm', 'Optimizing your natural sleep-wake cycle'),
('sleep-disorders', 'Restorative Sleep', 'Common Sleep Disorders and Solutions', 'Identifying and addressing sleep issues'),
('sleep-recovery', 'Restorative Sleep', 'Sleep and Physical Recovery', 'How sleep repairs your body'),

-- Stress Management
('stress-mindfulness', 'Stress Management', 'Mindfulness and Meditation Basics', 'Starting a meditation practice'),
('stress-breathing', 'Stress Management', 'Breathwork for Stress Relief', 'Breathing techniques to calm the nervous system'),
('stress-resilience', 'Stress Management', 'Building Stress Resilience', 'Developing coping strategies for life challenges'),
('stress-time-management', 'Stress Management', 'Effective Time and Energy Management', 'Reducing stress through better organization')
ON CONFLICT (id) DO NOTHING;

-- Comments for documentation
COMMENT ON TABLE education_articles IS 'Catalog of educational articles, 4 per pillar for 10% education score component';
COMMENT ON TABLE education_engagement IS 'Tracks patient engagement with articles. Each viewed article = 2.5% (max 10% per pillar)';
COMMENT ON COLUMN education_engagement.completed IS 'True if patient scrolled >= 80% or spent >= min_engagement_seconds';
