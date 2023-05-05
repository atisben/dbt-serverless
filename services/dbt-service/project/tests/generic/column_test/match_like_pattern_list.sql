{% test match_like_pattern_list(model, column_name,
                        like_pattern_list = None,
                        match_on="any", 
                        where_clause=None)%}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}


{%- if match_on!='any' and match_on!='group'  %}
  {{ exceptions.raise_compiler_error("match_on should be either 'any' or 'all'. Got match_on = " ~ match_on) }}
{% endif %}

{%- if like_pattern_list == None  %}
  {{ exceptions.raise_compiler_error("You have to provide at least one like pattern for the data to match. Got like_pattern_list = " ~ like_pattern_list) }}
{% endif %}

{% set check_query %} 
    SELECT * 
    FROM {{ model }}
    WHERE 
    {% for like_pattern in like_pattern_list %}
        {{ column_name }} not like '{{ like_pattern }}'
        {%- if not loop.last %}
        {{ " or " if match_on == "any" else " and "}}
        {% endif -%}
        {% endfor %}
    {%- if where_clause != None %}
        AND {{where_clause}}
    {% endif -%}
{% endset %}

SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'column_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{column_name}}' AS column,
        'match_like_pattern_list' AS test_name,
        "Every value in the column should match the like patterns provided. Got like_pattern_list =[ {{like_pattern_list | join(', ') }} ]" AS test_rule,
        '{"like_pattern_list" = {{like_pattern_list | replace("\"","") | replace("\'","")}}, "match_on" = {{match_on}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM ({{check_query}})) AS NUMERIC) AS failing_rows,
        CAST(("""{{check_query}}""") AS STRING) AS query
    )

{%- endtest -%}