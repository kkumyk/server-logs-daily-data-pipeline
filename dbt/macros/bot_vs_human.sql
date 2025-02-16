{% macro bot_vs_human(user_agent) %}
    CASE 
        WHEN LOWER({{ user_agent }}) LIKE '%bot%' 
          OR LOWER({{ user_agent }}) LIKE '%spider%' 
          OR LOWER({{ user_agent }}) LIKE '%crawl%' 
          OR LOWER({{ user_agent }}) LIKE '%slurp%' 
          OR LOWER({{ user_agent }}) LIKE '%baidu%' 
          OR LOWER({{ user_agent }}) LIKE '%yandex%' 
          OR LOWER({{ user_agent }}) LIKE '%duckduckgo%' 
          OR LOWER({{ user_agent }}) LIKE '%bingpreview%' 
          OR LOWER({{ user_agent }}) LIKE '%facebookexternalhit%' 
          OR LOWER({{ user_agent }}) LIKE '%googlebot%' 
        THEN 'bot'
        ELSE 'human'
    END
{% endmacro %}