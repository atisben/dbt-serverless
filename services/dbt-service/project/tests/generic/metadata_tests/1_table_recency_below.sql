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


SELECT 
    *, 
    IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'metadata_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{ column_name }}' AS column,
        'table_recency_below' AS test_name,
        'table recency is below the estimate time in minutes' AS test_rule,
        '{"minute":{{minute}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows
        
)


{% endtest %}