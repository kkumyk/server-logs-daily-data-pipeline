{% macro bot_vs_human(user_agent) %}
    CASE 
        WHEN LOWER({{ user_agent }}) LIKE '%bot%' 
        THEN 'bot'
        ELSE 'human'
    END
{% endmacro %}