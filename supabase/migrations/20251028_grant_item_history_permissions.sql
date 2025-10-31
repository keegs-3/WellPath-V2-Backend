-- Grant permissions to service_role for patient_item_scores_history table
-- The RLS policy allows access, but we also need table-level grants

-- Grant all permissions to service_role
GRANT ALL ON TABLE patient_item_scores_history TO service_role;

-- Grant all permissions to postgres (superuser)
GRANT ALL ON TABLE patient_item_scores_history TO postgres;

-- Grant authenticated users SELECT only (can view their own via RLS)
GRANT SELECT ON TABLE patient_item_scores_history TO authenticated;

-- Grant anon users SELECT only (RLS will restrict to their rows)
GRANT SELECT ON TABLE patient_item_scores_history TO anon;

COMMENT ON TABLE patient_item_scores_history IS
'Historical tracking of individual item scores. Service role has full access for edge function inserts. Authenticated users can view their own records via RLS.';
