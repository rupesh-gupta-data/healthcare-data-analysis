# 🏥 Healthcare Patient Analytics

## 📌 Project Overview
Analysis of 54,966 real Kaggle healthcare records to identify 
billing patterns, patient demographics and treatment insights 
using PostgreSQL and Excel.

## 🛠️ Tools Used
| Tool | Purpose |

| PostgreSQL | 17 SQL queries across 7 sections |
| Microsoft Excel | 5 pivot charts + SQL integration notes |

## 🧹 Data Cleaning
| Issue | Records | Fix |

| Negative billing | 106 records | ABS() function |
| Random hospital names | 39,874 unique | Documented as limitation |
| Partial year data | 2019 + 2024 | Noted in insights |
| Stay duration missing | All rows | Calculated from dates |

## 📊 Excel Analysis
| Sheet | Analysis | SQL Connection |

| Medical Condition | Avg billing by condition | Q7 |
| Insurance Provider | Avg billing by provider | Q8 |
| Demographics | Age group admissions | Q9 + Q11 |
| Yearly Trend | Billing trend 2019-2024 | Q15 + Q16 |

## 🗃️ SQL Analysis (7 Sections)
| Section | Queries | Focus |

| Data Audit | Q1-Q4 | Nulls, negatives, invalid dates |
| Data Cleaning | Q5 | CREATE VIEW with ABS() |
| Billing Analysis | Q6-Q8 | Admission type, conditions, insurance |
| Demographics | Q9-Q11 | Age groups, gender, conditions |
| Hospital Performance | Q12 | Data limitation documented |
| Treatment Analysis | Q13-Q14 | Medication, test results |
| Window Functions | Q15-Q17 | Trends, running totals, cost/day |

## 🔍 Key Insights
- Obesity → Diabetes → Asthma = chain of lifestyle diseases
- Senior citizens (50+) = 51% of all admissions
- 2020 admissions surged +51.6% = COVID-19 impact confirmed
- Lipitor prescribed for Cancer + Diabetes = high cholesterol comorbidity
- All billing uniform = synthetic dataset pricing detected
- Cumulative billing 2019-2024 = ₹1.40 Billion

## ⚠️ Data Limitation
Dataset contains 39,874 unique hospital names for 54,966 patients
— hospital names appear randomly generated. Hospital-level analysis
excluded. All other analyses are valid.

## 📁 Files
| File | Description |

| healthcare_analysis.sql | 17 SQL queries with business insights |
| healthcare_dataset.xlsm | Excel analysis with 5 pivot charts |

## 👤 Author
**Rupesh Gupta** — Aspiring Data Analyst | BBA 2nd Year
