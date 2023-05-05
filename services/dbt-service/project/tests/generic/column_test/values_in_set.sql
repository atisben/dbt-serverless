{% test values_in_set(model, column_name, value_set = None, where_clause=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}


{%- if value_set == None  %}
  {{ exceptions.raise_compiler_error("You have to provide at least one value to build the set of allowed values. Got value_set = " ~ value_set) }}
{% endif %}

WITH error_rows AS (
    SELECT *
    FROM {{model}}
    WHERE CAST({{column_name}} AS STRING) NOT IN ( "{{ value_set | join('", "') }}")
    {%- if where_clause != None %}
    OR CAST({{column_name}} AS STRING) IS NULL
    AND
        {{where_clause}}
    {%endif%}
)

SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'row_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{column_name}}' AS column,
        'values_in_set' AS test_name,
        'Every value should fall in the set of allowed values provided' AS test_rule,
        '{"value_set" = {{value_set | replace("\'","") | replace("\"","")}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM ({{query_check}})) AS NUMERIC) AS failing_rows,
        CAST(("""{{check_query}}""") AS STRING) AS query
)


{% endtest %}