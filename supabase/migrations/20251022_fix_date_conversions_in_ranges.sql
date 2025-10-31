-- =====================================================================================
-- FIX DATE CONVERSIONS IN RANGE DISPLAYS
-- =====================================================================================
-- Excel/CSV imports converted numeric ranges like "10-11" to dates like "Oct-11"
-- This migration fixes all instances in biomarkers_detail and biometrics_detail
-- =====================================================================================

-- Fix biomarkers_detail
UPDATE biomarkers_detail
SET frontend_display = CASE
    -- Pattern: "##-Oct" → "10-##"
    WHEN frontend_display ~ '^[0-9]+-Oct$' THEN
        '10-' || substring(frontend_display from '^([0-9]+)')
    -- Pattern: "Oct-##" → "10-##"
    WHEN frontend_display ~ '^Oct-[0-9]+$' THEN
        '10-' || substring(frontend_display from '-([0-9]+)$')
    -- Pattern: "##-Nov" → "11-##"
    WHEN frontend_display ~ '^[0-9]+-Nov$' THEN
        '11-' || substring(frontend_display from '^([0-9]+)')
    -- Pattern: "Nov-##" → "11-##"
    WHEN frontend_display ~ '^Nov-[0-9]+$' THEN
        '11-' || substring(frontend_display from '-([0-9]+)$')
    -- Pattern: "##-Dec" → "12-##"
    WHEN frontend_display ~ '^[0-9]+-Dec$' THEN
        '12-' || substring(frontend_display from '^([0-9]+)')
    -- Pattern: "Dec-##" → "12-##"
    WHEN frontend_display ~ '^Dec-[0-9]+$' THEN
        '12-' || substring(frontend_display from '-([0-9]+)$')
    ELSE frontend_display
END
WHERE frontend_display LIKE '%Oct%'
   OR frontend_display LIKE '%Nov%'
   OR frontend_display LIKE '%Dec%';

-- Fix biometrics_detail
UPDATE biometrics_detail
SET frontend_display_specific = CASE
    -- Pattern: "##-Oct" → "10-##"
    WHEN frontend_display_specific ~ '^[0-9]+-Oct$' THEN
        '10-' || substring(frontend_display_specific from '^([0-9]+)')
    -- Pattern: "Oct-##" → "10-##"
    WHEN frontend_display_specific ~ '^Oct-[0-9]+$' THEN
        '10-' || substring(frontend_display_specific from '-([0-9]+)$')
    -- Pattern: "##-Nov" → "11-##"
    WHEN frontend_display_specific ~ '^[0-9]+-Nov$' THEN
        '11-' || substring(frontend_display_specific from '^([0-9]+)')
    -- Pattern: "Nov-##" → "11-##"
    WHEN frontend_display_specific ~ '^Nov-[0-9]+$' THEN
        '11-' || substring(frontend_display_specific from '-([0-9]+)$')
    -- Pattern: "##-Dec" → "12-##"
    WHEN frontend_display_specific ~ '^[0-9]+-Dec$' THEN
        '12-' || substring(frontend_display_specific from '^([0-9]+)')
    -- Pattern: "Dec-##" → "12-##"
    WHEN frontend_display_specific ~ '^Dec-[0-9]+$' THEN
        '12-' || substring(frontend_display_specific from '-([0-9]+)$')
    ELSE frontend_display_specific
END
WHERE frontend_display_specific LIKE '%Oct%'
   OR frontend_display_specific LIKE '%Nov%'
   OR frontend_display_specific LIKE '%Dec%';

-- Verify the fixes
SELECT
    'biomarkers_detail' as table_name,
    biomarker,
    range_name,
    frontend_display as fixed_display
FROM biomarkers_detail
WHERE biomarker IN ('ALT', 'BUN', 'Estradiol', 'Ferritin', 'GGT', 'SHBG')
ORDER BY biomarker, range_name

UNION ALL

SELECT
    'biometrics_detail' as table_name,
    biometric,
    range_name,
    frontend_display_specific as fixed_display
FROM biometrics_detail
WHERE biometric = 'Visceral Fat' AND range_name = 'Elevated'
ORDER BY biometric, range_name;
