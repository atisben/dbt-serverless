{% test unique_combination_of_columns(model, combination_of_columns=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if combination_of_columns==None  %}
  {{ exceptions.raise_compiler_error("You have to specify at least one column on wich you want to check for duplicates. Got combination_of_columns = " ~ combination_of_columns ) }}
{% endif %}

{%- if combination_of_columns!=None %}
{%- set columns_csv=combination_of_columns | join(', ') %}
{% endif %}

WITH duplicated_rows AS(
    SELECT *,
            COUNT(*) OVER(PARTITION BY {{columns_csv}}) AS occurences
    FROM {{ model }}
    QUALIFY occurences > 1
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
      NULL AS column,
      'unique_combination_of_columns' AS test_name,
      'no duplicates should be found on the combination of columns. Got combination: {{ columns_csv }}' AS test_rule,
      '{"combination_of_columns":{{combination_of_columns | replace("\'","") | replace("\"","")}}, key_field = {{key_field}}}' AS test_params,
      NULL AS result,
      CAST((SELECT COUNT(*) FROM duplicated_rows) AS NUMERIC) AS failing_rows
)
{% endtest %}