{% test categorical_outliers(model, column_name, max_proportion = 0.8)%}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

WITH error_rows AS (
  SELECT *
  FROM 
  ( 
    SELECT {{column_name}},
            COUNT(1) AS failing_values,
            SAFE_DIVIDE(COUNT(*),(SELECT COUNT(*) FROM {{model}})) AS value_proportion 
    FROM {{ model }}
    GROUP BY {{ column_name }}
  )
  WHERE value_proportion > {{max_proportion}}
)


SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'stat_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{ column_name }}' AS column,
        'categorical_outliers' AS test_name,
        'proportion of the same value in the specified column shouldn not be higher than max_proportion' AS test_rule,
        '{"max_proportion":{{max_proportion}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows
        
)
{% endtest %}