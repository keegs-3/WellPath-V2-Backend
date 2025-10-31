-- Create sectioned education tables for biomarkers and biometrics
-- Similar to wellpath_score_about structure

-- =====================================================
-- 1. CREATE BIOMARKERS EDUCATION SECTIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.biomarkers_education_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    biomarker_id UUID NOT NULL REFERENCES biomarkers_base(id) ON DELETE CASCADE,
    section_title TEXT NOT NULL,
    section_content TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_biomarkers_education_sections_biomarker
ON public.biomarkers_education_sections(biomarker_id, display_order)
WHERE is_active = true;

-- =====================================================
-- 2. CREATE BIOMETRICS EDUCATION SECTIONS TABLE
-- =====================================================

CREATE TABLE IF NOT EXISTS public.biometrics_education_sections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    biometric_id UUID NOT NULL REFERENCES biometrics_base(id) ON DELETE CASCADE,
    section_title TEXT NOT NULL,
    section_content TEXT NOT NULL,
    display_order INTEGER NOT NULL DEFAULT 1,
    is_active BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_biometrics_education_sections_biometric
ON public.biometrics_education_sections(biometric_id, display_order)
WHERE is_active = true;

-- =====================================================
-- 3. RLS POLICIES
-- =====================================================

ALTER TABLE public.biomarkers_education_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can read biomarker education sections"
ON public.biomarkers_education_sections
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Service role can manage biomarker education sections"
ON public.biomarkers_education_sections
FOR ALL
TO service_role
USING (true);

ALTER TABLE public.biometrics_education_sections ENABLE ROW LEVEL SECURITY;

CREATE POLICY "All users can read biometric education sections"
ON public.biometrics_education_sections
FOR SELECT
TO authenticated
USING (is_active = true);

CREATE POLICY "Service role can manage biometric education sections"
ON public.biometrics_education_sections
FOR ALL
TO service_role
USING (true);

-- =====================================================
-- 4. GRANTS
-- =====================================================

GRANT SELECT ON public.biomarkers_education_sections TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.biomarkers_education_sections TO service_role;

GRANT SELECT ON public.biometrics_education_sections TO authenticated, service_role;
GRANT INSERT, UPDATE, DELETE ON public.biometrics_education_sections TO service_role;

-- =====================================================
-- 5. COMMENTS
-- =====================================================

COMMENT ON TABLE public.biomarkers_education_sections IS
'Sectioned education content for biomarkers. Each biomarker has multiple education sections (Longevity Connection, Optimal Ranges, How to Optimize, etc.) for better mobile rendering.';

COMMENT ON TABLE public.biometrics_education_sections IS
'Sectioned education content for biometrics. Each biometric has multiple education sections for better mobile rendering.';

SELECT '✅ Created biomarkers_education_sections and biometrics_education_sections tables' as status;
