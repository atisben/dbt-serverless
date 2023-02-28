{% test date_format(model, column_name, format ,key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

WITH desired_format AS(
  SELECT * EXCEPT(date),
         FORMAT_DATE("{{format}}", date) FROM {{model}}
),

error_rows AS(
    SELECT * EXCEPT({{column_name}}), CAST ({{column_name}} AS STRING) FROM {{model}}
    EXCEPT DISTINCT
    SELECT * FROM desired_format
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
        'date_format' AS test_name,
        'Every date should respect the provided date format' AS test_rule,
        'format = {{format}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)


{%- endtest -%}