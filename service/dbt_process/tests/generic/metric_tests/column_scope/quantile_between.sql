{% test percentile_between(model, column_name, min_value=None, max_value=None, p=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='OK',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if p==None  %}
  {{ exceptions.raise_compiler_error("parameter 'p' is mandatory (0<p<1). Got p=" ~ p ) }}
{% endif %}

{% if min_value!=None and max_value!=None%}
  {% if min_value > max_value  %}
    {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
  {% endif %}
{% endif %}

{% if min_value==None and max_value==None %}
  {{ exceptions.raise_compiler_error("You have to provide at least one of max_value or min_value parameter") }}
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
        'percentile_between' AS test_name,
        'the p-percentile value of the column should be between a specified range' AS test_rule,
        'min_value = {{min_value}}, max_value = {{max_value}}, p = {{p}}' AS test_params,
        CAST({% if min_value!=None %} {{ min_value }} {% else %} NULL {% endif %} AS NUMERIC) AS min_value ,
        CAST({% if max_value!=None %} {{ max_value }} {% else %} NULL {% endif %} AS NUMERIC) AS max_value ,
        CAST((SELECT PERCENTILE_CONT({{column_name}}, {{p}}) OVER() FROM {{ model }} LIMIT 1) AS NUMERIC) AS result
)
{% endtest %}