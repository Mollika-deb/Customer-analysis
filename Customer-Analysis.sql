USE CustomerAnalytics;
GO

SELECT TOP (10) *
FROM dbo.shopping_centre
ORDER BY customer_id;

-- Count records and unique customers.
SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM dbo.shopping_centre;

-- Check gender labels.
SELECT
    gender,
    COUNT(*) AS customer_count
FROM dbo.shopping_centre
GROUP BY gender
ORDER BY customer_count DESC;

USE CustomerAnalytics;
GO

-- Check for missing values.
SELECT
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END)
        AS missing_customer_id,

    SUM(CASE
        WHEN gender IS NULL OR LTRIM(RTRIM(gender)) = ''
        THEN 1 ELSE 0
    END) AS missing_gender,

    SUM(CASE WHEN age IS NULL THEN 1 ELSE 0 END)
        AS missing_age,

    SUM(CASE WHEN income IS NULL THEN 1 ELSE 0 END)
        AS missing_income,

    SUM(CASE WHEN spending_score IS NULL THEN 1 ELSE 0 END)
        AS missing_spending_score

FROM dbo.shopping_centre;


-- Check for duplicate customer IDs.
SELECT
    customer_id,
    COUNT(*) AS record_count
FROM dbo.shopping_centre
GROUP BY customer_id
HAVING COUNT(*) > 1;

USE CustomerAnalytics;
GO

CREATE OR ALTER VIEW dbo.vw_customer_profiles
AS
SELECT
    customer_id,

    CASE
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('M', 'MALE')
            THEN 'Male'
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('F', 'FEMALE')
            THEN 'Female'
        ELSE 'Unknown'
    END AS gender,

    age,
    income,
    spending_score

FROM dbo.shopping_centre;
GO

-- Check the cleaned gender labels.
SELECT
    gender,
    COUNT(*) AS customer_count
FROM dbo.vw_customer_profiles
GROUP BY gender;

--summary metrics
USE CustomerAnalytics;
GO

SELECT
    COUNT(*) AS total_customers,

    ROUND(AVG(CAST(age AS DECIMAL(10, 2))), 2)
        AS average_age,

    ROUND(AVG(CAST(income AS DECIMAL(10, 2))), 2)
        AS average_income,

    ROUND(AVG(CAST(spending_score AS DECIMAL(10, 2))), 2)
        AS average_spending_score

FROM dbo.vw_customer_profiles;


-- Q1. Which age groups have higher average spending scores?

USE CustomerAnalytics;
GO

WITH age_groups AS
(
    SELECT
        CASE
            WHEN age < 30 THEN '18-29'
            WHEN age < 40 THEN '30-39'
            WHEN age < 50 THEN '40-49'
            WHEN age < 60 THEN '50-59'
            ELSE '60+'
        END AS age_group,

        spending_score

    FROM dbo.vw_customer_profiles
)

SELECT
    age_group,
    COUNT(*) AS customer_count,

    ROUND(
        AVG(CAST(spending_score AS DECIMAL(10, 2))),
        2
    ) AS average_spending_score

FROM age_groups
GROUP BY age_group
ORDER BY age_group;


-- Customer Segmentation and View Update

USE CustomerAnalytics;
GO

CREATE OR ALTER VIEW dbo.vw_customer_profiles
AS
SELECT
    customer_id,

    CASE
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('M', 'MALE')
            THEN 'Male'
        WHEN UPPER(LTRIM(RTRIM(gender))) IN ('F', 'FEMALE')
            THEN 'Female'
        ELSE 'Unknown'
    END AS gender,

    age,
    income,
    spending_score,

    CASE
        WHEN age < 30 THEN '18-29'
        WHEN age < 40 THEN '30-39'
        WHEN age < 50 THEN '40-49'
        WHEN age < 60 THEN '50-59'
        ELSE '60+'
    END AS age_group,

    CASE
        WHEN income >= 61.5 AND spending_score >= 50
            THEN 'Higher income / Higher score'
        WHEN income >= 61.5 AND spending_score < 50
            THEN 'Higher income / Lower score'
        WHEN income < 61.5 AND spending_score >= 50
            THEN 'Lower income / Higher score'
        ELSE 'Lower income / Lower score'
    END AS customer_segment

FROM dbo.shopping_centre;
GO

-- Check the customer segments.
SELECT
    customer_segment,
    COUNT(*) AS customer_count
FROM dbo.vw_customer_profiles
GROUP BY customer_segment
ORDER BY customer_segment;


--Q. How do spending scores vary with age and income, and what distinguishes the customer groups?

USE CustomerAnalytics;
GO

-- Analysis 1: Income groups and spending scores

WITH income_groups AS
(
    SELECT
        CASE
            WHEN income >= 61.5 THEN 'Higher income'
            ELSE 'Lower income'
        END AS income_group,
        CAST(spending_score AS FLOAT) AS spending_score
    FROM dbo.vw_customer_profiles
)
SELECT
    income_group,
    COUNT(*) AS customer_count,
    ROUND(AVG(spending_score), 2) AS average_spending_score,
    ROUND(STDEV(spending_score), 2) AS spending_score_stddev,
    MIN(spending_score) AS minimum_score,
    MAX(spending_score) AS maximum_score
FROM income_groups
GROUP BY income_group;


-- Analysis 2: Customer segment profiles

SELECT
    customer_segment,
    COUNT(*) AS customer_count,

    ROUND(AVG(CAST(age AS FLOAT)), 2)
        AS average_age,

    ROUND(AVG(CAST(income AS FLOAT)), 2)
        AS average_income,

    ROUND(AVG(CAST(spending_score AS FLOAT)), 2)
        AS average_spending_score

FROM dbo.vw_customer_profiles
GROUP BY customer_segment
ORDER BY customer_segment;

-- Analysis 3: Correlation with spending score

WITH numeric_data AS
(
    SELECT
        CAST(age AS FLOAT) AS age,
        CAST(income AS FLOAT) AS income,
        CAST(spending_score AS FLOAT) AS spending_score
    FROM dbo.vw_customer_profiles
),
pairs AS
(
    SELECT
        'Age and spending score' AS relationship,
        age AS x,
        spending_score AS y
    FROM numeric_data

    UNION ALL

    SELECT
        'Income and spending score',
        income,
        spending_score
    FROM numeric_data
),
centered AS
(
    SELECT
        relationship,
        x - AVG(x) OVER (PARTITION BY relationship) AS dx,
        y - AVG(y) OVER (PARTITION BY relationship) AS dy
    FROM pairs
    WHERE x IS NOT NULL AND y IS NOT NULL
)
SELECT
    relationship,
    ROUND(
        SUM(dx * dy)
        / NULLIF(
            SQRT(SUM(dx * dx)) * SQRT(SUM(dy * dy)),
            0
        ),
        4
    ) AS correlation
FROM centered
GROUP BY relationship;


-- Analysis 4: Spending scores by gender

SELECT
    gender,
    COUNT(*) AS customer_count,

    ROUND(AVG(CAST(spending_score AS FLOAT)), 2)
        AS average_spending_score,

    ROUND(AVG(CAST(income AS FLOAT)), 2)
        AS average_income

FROM dbo.vw_customer_profiles
GROUP BY gender;