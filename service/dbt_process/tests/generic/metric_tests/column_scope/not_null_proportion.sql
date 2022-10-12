{% test not_null_proportion(model, column_name, min_value=0.0, max_value=1.0) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='OK',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if min_value > max_value  %}
  {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
{% endif %}

SELECT *, 
       IF({% if max_value!=None %} result > {{ max_value }} {% else %} 1=2 {% endif %} OR {% if min_value != None %} result < {{ min_value }} {% else %} 1=2 {% endif %},'KO','OK') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{ column_name }}' AS column,
        'not_null_proportion' AS test_name,
        'proportion of non-null values present in the column should be between a specified range' AS test_rule,
        'min_value = {{min_value}}, max_value = {{max_value}}' AS test_params,
        CAST({% if min_value!=None %} {{ min_value }} {% else %} NULL {% endif %} AS NUMERIC) AS min_value ,
        CAST({% if max_value!=None %} {{ max_value }} {% else %} NULL {% endif %} AS NUMERIC) AS max_value ,
        CAST(SUM(IF({{ column_name }} IS NULL,0,1))/CAST(COUNT(*) AS NUMERIC) AS NUMERIC) AS result
    FROM
        {{ model }}
)
{% endtest %}

