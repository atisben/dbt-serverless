{% test values_between(model, column_name, min_value=None, max_value=None, where_clause=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if min_value!=None and max_value!=None%}
  {% if min_value > max_value  %}
    {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
  {% endif %}
{% endif %}

{% if min_value==None and max_value==None %}
  {{ exceptions.raise_compiler_error("You have to provide at least one of max_value or min_value parameter") }}
{% endif %}

{% set check_query %} 
    SELECT 
      *
    FROM {{ model }}
    WHERE 
        {{ column_name }} < {{ min_value }}
    OR 
        {{ column_name }} > {{ max_value }}
    {%- if where_clause != None %}
    AND
        {{where_clause}}
    {%endif%}
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
        'values_between' AS test_name,
        "Every value should fall in the range provided i.e greater  or equal to min_value and less or equal than max_value." AS test_rule,
        '{"min_value" = {{min_value}}, "max_value" = {{max_value}}, "where_clause" = {{where_clause}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM ({{check_query}})) AS NUMERIC) AS failing_rows,
        CAST(("""{{check_query}}""") AS STRING) AS query

)

{% endtest %}