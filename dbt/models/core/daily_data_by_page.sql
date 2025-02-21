{{
    config(
        materialized='table'
    )
}}

WITH daily_data AS (
    SELECT * FROM {{ ref('stg_daily_data') }}
),
page_categories AS (
    SELECT * FROM {{ ref('page_categories') }}
)

SELECT
    d.unique_row_id,
    d.filename,
    d.requested_url,
    p.cleaned_page_url,
    d.ip_address,
    d.timestamp,
    d.http_method,
    d.http_protocol,
    d.response_code,
    d.bytes_transferred,
    d.referrer,
    d.user_agent,
    d.bot_human_flag,
    d.bot_name,
    p.page_category
FROM daily_data d
LEFT JOIN page_categories p 
ON d.requested_url = p.page_url