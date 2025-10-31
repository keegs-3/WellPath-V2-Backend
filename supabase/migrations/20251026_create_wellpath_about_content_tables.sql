-- Drop the incorrectly structured table
DROP VIEW IF EXISTS public.wellpath_score_about_sections;
DROP TABLE IF EXISTS public.wellpath_score_about_content CASCADE;

-- =====================================================
-- 1. WellPath Score About Content (Overall scoring explanation)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wellpath_score_about (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    section_number integer NOT NULL,
    section_title text NOT NULL,
    section_content text NOT NULL,
    display_order integer NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT unique_score_section_number UNIQUE (section_number)
);

CREATE INDEX idx_wellpath_score_about_order ON public.wellpath_score_about(display_order) WHERE is_active = true;

-- =====================================================
-- 2. WellPath Pillars About Content (Pillar-specific explanations)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wellpath_pillars_about (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pillar_id text NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,
    about_content text NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT unique_pillar_about UNIQUE (pillar_id)
);

-- =====================================================
-- 3. Pillar Markers About Content (Biomarkers/Biometrics component)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wellpath_pillars_markers_about (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pillar_id text NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,
    section_title text,
    about_content text NOT NULL,
    display_order integer NOT NULL DEFAULT 1,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX idx_pillars_markers_about_pillar ON public.wellpath_pillars_markers_about(pillar_id, display_order) WHERE is_active = true;

-- =====================================================
-- 4. Pillar Behaviors About Content (Behaviors component)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wellpath_pillars_behaviors_about (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pillar_id text NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,
    section_title text,
    about_content text NOT NULL,
    display_order integer NOT NULL DEFAULT 1,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX idx_pillars_behaviors_about_pillar ON public.wellpath_pillars_behaviors_about(pillar_id, display_order) WHERE is_active = true;

-- =====================================================
-- 5. Pillar Education About Content (Education component)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.wellpath_pillars_education_about (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    pillar_id text NOT NULL REFERENCES pillars_base(pillar_id) ON DELETE CASCADE,
    section_title text,
    about_content text NOT NULL,
    display_order integer NOT NULL DEFAULT 1,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX idx_pillars_education_about_pillar ON public.wellpath_pillars_education_about(pillar_id, display_order) WHERE is_active = true;

-- =====================================================
-- RLS Policies (all tables follow same pattern)
-- =====================================================

-- wellpath_score_about
ALTER TABLE public.wellpath_score_about ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read score about" ON public.wellpath_score_about FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role can manage score about" ON public.wellpath_score_about FOR ALL TO service_role USING (true);

-- wellpath_pillars_about
ALTER TABLE public.wellpath_pillars_about ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read pillars about" ON public.wellpath_pillars_about FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role can manage pillars about" ON public.wellpath_pillars_about FOR ALL TO service_role USING (true);

-- wellpath_pillars_markers_about
ALTER TABLE public.wellpath_pillars_markers_about ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read markers about" ON public.wellpath_pillars_markers_about FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role can manage markers about" ON public.wellpath_pillars_markers_about FOR ALL TO service_role USING (true);

-- wellpath_pillars_behaviors_about
ALTER TABLE public.wellpath_pillars_behaviors_about ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read behaviors about" ON public.wellpath_pillars_behaviors_about FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role can manage behaviors about" ON public.wellpath_pillars_behaviors_about FOR ALL TO service_role USING (true);

-- wellpath_pillars_education_about
ALTER TABLE public.wellpath_pillars_education_about ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can read education about" ON public.wellpath_pillars_education_about FOR SELECT TO authenticated USING (is_active = true);
CREATE POLICY "Service role can manage education about" ON public.wellpath_pillars_education_about FOR ALL TO service_role USING (true);

-- =====================================================
-- Grants
-- =====================================================
GRANT SELECT ON public.wellpath_score_about TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.wellpath_score_about TO service_role;

GRANT SELECT ON public.wellpath_pillars_about TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.wellpath_pillars_about TO service_role;

GRANT SELECT ON public.wellpath_pillars_markers_about TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.wellpath_pillars_markers_about TO service_role;

GRANT SELECT ON public.wellpath_pillars_behaviors_about TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.wellpath_pillars_behaviors_about TO service_role;

GRANT SELECT ON public.wellpath_pillars_education_about TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.wellpath_pillars_education_about TO service_role;

-- =====================================================
-- Insert WellPath Score About Content
-- =====================================================
INSERT INTO public.wellpath_score_about (section_number, section_title, section_content, display_order) VALUES
(1, 'What Is Your WellPath Score?',
'Your WellPath Score is a comprehensive measure of your health across seven interconnected pillars of longevity and wellness. Each pillar is scored from 0 to 100 based on your biomarkers, behaviors, and engagement with educational content. Your overall score reflects how these seven pillars combine to paint a complete picture of your health.

Rather than focusing on treating disease, your WellPath Score emphasizes optimization. It shows not just where you are today, but where you have the greatest opportunity to improve your healthspan and longevity.',
1),

(2, 'How Each Pillar Is Scored',
'While each pillar contributes equally to your overall score, within each pillar the scoring is more nuanced:

Three Components per Pillar:
• Biomarkers & Biometrics: Objective laboratory values and measurements (weight varies by pillar)
• Behaviors & Self-Assessment: Your habits, actions, and self-reported experiences (weight varies by pillar)
• Education Engagement: Your completion of evidence-based learning modules (10% for all pillars)

Why Component Weights Differ: Each pillar uses a measurement-validity approach. Pillars with strong objective biomarkers (like Healthful Nutrition with 72% biomarkers) lean more heavily on lab values. Pillars that depend on subjective experience (like Stress Management with 63% behaviors) emphasize self-assessment. This ensures we''re measuring what matters most in each health domain.',
2),

(3, 'Understanding Your Opportunities',
'Your WellPath Score isn''t just a number, it''s a roadmap for improvement. The score identifies:

Where You Stand: Each pillar score shows your current health status in that domain relative to optimal ranges.

Where You Can Improve Most: Lower-scoring pillars represent your greatest opportunities for health gains. Improving from a score of 30 to 60 in Sleep has far more impact on your longevity than improving from 85 to 95 in Nutrition.

What Actions to Take: Your physician uses your pillar scores to prioritize recommendations. The system identifies which interventions will have the greatest impact based on your individual biomarkers and behaviors, not generic health advice.

Progress Over Time: As you implement recommendations and track your metrics, you''ll see how your pillar scores change, providing motivation and validation that your efforts are working.',
3),

(4, 'Why Equal Weighting?',
'Each of the seven pillars contributes equally (1/7th) to your overall WellPath Score. This equal weighting approach is intentional and evidence-based:

Holistic Health Integration: Research from Blue Zone populations (regions where people live the longest, healthiest lives) shows that healthy behaviors cluster together. People who optimize their nutrition also tend to prioritize sleep, exercise, and social connections. Health isn''t about perfecting one area while neglecting others, it''s about balanced attention across all domains.

Avoiding False Hierarchies: While it might be tempting to weight nutrition more heavily than social connection, or exercise more than stress management, doing so would suggest some aspects of health "don''t matter as much." The reality is that all seven pillars are critical to longevity outcomes. Poor sleep can undermine perfect nutrition. Chronic stress can negate exercise benefits. Social isolation increases mortality risk as much as smoking.

Measurement Fairness: Different health domains have different measurement capabilities. For example, nutrition has 67 objective biomarkers we can measure, while social connection has only 4. Equal pillar weighting prevents our scoring system from being biased toward areas that are simply easier to measure with blood tests.',
4);

SELECT '✅ Created WellPath about content tables with hierarchical structure' as status;
