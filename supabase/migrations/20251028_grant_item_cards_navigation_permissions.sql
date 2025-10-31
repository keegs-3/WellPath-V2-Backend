-- Grant permissions for patient_item_cards_with_navigation view

-- Grant SELECT to service_role (for Edge Functions)
GRANT SELECT ON patient_item_cards_with_navigation TO service_role;

-- Grant SELECT to authenticated users (for mobile app queries)
GRANT SELECT ON patient_item_cards_with_navigation TO authenticated;

-- Grant SELECT to anon (for unauthenticated access if needed)
GRANT SELECT ON patient_item_cards_with_navigation TO anon;

-- Create RLS policies for the base tables if not already present
-- (The view inherits these policies via security_invoker = on)

-- Verify that authenticated users can only see their own patient data
-- This is already handled by patient_item_scores_history RLS policies

-- Comments
COMMENT ON VIEW patient_item_cards_with_navigation IS
'Permissions: Authenticated users can SELECT their own patient data via inherited RLS policies from patient_item_scores_history';
