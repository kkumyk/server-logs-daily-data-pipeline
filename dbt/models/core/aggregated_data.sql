{{ config(materialized='table') }}

WITH aggregated_data AS (
    SELECT 
        DATE(timestamp) AS request_date,
        requested_url,
        bot_human_flag,
        bot_name,
        COUNT(*) AS total_requests,
        COUNT(DISTINCT ip_address) AS unique_visitors,
        SUM(CASE WHEN response_code = 200 THEN 1 ELSE 0 END) AS `200`,
        SUM(CASE WHEN response_code = 301 THEN 1 ELSE 0 END) AS `301`,
        SUM(CASE WHEN response_code = 302 THEN 1 ELSE 0 END) AS `302`,
        SUM(CASE WHEN response_code = 404 THEN 1 ELSE 0 END) AS `404`,
        SUM(CASE WHEN response_code = 500 THEN 1 ELSE 0 END) AS `500`,
        SUM(CASE WHEN bot_human_flag = 'bot' THEN 1 ELSE 0 END) AS bot_requests
    FROM {{ ref('daily_data_by_page') }}
    GROUP BY 1, 2, 3, 4
),

page_categories AS (
    SELECT page_url, cleaned_page_url, page_category FROM {{ ref('page_categories') }}
)

SELECT 
    COALESCE(ad.request_date, CURRENT_DATE) AS request_date,  -- Use today’s date for pages with no traffic
    c.page_url,
    c.cleaned_page_url,
    c.page_category,
    COALESCE(ad.bot_human_flag, 'unknown') AS bot_human_flag,
    COALESCE(ad.bot_name, 'unknown') AS bot_name,
    COALESCE(ad.total_requests, 0) AS total_requests,
    COALESCE(ad.unique_visitors, 0) AS unique_visitors,
    COALESCE(ad.200, 0) AS `200`,
    COALESCE(ad.404, 0) AS `404`,
    COALESCE(ad.301, 0) AS `301`,
    COALESCE(ad.302, 0) AS `302`,
    COALESCE(ad.500, 0) AS `500`,
    COALESCE(ad.bot_requests, 0) AS bot_requests
FROM page_categories c
LEFT JOIN aggregated_data ad
ON c.page_url = ad.requested_url