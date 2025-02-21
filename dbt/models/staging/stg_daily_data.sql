WITH bots_updated_logs AS (
    SELECT
        unique_row_id,
        filename,
        ip_address,
        timestamp,
        http_method,
        requested_url,
        http_protocol,
        response_code,
        bytes_transferred,
        referrer,
        user_agent,
        {{ bot_vs_human('user_agent') }} AS bot_human_flag,
        {{ bots('user_agent') }} AS bot_name
    FROM {{ source('staging', 'daily_data') }}
)

SELECT * FROM bots_updated_logs