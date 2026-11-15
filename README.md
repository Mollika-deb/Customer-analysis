# Customer Profile & Spending Analysis

A customer analytics project using SQL Server and Power BI to explore data quality, customer profiles, and spending-score patterns.

## Project Objective

Understand how spending scores vary across age and income groups, create interpretable customer segments, and communicate the findings through a Power BI report.

## Tools

- **SQL Server and SSMS:** data exploration, quality checks, cleaning, and analysis
- **Power BI Desktop:** report development and visualization
- **DAX:** distinct customer count

## Dataset

The dataset contains **200 customer records** with five columns:

| Column | Description |
|---|---|
| customer_id | Customer identifier |
| gender | Recorded gender label |
| age | Customer age |
| income | Income variable; units not specified in the supplied CSV |
| spending_score | Numeric spending score; calculation methodology not supplied |

Each row represents one customer. The dataset does not contain transaction amounts, purchase dates, or visit history.

## Data Quality Checks

SQL queries were used to check:

- Missing values across all columns
- Duplicate customer IDs
- Inconsistent gender labels
- Numeric ranges

### Results

- 200 records and 200 unique customer IDs
- No missing values
- No duplicate customer IDs
- Three records used `M` instead of `Male`

The cleaned view standardizes `M` to `Male`, based on the documented assumption that these labels represent the same category. The original table is preserved.

## SQL Workflow

1. Imported the CSV into `CustomerAnalytics.dbo.shopping_centre`.
2. Checked data completeness, uniqueness, and category consistency.
3. Created `dbo.vw_customer_profiles` to standardize labels.
4. Added age groups and rule-based customer segments to the view.
5. Calculated summary metrics and compared customer groups.
6. Examined correlations between age, income, and spending score.
7. Connected Power BI to the cleaned SQL view.

## Summary Metrics

| Metric | Value |
|---|---:|
| Customers | 200 |
| Average age | 38.85 |
| Average income | 60.56 |
| Average spending score | 50.20 |

## Customer Segmentation

Customers were divided into four groups using the dataset medians:

- **Income threshold:** 61.5
- **Spending-score threshold:** 50

Values equal to a threshold are assigned to the higher group. These thresholds are fixed for this analysis.

| Segment | Customers | Average age | Average spending score |
|---|---:|---:|---:|
| Higher income / Higher score | 50 | 35.04 | 76.18 |
| Higher income / Lower score | 50 | 40.86 | 24.76 |
| Lower income / Higher score | 52 | 34.81 | 65.25 |
| Lower income / Lower score | 48 | 45.10 | 33.33 |

These are rule-based segments, not machine learning clusters. “Higher” and “lower” refer to this dataset rather than universal income or spending categories.

## Key Findings

### 1. Spending scores differ across age groups

| Age group | Customers | Average spending score |
|---|---:|---:|
| 18–29 | 55 | 58.58 |
| 30–39 | 61 | 61.10 |
| 40–49 | 39 | 34.95 |
| 50–59 | 25 | 34.72 |
| 60+ | 20 | 43.00 |

Customers aged **30–39** have the highest average spending score in this sample.

### 2. Income groups have similar average spending scores

Higher-income customers have an average score of **50.47**, compared with **49.93** for lower-income customers.

However, scores vary more within the higher-income group: the sample standard deviation is **29.52**, compared with **21.66** in the lower-income group.

### 3. Age has a stronger linear association with score than income

| Variables | Pearson correlation |
|---|---:|
| Age and spending score | -0.3272 |
| Income and spending score | 0.0099 |

Age shows a modest negative linear relationship with spending score. Income shows almost no overall linear relationship. This does not rule out nonlinear patterns or relationships within subgroups.

### 4. Higher-score segments are younger on average

Within both income categories, customers in the higher-score segment are younger on average than those in the lower-score segment.

This is a descriptive association and does not establish that age causes differences in spending score.

## Conclusion

Income alone does not adequately describe spending-score patterns in this sample. Higher- and lower-income customers have similar average scores, while age groups show clearer differences.

Examining age alongside income provides a more informative customer profile. Actual purchase history, visit frequency, and customer feedback would be needed before translating these observations into marketing decisions.

## Power BI Report

**Status: In progress**

The cleaned SQL view has been connected to Power BI, and report development has started.

Planned visuals include:

- Customer count and average profile metrics
- Average spending score by age group
- Income versus spending score scatter plot
- Customer segment distribution
- Interactive age-group and gender filters


## Limitations

- The dataset contains only 200 customers; its sampling method and representativeness are not established.
- Income units and the spending-score methodology were not supplied.
- Spending score should not be interpreted as revenue, profit, or customer lifetime value.
- The data cannot establish loyalty, repeat purchases, or trends over time.
- Correlations and group comparisons do not establish causation.
- Dataset source and redistribution terms should be documented before sharing the CSV publicly.

