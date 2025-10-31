-- Create table for WellPath Score educational "About" content
-- This stores the static educational content that explains how scoring works

CREATE TABLE IF NOT EXISTS public.wellpath_score_about_content (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    section_number integer NOT NULL,
    section_title text NOT NULL,
    section_content text NOT NULL,
    display_order integer NOT NULL,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamp with time zone NOT NULL DEFAULT now(),
    updated_at timestamp with time zone NOT NULL DEFAULT now(),

    CONSTRAINT unique_section_number UNIQUE (section_number)
);

-- Create index
CREATE INDEX idx_wellpath_about_display_order ON public.wellpath_score_about_content(display_order) WHERE is_active = true;

-- RLS Policies
ALTER TABLE public.wellpath_score_about_content ENABLE ROW LEVEL SECURITY;

-- Anyone can read the about content (it's educational/public)
CREATE POLICY "Anyone can read about content"
ON public.wellpath_score_about_content
FOR SELECT
TO authenticated
USING (is_active = true);

-- Service role can manage content
CREATE POLICY "Service role can manage about content"
ON public.wellpath_score_about_content
FOR ALL
TO service_role
USING (true);

-- Grants
GRANT SELECT ON public.wellpath_score_about_content TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.wellpath_score_about_content TO service_role;

-- Insert the four sections
INSERT INTO public.wellpath_score_about_content (section_number, section_title, section_content, display_order) VALUES
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

-- Create a view for easy mobile app access
CREATE OR REPLACE VIEW public.wellpath_score_about_sections AS
SELECT
    section_number,
    section_title,
    section_content,
    display_order
FROM public.wellpath_score_about_content
WHERE is_active = true
ORDER BY display_order;

-- Grant access to view
GRANT SELECT ON public.wellpath_score_about_sections TO authenticated;
GRANT SELECT ON public.wellpath_score_about_sections TO service_role;

-- RLS for view
ALTER VIEW public.wellpath_score_about_sections SET (security_invoker = true);

SELECT '✅ Created WellPath Score about content with 4 sections' as status;
