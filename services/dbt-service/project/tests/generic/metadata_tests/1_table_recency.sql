{% test table_recency_below(model, minute) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}



WITH error_rows AS (
    SELECT  
        COUNT(1) AS failing_values,
    FROM(
        SELECT 
            DATE_DIFF(CURRENT_TIMESTAMP(),creation_time, MINUTE) AS diff
            FROM {{model.database}}.{{model.schema}}.INFORMATION_SCHEMA.TABLES
            WHERE table_name = "{{model.table}}"
    )
    WHERE diff > {{minute}}
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
        NULL AS column,
        'table_recency_below' AS test_name,
        "Tables recency is below the estimate time in minutes" AS test_rule,
        'minutes < {{minute}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        NULL AS result
        
)


{% endtest %}