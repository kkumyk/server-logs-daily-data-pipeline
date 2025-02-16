{{ config(materialized='table') }}

select 
    page_url,
    case 
        when page_url = '/' then '/'
        else regexp_replace(regexp_replace(page_url, '/$', ''), '\\?.*', '') 
    end as cleaned_page_url,
    page_category
from {{ ref('categories_by_page') }}