{% test min_between(model, column_name, min_value=None, max_value=None) %}

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

SELECT 
  *, 
  IF({% if max_value!=None %} result > {{ max_value }} {% else %} 1=2 {% endif %} OR {% if min_value != None %} result < {{ min_value }} {% else %} 1=2 {% endif %},'FAIL','PASS') AS test_status
FROM
(
  SELECT
    TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
    'column_test' AS test_type,
    '{{ model.database }}' AS project,
    '{{ model.schema }}' AS dataset,
    '{{ model.table }}' AS table,
    '{{ column_name }}' AS column,
    'min_between' AS test_name,
    'inimum value of the column should be between a specified range' AS test_rule,
    '{"min_value":{{min_value}}, "max_value":{{max_value}}}' AS test_params,
    CAST((SELECT MIN({{ column_name }}) FROM {{ model }}) AS NUMERIC) AS result,
    NULL AS failing_rows
)
{% endtest %}