{% test consistent_casing(model, column_name, key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

with test_data as (
    SELECT LOWER(distinct_values) AS value,
           COUNT(*) AS occurences 
    FROM (
        SELECT DISTINCT {{column_name}} as distinct_values
        FROM
            {{ model }}
    )
    GROUP BY value
    HAVING occurences > 1
 ),


error_rows as(
 SELECT * FROM {{ model }}
 WHERE LOWER({{column_name}}) IN (SELECT value FROM test_data)
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
        'consistent_casing' AS test_name,
        'Every value in the column should have consistent casing' AS test_rule,
        '{"key_field": {{key_field}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        
    )
 {%- endtest -%}