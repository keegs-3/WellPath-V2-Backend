#!/bin/bash

# Test the calculate-wellpath-score Edge Function
# Usage: ./test_edge_function.sh

SERVICE_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1OTMyNDgxMSwiZXhwIjoyMDc0OTAwODExfQ.X1belKzZ6vBmAh4K9-kS0x5DcWiRFp6lnFPPFA28Rxk"
PATIENT_ID="1758fa60-a306-440e-8ae6-9e68fd502bc2"

echo "Testing Edge Function at $(date +%H:%M:%S)..."
echo ""

curl -s https://csotzmardnvrpdhlogjm.supabase.co/functions/v1/calculate-wellpath-score \
  -H "Authorization: Bearer $SERVICE_KEY" \
  -H "Content-Type: application/json" \
  -d "{\"patient_id\":\"$PATIENT_ID\"}" | python3 -m json.tool

echo ""
echo "✅ Check Supabase logs at:"
echo "https://supabase.com/dashboard/project/csotzmardnvrpdhlogjm/functions/calculate-wellpath-score/logs"
