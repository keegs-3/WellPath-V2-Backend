/**
 * Test script for calculate-wellpath-score Edge Function
 * Tests the updated function with normalized weights and category grouping
 */

const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = 'https://csotzmardnvrpdhlogjm.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNzb3R6bWFyZG52cnBkaGxvZ2ptIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTcyNzY0NTQyNywiZXhwIjoyMDQzMjIxNDI3fQ.WaYbRuLZUqF-jrF_RMC5_RlPQnfwUIr0PkUWsZOZFWs';

const supabase = createClient(supabaseUrl, supabaseKey);

async function testEdgeFunction() {
  console.log('🧪 Testing calculate-wellpath-score Edge Function\n');

  const testPatientId = '1758fa60-a306-440e-8ae6-9e68fd502bc2'; // Perfect test patient

  console.log(`Patient ID: ${testPatientId}\n`);
  console.log('Calling Edge Function...\n');

  try {
    const { data, error } = await supabase.functions.invoke('calculate-wellpath-score', {
      body: { patient_id: testPatientId }
    });

    if (error) {
      console.error('❌ Error:', error);
      return;
    }

    console.log('✅ Success!\n');
    console.log('📊 Overall Score:', data.overall_score?.toFixed(2));
    console.log('\n🎯 Pillar Scores:');

    for (const pillar of data.pillar_scores || []) {
      console.log(`\n  ${pillar.pillar_name}:`);
      console.log(`    Final Score: ${pillar.final_score.toFixed(2)}`);
      console.log(`    Markers: ${pillar.markers_score.toFixed(2)} / ${pillar.markers_max.toFixed(2)}`);
      console.log(`    Survey: ${pillar.survey_score.toFixed(2)} / ${pillar.survey_max.toFixed(2)}`);
      console.log(`    Education: ${pillar.education_score.toFixed(2)} / ${pillar.education_max.toFixed(2)}`);

      // Show a few sample scored items with categories
      if (pillar.scored_items && pillar.scored_items.length > 0) {
        console.log(`    Sample Scored Items (${pillar.scored_items.length} total):`);
        const samples = pillar.scored_items.slice(0, 3);
        for (const item of samples) {
          console.log(`      - ${item.item_name} (${item.item_type})`);
          console.log(`        Category: ${item.category || 'N/A'}`);
          console.log(`        Score: ${item.normalized_score.toFixed(3)}`);
          console.log(`        Weight: ${item.pillar_contributions[0].weight.toFixed(4)}`);
          console.log(`        Weighted Score: ${item.pillar_contributions[0].weighted_score.toFixed(4)}`);
        }
      }
    }

    // Check if categories are populated
    console.log('\n\n🔍 Category Check:');
    let totalItems = 0;
    let itemsWithCategory = 0;

    for (const pillar of data.pillar_scores || []) {
      if (pillar.scored_items) {
        for (const item of pillar.scored_items) {
          totalItems++;
          if (item.category) {
            itemsWithCategory++;
          }
        }
      }
    }

    console.log(`  Total scored items: ${totalItems}`);
    console.log(`  Items with category: ${itemsWithCategory}`);
    console.log(`  Category coverage: ${((itemsWithCategory / totalItems) * 100).toFixed(1)}%`);

    // Group biomarkers/biometrics by category
    console.log('\n\n📁 Biomarkers/Biometrics by Category:');
    const markersByCategory = new Map();

    for (const pillar of data.pillar_scores || []) {
      if (pillar.scored_items) {
        for (const item of pillar.scored_items) {
          if (item.item_type === 'biomarker' || item.item_type === 'biometric') {
            const category = item.category || 'Uncategorized';
            if (!markersByCategory.has(category)) {
              markersByCategory.set(category, []);
            }
            markersByCategory.get(category).push(item);
          }
        }
      }
    }

    for (const [category, items] of markersByCategory.entries()) {
      console.log(`\n  ${category} (${items.length} items):`);
      items.slice(0, 3).forEach(item => {
        console.log(`    - ${item.item_name}: ${(item.normalized_score * 100).toFixed(1)}%`);
      });
      if (items.length > 3) {
        console.log(`    ... and ${items.length - 3} more`);
      }
    }

    // Group survey questions by category
    console.log('\n\n📋 Survey Questions by Category:');
    const questionsByCategory = new Map();

    for (const pillar of data.pillar_scores || []) {
      if (pillar.scored_items) {
        for (const item of pillar.scored_items) {
          if (item.item_type === 'survey_question') {
            const category = item.category || 'Uncategorized';
            if (!questionsByCategory.has(category)) {
              questionsByCategory.set(category, []);
            }
            questionsByCategory.get(category).push(item);
          }
        }
      }
    }

    for (const [category, items] of questionsByCategory.entries()) {
      console.log(`\n  ${category} (${items.length} items):`);
      items.slice(0, 2).forEach(item => {
        console.log(`    - ${item.item_name}: ${(item.normalized_score * 100).toFixed(1)}%`);
      });
      if (items.length > 2) {
        console.log(`    ... and ${items.length - 2} more`);
      }
    }

  } catch (error) {
    console.error('❌ Exception:', error);
  }
}

testEdgeFunction();
