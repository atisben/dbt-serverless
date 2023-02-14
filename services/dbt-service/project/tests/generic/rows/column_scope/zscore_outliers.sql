{% test zscore_outliers(model, column_name, max_pos_zscore = 3, max_neg_zscore=-3,  key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

WITH average_value AS(
  SELECT AVG({{column_name}}) AS average
  FROM {{model}}
),
std_dev_value AS(
  SELECT STDDEV({{column_name}}) AS std_dev
  FROM {{model}}
),

error_rows AS(
  SELECT *
  FROM(
    SELECT *,
        ({{column_name}} - (SELECT average FROM average_value))/(SELECT std_dev FROM std_dev_value) AS zscore
  FROM {{model}}
  )
  WHERE zscore > {{max_pos_zscore}}
  OR zscore < {{max_neg_zscore}}
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
        'zscore_outliers' AS test_name,
        "Every value should have an absolute zscore between a min_value and a max_value value" AS test_rule,
        'max_pos_zscore = {{max_pos_zscore}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)

{% endtest %}