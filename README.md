# Preventive Care Analytics Dashboard
End-to-end healthcare analytics project using SQL, Python, and Power BI to analyze preventive care compliance and gaps

## Project Overview
This project analyzes preventive healthcare data to evaluate patient compliance, identify care gaps, and highlight high-risk groups.

It is an end-to-end data analytics project using:
- SQL (data extraction)
- Python (data cleaning)
- Power BI (dashboard)

## Objectives
- Measure patient compliance with preventive care
- Identify care gaps (Due, Missed, Overdue)
- Track monthly trends
- Analyze risk by age group
- Provide actionable insights

## Tools Used
- SQL  
- Python (Pandas)  
- Power BI  

## Dashboard Features

### KPIs
- Total Patients  
- Compliance Rate  
- Average Care Gaps  
- Overdue Rate  
- Full Compliance %  

### Visuals
- Monthly Compliance Trend  
- Compliance Rate by Preventive Care  
- Gap Rate by Preventive Care  
- Care Gap Distribution by Age Group  

### Filters
- Care Name  
- Status  
- Gender  
- Reporting Period  

## Key Insights
- Some preventive care types have lower compliance
- Many patients fall into overdue category
- Older age groups have higher care gaps
- Compliance varies over time

## Data Workflow

### Step 1: Python
- Clean data
- Handle missing values
- Create Age Groups
  
### Step 2: SQL
- Extract patient and care data
- Prepare structured dataset

### Step 3: Power BI
- Build data model
- Create DAX measures
- Design dashboard

## Important DAX Measures

### Compliance Rate
DIVIDE([Completed Care], [Due Care], 0)

### Overdue Rate
Overdue Rate =
DIVIDE([Overdue Care Count], [Total Care], 0)

### Full Compliance %
Full Compliance % =
DIVIDE(
[Fully Compliant Patients],
DISTINCTCOUNT(patients[patient_id]),
0
)

## Dashboard Preview
<img width="1141" height="691" alt="image" src="https://github.com/user-attachments/assets/63ff9514-b85a-45d5-8df7-824bae0c9ba2" />

## Files in Project
- SQL Script
- Python Notebook
- PowerBI Dashboard Screenshot

## Author
Priyanka

## Support
If you like this project, give it a star ⭐ on GitHub!
