{% test date_format(model, column_name, format) %}

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
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'column_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{ column_name }}' AS column,
        'date_format' AS test_name,
        'every date should respect the provided date format' AS test_rule,
        '{"format":{{format}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
)


{%- endtest -%}