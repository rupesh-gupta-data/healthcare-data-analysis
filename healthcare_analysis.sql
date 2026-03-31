-- ============================================================
-- PROJECT   : Healthcare Patient Analytics
-- AUTHOR    : Rupesh Gupta
-- DATASET   : 54,966 real Kaggle records
-- TOOLS     : PostgreSQL
-- DATE      : March 2026
-- ============================================================

DROP TABLE IF EXISTS healthcare;

CREATE TABLE healthcare (
    name VARCHAR(100),
    age INT,
    gender VARCHAR(10),
    blood_type VARCHAR(5),
    medical_condition VARCHAR(50),
    admission_date DATE,
    doctor VARCHAR(100),
    hospital VARCHAR(100),
    insurance_provider VARCHAR(50),
    billing_amount NUMERIC(10,2),
    room_number INT,
    admission_type VARCHAR(20),
    discharge_date DATE,
    medication VARCHAR(50),
    test_results VARCHAR(20)
);

-- ============================================================
-- SECTION 1: DATA QUALITY AUDIT
-- ============================================================

-- Q1: Check total rows
select count (*) from healthcare ;


-- Q2: Check missing values in key columns

select 
    count (*) FILTER (WHERE name is NULL) AS missing_name ,
    count (*) FILTER (WHERE billing_amount is NULL) AS missing_amount
	FROM healthcare ;
	
-- Q3: Check negative billing values

select count (*)
from healthcare
where billing_amount < 0 ;


-- Q4: Check if any discharge date is before admission date

select count (*)
from healthcare
where discharge_date < admission_date ;

/* Section 1 Findings:
- Total rows    = 54966
- Missing values =  no missing value
- Negative billing = 106 records
- Invalid dates  =  no invalid dates 
*/

-- ============================================================
-- SECTION 2: DATA CLEANING
-- ============================================================

-- Q5: Create clean view with ABS billing + stay days calculated

drop view if exists clean_healthcare 

Create view clean_healthcare As
  Select * ,
  ABS(billing_amount) as clean_amount ,
   (discharge_date - admission_date) as Days_stays
  from healthcare ;

select clean_amount, Days_stays 
From clean_healthcare;
/* Cleaning Log:
- 106 negative billing values found (38 Urgent, 36 Elective, 32 Emergency) 
spread randomly across all hospitals and age groups.
--No systematic pattern detected.
Treated using ABS() function.
- Stay days calculated from discharge - admission dates
- Original data preserved in healthcare table */

-- ============================================================
-- SECTION 3: BILLING ANALYSIS
-- ============================================================

-- Q6: Avg billing by admission type (Emergency vs Elective vs Urgent)

Select admission_type , 
 round(Avg(clean_amount),2) as avg_amounts
FROM clean_healthcare
group by admission_type
order by avg_amounts ;

/* Q6 Key Insights:
- Elective = highest avg billing (₹25,614)
- Emergency = lowest avg billing (₹25,506)
- Gap between all 3 types = only ₹108 = pricing is uniform
- Insurance companies charge similar regardless of admission urgency
- Recommendation: Investigate why Emergency costs same as Elective
  — Emergency should typically cost more due to immediate resources used */

-- Q7: Top 3 most expensive medical conditions

select medical_condition , 
 round(Avg(clean_amount),2) as avg_amounts
from clean_healthcare
group by medical_condition
order by avg_amounts desc
limit 3 ;

/* Q7 Key Insights:
- Obesity = most expensive (₹25,806) = root cause condition
- Diabetes & Asthma follow = likely obesity-linked conditions
- Gap between top 3 = only ₹171 = no major billing difference
- Obesity → Diabetes → Asthma = chain of lifestyle diseases
- Recommendation: Prevention programs targeting obesity can
  reduce all 3 conditions simultaneously = major cost saving */
  
-- Q8: Which insurance provider covers highest avg billing?

select insurance_provider ,
  count (*) as patients_counts,
  round(avg(clean_amount),2) as avg_amounts
FROM clean_healthcare
group by insurance_provider
order by avg_amounts desc ;
                                 --  subquery (finding gap)
SELECT 
    MAX(avg_bill) AS highest_bill,
    MIN(avg_bill) AS lowest_bill,
    MAX(avg_bill) - MIN(avg_bill) AS gap
FROM (
    SELECT insurance_provider,
       count (*) as patients_counts,   
	   ROUND(AVG(clean_amount), 2) AS avg_bill
    FROM clean_healthcare
    GROUP BY insurance_provider
) AS provider_summary;

/* Q8 Key Insights:
- Medicare = highest avg billing covered (₹25,630)
- UnitedHealthcare = lowest avg billing covered (₹25,415)
- Gap = only ₹215 = all providers cover almost equally
- Cigna has most patients (11,139) but not highest billing
- Recommendation: Patients should choose provider based on
  specific condition coverage not just avg billing */

-- ============================================================
-- SECTION 4: PATIENT DEMOGRAPHICS
-- ============================================================

-- Q9: Age group with most admissions using CASE WHEN
-- Groups: Senior (>50), Adult (30-50), Young (<30)

select 
  case
   when age > 50 then 'Senior'
   when age BETWEEN 30 AND 50 then 'Adult'
   ELSE 'Young'
End as age_groups ,
count (*) as patient_count
FROM  clean_healthcare 
group by age_groups
order by patient_count desc;

/* Q9 Key Insights:
- Senior (50+) = 28,394 = 51% of admissions = lifestyle diseases dominate
- Adult (30-50) = 16,967 = 31% = working age facing health pressure
- Young (<30) = 9,605 = 18% = alarming for a young population
- Senior conditions = Obesity, Diabetes, Asthma = all preventable
- Youth admissions linked to malnutrition + environmental pollution
- Recommendation:
  1. Increase government budget for child nutrition programs
  2. Strict monitoring of companies on industrial waste disposal
  3. Senior prevention camps for obesity and diabetes
  4. Corporate wellness programs for working adults */

  
-- Q10: Gender breakdown of patients

select gender,
count (*) as patients_counts
from clean_healthcare
group by gender 
order by patients_counts ;

/* Q10 Key Insights:
- Male = 27,496 vs Female = 27,470 = gap of only 26 patients
- India population = more males than females
- Equal admissions = proportionally MORE females are sick
- Housewives = sedentary lifestyle = less physical activity = higher disease risk
- Working women face dual burden = office stress + household work
- Recommendation:
  1. Launch women-specific health awareness programs
  2. Promote daily physical activity for housewives
  3. Free health checkup camps targeting women in rural areas
  4. Corporate policies for women's wellness leave */

-- Q11: Most common medical condition per age group

SELECT medical_condition ,
  CASE 
   when age > 50 then 'Senior'
   when age BETWEEN 30 AND 50 then 'Adult'
   ELSE 'Young'
End as age_groups ,
count (*) as patient_count
FROM  clean_healthcare 
group by age_groups , medical_condition
order by age_groups , patient_count desc;

/* Q11 Key Insights:
- Seniors (50+): Diabetes, Hypertension, Arthritis equally dominant (4,763 each)
- Young (<30): Obesity #1 = early lifestyle disease onset is alarming
- Obesity appears in ALL 3 age groups = national health crisis
- Obesity → Diabetes → Asthma chain starts from youth itself
- Recommendation:
  1. Mandatory protein + strength training programs in schools
  2. Senior care focused on diabetes + hypertension management
  3. Government nutrition monitoring for children under 18 */

-- ============================================================
-- SECTION 5: HOSPITAL PERFORMANCE
-- ============================================================

-- Q12: Top 5 most expensive hospitals vs top 5 cheapest

-- Top 5 most expensive hospitals
SELECT hospital,
       ROUND(AVG(clean_amount), 2) AS avg_billing
FROM clean_healthcare
GROUP BY hospital
ORDER BY avg_billing DESC
LIMIT 5;

-- Top 5 cheapest hospitals
SELECT hospital,
       ROUND(AVG(clean_amount), 2) AS avg_billing
FROM clean_healthcare
GROUP BY hospital
ORDER BY avg_billing ASC
LIMIT 5;

-- Gap between most expensive and cheapest

SELECT
    MAX(avg_billing) AS most_expensive,
    MIN(avg_billing) AS cheapest,
    MAX(avg_billing) - MIN(avg_billing) AS gap
FROM (
    SELECT hospital,
           ROUND(AVG(clean_amount), 2) AS avg_billing
    FROM clean_healthcare
    GROUP BY hospital) AS hospital_summary;
                                               
SELECT hospital,
   ROUND(AVG(clean_amount), 2) AS avg_billing,
 COUNT(*) AS total_records,
 MIN(clean_amount) AS min_bill,
 MAX(clean_amount) AS max_bill
FROM clean_healthcare
GROUP BY hospital
ORDER BY avg_billing
LIMIT 10;

SELECT COUNT(DISTINCT hospital) AS total_hospitals,
       ROUND(AVG(records_per_hospital), 0) AS avg_records
FROM (
    SELECT hospital, COUNT(*) AS records_per_hospital
    FROM clean_healthcare
    GROUP BY hospital
) AS h;

SELECT hospital,
  ROUND(AVG(clean_amount), 2) AS avg_billing,
  COUNT(*) AS total_records
FROM clean_healthcare
GROUP BY hospital
HAVING COUNT(*) > 5
ORDER BY avg_billing ASC
LIMIT 5;

/* Q12 Key Insights:
- Dataset has 39,874 unique hospitals for 54,966 patients
- Average = 1 record per hospital = randomly generated names
- Hospital-level comparison is not meaningful in this dataset
- Real insight: Focus on medical condition + insurance analysis instead */

-- ============================================================
-- SECTION 6: TREATMENT ANALYSIS
-- ============================================================

-- Q13: Most prescribed medication per medical condition

SELECT medical_condition , medication,
count(*) as total_patients
from clean_healthcare
group by medical_condition , medication
order by total_patients desc;

                                   
SELECT medical_condition, medication, total_patients
FROM (
    SELECT medical_condition, medication,
           COUNT(*) AS total_patients,
           RANK() OVER (PARTITION BY medical_condition 
           ORDER BY COUNT(*) DESC) AS rnk
    FROM clean_healthcare
    GROUP BY medical_condition, medication
) AS ranked
WHERE rnk = 1
ORDER BY total_patients DESC;

/* Q13 Key Insights:
- Lipitor (cholesterol drug) = top medication for Cancer + Diabetes
- Suggests these patients have high cholesterol as comorbidity
- Heart disease risk = hidden burden in Cancer + Diabetes patients
- Ibuprofen = top for Hypertension = pain management priority
- Penicillin = top for Obesity = infection risk in obese patients
- Recommendation:
  1. Screen all Cancer + Diabetes patients for cholesterol levels
  2. Add cardiac monitoring for patients on Lipitor
  3. Obesity patients need infection prevention protocols */

-- Q14: Test results breakdown (Normal vs Abnormal vs Inconclusive)

select test_results ,
count (*) as total_patients ,
ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
from healthcare
group by test_results
order by total_patients;

/* Q14 Key Insights:
- Abnormal , normal , inconclusion = 33% approx. = highest = alarming
- All 3 results almost equally distributed = suspicious uniformity
- Real hospitals: Normal results should be 60-70% not 33%
- Recommendation: Validate test result data quality —
  equal distribution suggests randomly generated values */
  
-- ============================================================
-- SECTION 7: ADVANCED WINDOW FUNCTIONS
-- ============================================================

-- Q15: Yearly billing trend

SELECT 
   EXTRACT(YEAR FROM admission_date) AS year,
   COUNT(*) AS total_patients,
   ROUND(AVG(clean_amount), 2) AS avg_billing,
   ROUND(SUM(clean_amount), 2) AS total_billing
FROM clean_healthcare
GROUP BY year
ORDER BY year;


/* Q15 Key Insights:
- 2019 (7,300) + 2024 (3,827) = partial year data = lower counts
- 2020-2023 peak = COVID-19 drove hospital admissions surge
- 2021 highest = 10,816 patients = peak COVID + post-COVID complications
- Avg billing consistent ₹25,000-₹25,700 across all years = uniform pricing confirmed
- 2024 drop = Gen Z increasingly health conscious = better diet + fitness
- 51% senior citizens driving bulk of admissions throughout all years
- Obesity dominant condition = lifestyle crisis worsened during COVID lockdowns
- Recommendation:
  1. Post-COVID senior care programs urgently needed
  2. Invest in Gen Z wellness momentum — they are responding
  3. Anti-obesity campaigns during lockdown periods
  4. Government must prepare for aging population surge by 2030 */

-- Q16: Running total billing by year

SELECT 
    EXTRACT(YEAR FROM admission_date) AS year,
    ROUND(SUM(clean_amount), 2) AS yearly_billing,
    ROUND(SUM(SUM(clean_amount)) OVER
	        (ORDER BY EXTRACT(YEAR FROM admission_date)), 2) AS running_total
FROM clean_healthcare
GROUP BY year
ORDER BY year;  

/* Q16 Key Insights:
- Total healthcare billing 2019-2024 = ₹1.40 Billion cumulative
- 2020 biggest single year jump = +51.6% from 2019 = COVID surge
- Crossed ₹1 Billion cumulative by 2022 = healthcare crisis scale
- 2021-2023 stable = ₹27-28Cr yearly = post COVID new normal
- 2024 sharp drop = partial year data only (not full year)
- Recommendation:
  1. Government must budget for ₹28Cr+ annual healthcare spend
  2. Build emergency capacity for sudden surges like 2020*/


