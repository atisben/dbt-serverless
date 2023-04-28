{% test row_count(model,
                    min_value=None,
                    max_value=None,
                    where_clause=None,
                    strictly=False) 
%}

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

WITH row_count_table AS(
    SELECT COUNT(*) AS row_count
    FROM 
        {{ model }}
    {%- if where_clause!=None-%}
    WHERE {{ where_clause }}
    {% endif %}
)

SELECT 
  *, 
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
    TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
    'metadata_test' AS test_type,
    '{{ model.database }}' AS project,
    '{{ model.schema }}' AS dataset,
    '{{ model.table }}' AS table,
    '{{ column_name }}' AS column,
    'row_count' AS test_name,
    'the number of rows in the model should be between min_value and max_value' AS test_rule,
    '{"min_value":{{min_value}}, "max_value":{{max_value}}}' AS test_params,
    CAST((SELECT row_count FROM row_count_table) AS NUMERIC) AS result
    NULL AS failing_rows
)
{%- endtest -%}