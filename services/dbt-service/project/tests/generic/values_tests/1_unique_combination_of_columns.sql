{% test unique_combination_of_columns(model, combination_of_columns=None, key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if combination_of_columns==None  %}
  {{ exceptions.raise_compiler_error("You have to specify at least one column on wich you want to check for duplicates. Got combination_of_columns = " ~ combination_of_columns ) }}
{% endif %}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
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
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        'unique_combination_of_columns' AS test_name,
        'No duplicates should be found on the combination of columns. Got combination: {{ columns_csv }}' AS test_rule,
        'combination_of_columns = {{combination_of_columns | replace("\'","") | replace("\"","")}}, key_field = {{key_field}}' AS test_params,
        CAST(COUNT(*) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM duplicated_rows) AS failed_key_field
    FROM
        duplicated_rows
)


{% endtest %}