{% test unique_proportion(model, column_name, min_value=0.0, max_value=1.0, where_clause=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if min_value > max_value  %}
  {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
{% endif %}

WITH unique_values AS (
    SELECT COUNT(*) AS count 
    FROM (
        SELECT {{ column_name }}
        FROM {{ model }}
        {%- if where_clause != None %}
        WHERE 
            {{where_clause}}
        {%endif%}
        GROUP BY {{ column_name }}
        HAVING COUNT(*)=1
    )
)

SELECT *, 
       IF({% if max_value!=None %} result > {{ max_value }} {% else %} 1=2 {% endif %} OR {% if min_value != None %} result < {{ min_value }} {% else %} 1=2 {% endif %},'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{ column_name }}' AS column,
        'unique_proportion' AS test_name,
        'proportion of unique values present in the column should be between a specified range [min_value(optional), max_value(optional)]' AS test_rule,
        'min_value = {{min_value}}, max_value = {{max_value}}, where_clause = {{where_clause}}' AS test_params,
        CAST({% if min_value!=None %} {{ min_value }} {% else %} NULL {% endif %} AS NUMERIC) AS min_value ,
        CAST({% if max_value!=None %} {{ max_value }} {% else %} NULL {% endif %} AS NUMERIC) AS max_value ,
        CAST((SELECT count FROM unique_values)/CAST(COUNT(*) AS NUMERIC) AS NUMERIC) AS result
    FROM
        {{ model }}
    {%- if where_clause != None %}
    WHERE 
        {{where_clause}}
    {%endif%}
)
{% endtest %}