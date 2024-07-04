
-- SET bigquery_billing_project = 'ose-volta-dev';

SELECT COUNT(*) as HowManyArticles
FROM `ose-volta-dev.ose_volta_insights.medium_articles_data1_2`
-- WHERE is_gcp is true
LIMIT 1000
