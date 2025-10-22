# WellPath Application Workflow

## Complete User Journey: From Practice Setup to WellPath Score

---

## Phase 1: Practice & Team Setup

### 1.1 Initial Practice Creation
**Trigger**: New practice signs up

**Initial Admin User Created**:
- First Name
- Last Name
- Email Address
- Phone Number
- Password
- Role: Admin or Clinician
- Specialty

### 1.2 Practice Configuration
**Practice Details**:
- Practice Name
- Practice Address
- City, State, Zip Code
- Time Zone
- Primary Specialties

### 1.3 Team Member Management
**Additional team members can be added**:
- Roles available: Clinician, Nurse, Admin
- **Requirement**: At least 1 Clinician must be in the practice to add patients

**Database State**: Practice UUID + Admin UUID + Clinician UUID(s) created

---

## Phase 2: Patient Onboarding

### 2.1 Patient Registration
**Clinician adds patient with**:
- Patient ID
- Biological Sex (Male, Female)
- First Name, Last Name
- Email, Phone Number
- Date of Birth (MM/DD/YYYY)
- Assigned Clinician (dropdown from practice clinicians)

**Database State**: Patient UUID created and linked to clinician

### 2.2 Patient Account Activation
1. Patient receives welcome email with sign-in OTP
2. Patient sets password
3. Patient signs into mobile app

### 2.3 Initial App Access (Limited)
**Patient has access to**:
- Survey/Questionnaire
- Account Details
- Education

**Patient DOES NOT have access to**:
- Dashboard
- Metrics
- WellPath Score
- Challenges

---

## Phase 3: Data Collection

### 3.1 Patient Survey
- Patient works through questionnaire
- **Question count**: 200-300 questions (depending on conditional logic)
- Clinician can view progress but **CANNOT edit**

### 3.2 Clinical Data Entry
**Clinician enters**:
- **60 biomarkers** (lab results)
- **16 biometrics** (measurements)

### 3.3 Data Collection Complete Gate
**All data must be present**:
- ✅ 60 biomarkers
- ✅ 16 biometrics
- ✅ 200-300 survey responses (depending on conditional filling)

**Only when complete**: Clinician can generate recommendations

---

## Phase 4: Recommendation Generation

### 4.1 AI-Powered Recommendation Matching
**Process**:
1. Patient data exposed to OpenAI
2. Custom model matches patient to ~300 available recommendations
3. Returns top recommendations per pillar

### 4.2 Recommendation Selection
**Selection Criteria**:
- **20 total recommendations** presented
- **2 from each pillar** (7 pillars × 2 = 14 recommendations)
- **6 additional** highest-scoring matches across all pillars

**Selection Process** (Clinician Web App only):
- Clinician and patient review together
- Select recommendations to push
- Choose recommendation level for each
- Confirm selection

### 4.3 Recommendation Deployment
**Once confirmed**: Recommendations pushed to patient mobile app for tracking

---

## Phase 5: Full App Access & Tracking

### 5.1 Patient App - Full Access Unlocked
After recommendations are pushed, patient gains access to:

#### **Dashboard (Home)**
- Main widget: Daily goal progress
- Recommendation tracking
- Sub-pages: 1 page per pillar
  - Recommendations bucketed by primary mapped pillar

#### **Metrics Page**
- Charts for biomarkers
- Charts for biometrics
- Visualizations for tracked data

#### **Challenges**
- [To be discussed - future feature]

#### **Add Tracked Metrics**
- Route to ALL display_metrics/display_screens
- Based on new display architecture schema

#### **WellPath Score Widget** (Home page)
- Shows overall WellPath Score percentage
- Click widget → Modal with scores by pillar
- Click pillar → Opens WellPath Score Detail Screen

---

## Phase 6: WellPath Score Detail Screen

### 6.1 Current Implementation (Needs Rebuild)

**Current Structure** (Paginated):
1. **Biomarkers Tab**
2. **Biometrics Tab**
3. **Questionnaire Tab**
4. **Education Tab**

**Current Display Format**:
Each item shown in a "pill" container with:

#### Biomarkers & Biometrics:
- Marker/Metric name
- Patient's value
- Small info tooltip with:
  - Normalized score
  - Max score
- **Color coding**:
  - 🔴 Red: 0-33% of max
  - 🟡 Yellow: 34-66% of max
  - 🟢 Green: 67-100% of max

#### Questionnaire:
- Question text
- Patient's response
- Score (same color coding as above)

#### Education:
- Article title
- Completion status: "Yes" or "No"
- Score (if applicable)

### 6.2 What Needs to Be Built

**Problem**: Current dev implementation doesn't calculate individual component scores correctly

**Solution**: Build proper WellPath Score Detail views using:
- Survey hierarchy (sections → categories → groups → questions)
- Proper score aggregation
- Component breakdown (Biomarkers, Biometrics, Behaviors/Survey, Education)
- Rollup views showing scores at each level

---

## Application Flow Summary

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Admin User Created                                        │
│    └─> Practice Created                                      │
│        └─> Clinician Added (if admin is not clinician)      │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. Patient Created                                           │
│    └─> Linked to Clinician                                  │
│    └─> Limited app access granted                           │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. Data Collection                                           │
│    ├─> Patient completes questionnaire (200-300 questions)  │
│    ├─> Clinician enters biomarkers (60)                     │
│    └─> Clinician enters biometrics (16)                     │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. Recommendations Generated                                 │
│    └─> First accurate WellPath Score calculation possible   │
│        (Note: Education component not yet included)          │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. Recommendations Pushed to App                             │
│    └─> Full app access unlocked                             │
└────────────────────────┬────────────────────────────────────┘
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. Patient Uses Full App                                     │
│    ├─> Dashboard: Daily goals + pillar sub-pages            │
│    ├─> Metrics: Biomarker/biometric charts                  │
│    ├─> Challenges: [Future]                                 │
│    ├─> Add Tracked Metrics: All display_metrics/screens     │
│    └─> WellPath Score Widget                                │
│        └─> Click → Modal with pillar scores                 │
│            └─> Click pillar → Detail screen                 │
│                └─> THIS IS WHAT WE NEED TO BUILD            │
└─────────────────────────────────────────────────────────────┘
```

---

## Key Gates & Dependencies

### Gate 1: Practice Setup Complete
**Requirements**:
- ✅ Practice created
- ✅ At least 1 Clinician in practice

**Unlocks**: Ability to add patients

### Gate 2: Data Collection Complete
**Requirements**:
- ✅ 60 biomarkers entered
- ✅ 16 biometrics entered
- ✅ 200-300 survey questions answered

**Unlocks**: Ability to generate recommendations

### Gate 3: Recommendations Pushed
**Requirements**:
- ✅ Recommendations generated
- ✅ Clinician + patient selected 20 recommendations
- ✅ Recommendations confirmed and pushed

**Unlocks**:
- Full app access
- Dashboard tracking
- Metrics visualization
- WellPath Score display

---

## Current Focus: WellPath Score Detail Screen

### Problem Statement
The current implementation:
- ❌ Doesn't calculate individual component scores correctly
- ❌ Basic pill UI that doesn't leverage our data architecture
- ❌ No proper hierarchy/rollup views
- ❌ Missing aggregation by categories and groups

### Solution Requirements
Build proper WellPath Score Detail screens that:
- ✅ Use survey hierarchy (sections → categories → groups → questions)
- ✅ Calculate component scores correctly:
  - Biomarkers (72% weight)
  - Biometrics (varies by pillar)
  - Behaviors/Survey (18% weight)
  - Education (10% weight)
- ✅ Show rollup views at each hierarchy level
- ✅ Display patient values, scores, and context (tips, longevity impact)
- ✅ Color-code by performance (red/yellow/green)
- ✅ Allow drill-down from pillar → component → subsection → individual items

---

## Database State at Each Phase

| Phase | Patient Data | Access Level | Features Available |
|-------|-------------|--------------|-------------------|
| **Phase 2** | UUID only | Limited | Survey, Account, Education |
| **Phase 3** | Partial data | Limited | Survey (in progress) |
| **Phase 4** | Complete data | Limited | Survey (completed) |
| **Phase 5** | Complete + Recs | Full | All features unlocked |
| **Phase 6** | Complete + Recs | Full | Tracking + scoring active |

---

## Notes

- **First WellPath Score Calculation**: Happens at recommendation generation (after all biomarkers, biometrics, and survey data collected)
- **Education Component**: Not included in initial score calculation (recommendations phase)
- **Score Updates**: Will recalculate as patient completes education articles and tracks metrics
- **Clinician-Patient Collaboration**: Recommendation selection must happen together via clinician web app
- **Conditional Survey Logic**: Question count varies (200-300) based on patient responses triggering conditional branches

---

**Document Version**: 1.0
**Last Updated**: 2025-10-17
**Status**: Complete workflow documented - Ready to build WellPath Score Detail screens
