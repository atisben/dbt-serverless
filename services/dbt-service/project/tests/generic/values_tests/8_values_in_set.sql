{% test values_in_set(model, column_name, value_set = None, where_clause=None, key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
{{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

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
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{column_name}}' AS column,
        'values_in_set' AS test_name,
        'Every value should fall in the set of allowed values provided' AS test_rule,
        'value_set = {{value_set | replace("\'","") | replace("\"","")}}, where_clause = {{where_clause}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)


{% endtest %}