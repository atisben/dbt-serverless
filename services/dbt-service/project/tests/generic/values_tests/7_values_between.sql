{% test values_between(model, column_name, min_value=None, max_value=None, where_clause=None,key_field = None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

{% if min_value!=None and max_value!=None%}
  {% if min_value > max_value  %}
    {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
  {% endif %}
{% endif %}

{% if min_value==None and max_value==None %}
  {{ exceptions.raise_compiler_error("You have to provide at least one of max_value or min_value parameter") }}
{% endif %}

WITH error_rows AS (
        SELECT *
        FROM {{ model }}
        WHERE 
            {{ column_name }} < {{ min_value }}
        OR 
            {{ column_name }} > {{ max_value }}
        {%- if where_clause != None %}
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
        'values_between' AS test_name,
        "Every value should fall in the range provided i.e greater  or equal to min_value and less or equal than max_value." AS test_rule,
        'min_value = {{min_value}}, max_value = {{max_value}}, where_clause = {{where_clause}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)

{% endtest %}