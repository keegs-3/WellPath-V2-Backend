const https = require('https');

const data = JSON.stringify({
  patient_id: '1758fa60-a306-440e-8ae6-9e68fd502bc2'
});

const options = {
  hostname: 'csotzmardnvrpdhlogjm.supabase.co',
  port: 443,
  path: '/functions/v1/calculate-wellpath-score',
  method: 'POST',
  headers: {
    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzY0NTQyNywiZXhwIjoyMDQzMjIxNDI3fQ.WaYbRuLZUqF-jrF_RMC5_RlPQnfwUIr0PkUWsZOZFWs',
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = https.request(options, (res) => {
  let responseData = '';

  res.on('data', (chunk) => {
    responseData += chunk;
  });

  res.on('end', () => {
    console.log('Status Code:', res.statusCode);
    console.log('Response:');
    const parsed = JSON.parse(responseData);
    console.log(JSON.stringify(parsed, null, 2));
  });
});

req.on('error', (error) => {
  console.error('Error:', error);
});

req.write(data);
req.end();
