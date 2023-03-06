{% test column_count(model, min_value=None, max_value=None ) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if min_value!=None and max_value!=None%}
  {% if min_value > max_value  %}
    {{ exceptions.raise_compiler_error("parameter 'min_value' should not be greater than parameter 'max_value'. Got: " ~ min_value  ~ " > " ~ max_value ) }}
  {% endif %}
{% endif %}

{% if min_value==None and max_value==None %}
  {{ exceptions.raise_compiler_error("You have to provide at least one of max_value or min_value parameter") }}
{% endif %}
{%- set number_actual_columns = (adapter.get_columns_in_relation(model) | length) -%}

{%- set expression %}
( 1=1
{%- if min_value %} and number_actual_columns >= min_value{% endif %}
{%- if max_value %} and number_actual_columns <= max_value{% endif %}
)
{% endset -%}


SELECT *, 
       {% if min_value!=None and max_value!=None%}
       IF(result > {{ max_value }} OR result < {{ min_value }},'FAIL','PASS') AS test_status
       {% elif min_value==None and max_value!=None%}
       IF(result > {{ max_value }},'FAIL','PASS') AS test_status
       {% elif min_value!=None and max_value==None%}
       IF(result < {{ min_value }},'FAIL','PASS') AS test_status
       {% endif %}
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        'column_count' AS test_name,
        'the number of columns in the model should be between min_value and max_value.' AS test_rule,
        'min_value = {{min_value}}, max_value = {{max_value}}' AS test_params,
        CAST({% if min_value!=None %} {{ min_value }} {% else %} NULL {% endif %} AS NUMERIC) AS min_value ,
        CAST({% if max_value!=None %} {{ max_value }} {% else %} NULL {% endif %} AS NUMERIC) AS max_value ,
        CAST({{ number_actual_columns }} AS NUMERIC) AS result
)
{% endtest %}
