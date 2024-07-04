-- SET bigquery_billing_project = 'ose-volta-dev';


SELECT
    t.* ,
-- TODO(ricc): add fancy url like "[title](url)"
    REGEXP_EXTRACT(t.user_email, r'(.+)@google.com') as ldap,
    ARRAY_TO_STRING(categories, ', ') as categories_str,
    "[Test fancy Link with bq](https://website-name.com)" as fancy_urled_title,
    'dev' as env
FROM `ose-volta-dev.ose_volta_insights.medium_articles_data1_2` t
WHERE is_gcp is true


-- LIMIT 1000
