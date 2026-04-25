----------------------------------------------------------------------------------------------------------
-- *****************************************************************************************************--
-- Project Name 			: Preventive Care Analysis - caretrack.sql
-- Created By				: Priyanka
-- About the Project		: Preventive Care Compliance Tracking is the process of monitoring patient 
--							adherence to recommended preventive healthcare services such as vaccinations 
--							and screenings, to identify care gaps and improve health outcomes through 
--							data-driven interventions.
-- Completetion Date		: Apr 25, 2026 
-- *****************************************************************************************************--
----------------------------------------------------------------------------------------------------------
--1. What is the compliance rate for each preventive care type?
SELECT 
    prc.care_name,
    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate
FROM 
    patients p
JOIN patient_care pc ON p.patient_id = pc.patient_id 
JOIN preventive_care prc ON prc.care_id = pc.care_id
GROUP BY 
    prc.care_name;

----------------------------------------------------------------------------------------------------------

--2.  Which patients have gaps in care?

SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    prc.care_name,
    pc.status,
    CASE 
        WHEN pc.status = 'Missed' THEN 'Gap - Missed'
        WHEN pc.status = 'Due' THEN 'Gap - Due'
		WHEN pc.status = 'Overdue' THEN 'Gap - Overdue'
        ELSE 'No Gap'
    END AS gap_type
FROM 
    patients p
JOIN patient_care pc ON p.patient_id = pc.patient_id 
JOIN preventive_care prc ON prc.care_id = pc.care_id
WHERE pc.status IN ('Missed', 'Due','Overdue')
ORDER BY p.patient_id;


----------------------------------------------------------------------------------------------------------

--3. How many patients are eligible for each preventive care?
SELECT 
    prc.care_name,
    COUNT(DISTINCT pc.patient_id) AS eligible_patients
FROM 
    patient_care pc
JOIN preventive_care prc ON prc.care_id = pc.care_id
GROUP BY 
    prc.care_name;

----------------------------------------------------------------------------------------------------------

--4. Which preventive care has the highest gap rate?
SELECT 
    prc.care_name,
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN pc.status IN ('Missed', 'Due','Overdue') THEN 1 END) AS gaps,
    COUNT(CASE WHEN pc.status IN ('Missed', 'Due','Overdue') THEN 1 END) * 100.0 
    / COUNT(*) AS gap_rate
FROM 
    patient_care pc
JOIN preventive_care prc ON prc.care_id = pc.care_id
GROUP BY prc.care_name
ORDER BY gap_rate DESC;

----------------------------------------------------------------------------------------------------------

--5. Compliance rate by age group

SELECT 
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_patients,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate, 
	p.age_group
    FROM 
        patients p
    JOIN patient_care pc 
        ON pc.patient_id = p.patient_id
GROUP BY 
    p.age_group
ORDER BY 
    p.age_group;

----------------------------------------------------------------------------------------------------------

--6. Compliance rate by gender
SELECT 
    gender,
    COUNT(*) AS total_patients,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_patients,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate
FROM 
        patients p
    JOIN patient_care pc 
        ON pc.patient_id = p.patient_id
GROUP BY 
    gender
ORDER BY 
    gender;

----------------------------------------------------------------------------------------------------------
-- 7. How many patients completed all required preventive care?
SELECT COUNT(*) AS patients_completed_all_care
FROM (
	SELECT 
		p.patient_id,
		COUNT(*) AS total_required, 
	    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) AS completed
	FROM 
	patients p
	JOIN patient_care pc ON p.patient_id = pc.patient_id
	JOIN preventive_care prc ON pc.care_id = prc.care_id
	WHERE prc.is_mandatory = 'Yes'
	GROUP BY p.patient_id
	HAVING 
	    COUNT(*) = COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END)
	ORDER BY p.patient_id
) t;

----------------------------------------------------------------------------------------------------------
-- 8. What is the trend of care completion over time?

SELECT 
    DATE_TRUNC('month', due_date) AS month_start,  
    COUNT(*) AS total_due,    
    COUNT(
        CASE 
            WHEN status = 'Completed' THEN 1 
        END
    ) AS completed_count,    
    ROUND(
        COUNT(
            CASE 
                WHEN status = 'Completed' THEN 1 
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS completion_rate_pct
FROM patient_care
WHERE due_date IS NOT NULL
GROUP BY DATE_TRUNC('month', due_date)
ORDER BY month_start;

----------------------------------------------------------------------------------------------------------
-- 9. Which patients have multiple care gaps?
SELECT 
    p.patient_id,
    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN pc.status IN ('Missed', 'Due','Overdue') THEN 1 END) AS gaps
FROM 
 patient_care pc
JOIN patients p ON p.patient_id = pc.patient_id
GROUP BY p.patient_id
HAVING COUNT(CASE WHEN pc.status IN ('Missed', 'Due','Overdue') THEN 1 END) > 1;

----------------------------------------------------------------------------------------------------------
-- 10. Top 5 most compliant and least compliant care types

WITH compliance_data AS (
    SELECT 
        prc.care_name,
        COUNT(*) AS total,
        COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) AS completed,
        COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate
    FROM 
        patient_care pc
    JOIN preventive_care prc ON pc.care_id = prc.care_id
    GROUP BY 
        prc.care_name
)

SELECT * FROM (
    -- Top 5 Most Compliant
    SELECT 
        'Top 5 Most Compliant' AS category,
        *
    FROM compliance_data
    ORDER BY compliance_rate DESC
    LIMIT 5
) t1

UNION ALL

SELECT * FROM (
    -- Top 5 Least Compliant
    SELECT 
        'Top 5 Least Compliant' AS category,
        *
    FROM compliance_data
    ORDER BY compliance_rate ASC
    LIMIT 5
) t2;


--======================================================================================================

-- 	ADVANCED LEVEL ANALYSIS

--======================================================================================================

-- Are older patients more compliant than younger ones?

WITH age_group_data AS (
    SELECT 
        p.patient_id,
        pc.status,
        CASE 
            WHEN p.age < 40 THEN 'Younger'
            ELSE 'Older'
        END AS age_group
    FROM 
        patients p
    JOIN patient_care pc ON p.patient_id = pc.patient_id
)

SELECT 
    age_group,
    COUNT(*) AS total,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed,
    COUNT(CASE WHEN status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate
FROM 
    age_group_data
GROUP BY 
    age_group
ORDER BY 
    age_group;

----------------------------------------------------------------------------------------------------------
-- On-Time vs Late Completion : if care was completed before or after due date

SELECT 
    CASE 
        WHEN pc.date_completed::date <= pc.due_date::date THEN 'On Time'
        ELSE 'Late'
    END AS completion_status,
    
    COUNT(*) AS total

FROM 
    patient_care pc

WHERE 
    pc.status = 'Completed'
    AND pc.date_completed IS NOT NULL
    AND pc.due_date IS NOT NULL

GROUP BY 
    completion_status;

----------------------------------------------------------------------------------------------------------
--Overdue Care Analysis : care that is still not completed and already past due

SELECT 
    COUNT(*) AS overdue_count
FROM patient_care
WHERE status = 'Overdue';


--patient_wise 
SELECT 
    pc.patient_id,
    COUNT(*) AS overdue_care
FROM patient_care pc
WHERE pc.status = 'Overdue'
GROUP BY pc.patient_id
ORDER BY overdue_care DESC;
	
----------------------------------------------------------------------------------------------------------
-- Mandatory vs Optional Compliance : Comparison of required vs optional care performance

SELECT 
    prc.is_mandatory, 
    COUNT(*) AS total,    
    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) AS completed,    
    COUNT(CASE WHEN pc.status = 'Completed' THEN 1 END) * 100.0 / COUNT(*) AS compliance_rate
FROM 
    patient_care pc
JOIN preventive_care prc ON pc.care_id = prc.care_id
GROUP BY 
    prc.is_mandatory;
	
----------------------------------------------------------------------------------------------------------
-- Patient Segmentation : Classify patients based on compliance behavior

--*-- Patient-level summary
WITH patient_summary AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_count,
        COUNT(CASE WHEN status = 'Scheduled' THEN 1 END) AS scheduled_count,
        COUNT(CASE WHEN status = 'Due' THEN 1 END) AS due_count,
        COUNT(CASE WHEN status IN ('Missed','Overdue') THEN 1 END) AS gap_count
    FROM patient_care
    GROUP BY patient_id
)

--*-- Segmentation

SELECT 
    CASE
        WHEN completed_count = total_records THEN 'Fully Compliant'
        WHEN gap_count > 0 THEN 'Non-Compliant'
        WHEN due_count > 0 THEN 'At Risk'
        ELSE 'Mostly Compliant'
    END AS patient_segment,
    COUNT(*) AS patient_count
FROM patient_summary
GROUP BY patient_segment;
	
--*-- Count per segment
WITH patient_summary AS (
    SELECT 
        patient_id,
        COUNT(*) AS total_records,
        COUNT(CASE WHEN status = 'Completed' THEN 1 END) AS completed_count,
        COUNT(CASE WHEN status = 'Scheduled' THEN 1 END) AS scheduled_count,
        COUNT(CASE WHEN status = 'Due' THEN 1 END) AS due_count,
        COUNT(CASE WHEN status IN ('Missed','Overdue') THEN 1 END) AS gap_count
    FROM patient_care
    GROUP BY patient_id
)

SELECT 
    CASE
        WHEN completed_count = total_records THEN 'Fully Compliant'
        WHEN gap_count > 0 THEN 'Non-Compliant'
        WHEN due_count > 0 THEN 'At Risk'
        ELSE 'Mostly Compliant'
    END AS patient_segment,
    COUNT(*) AS patient_count
FROM patient_summary
GROUP BY patient_segment;

----------------------------------------------------------------------------------------------------------
-- High-Risk Patients Table

SELECT 
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,

    COUNT(CASE WHEN pc.status = 'Missed' THEN 1 END) AS missed_count,
    STRING_AGG(DISTINCT CASE WHEN pc.status = 'Missed' THEN prc.care_name END, ', ') AS missed_care_names,

    COUNT(CASE WHEN pc.status = 'Overdue' THEN 1 END) AS overdue_count,
    STRING_AGG(DISTINCT CASE WHEN pc.status = 'Overdue' THEN prc.care_name END, ', ') AS overdue_care_names,

    COUNT(CASE WHEN pc.status = 'Due' THEN 1 END) AS due_count,
    STRING_AGG(DISTINCT CASE WHEN pc.status = 'Due' THEN prc.care_name END, ', ') AS due_care_names,

    MAX(CASE WHEN pc.status = 'Completed' THEN pc.date_completed::date END) AS last_visit

FROM patients p
JOIN patient_care pc ON p.patient_id = pc.patient_id
JOIN preventive_care prc ON prc.care_id = pc.care_id

GROUP BY 
    p.patient_id, p.first_name, p.last_name

HAVING 
    COUNT(CASE WHEN pc.status IN ('Missed','Overdue','Due') THEN 1 END) > 0

ORDER BY 
    overdue_count DESC,
    missed_count DESC,
    due_count DESC

LIMIT 10;

	