{% test percentile_outliers(model, column_name, p_low=None, p_high=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if p_low!=None and p_high!=None%}
  {% if p_low > p_high  %}
    {{ exceptions.raise_compiler_error("parameter 'p_low' should not be greater than parameter 'p_high'. Got: " ~ p_low  ~ " > " ~ p_high ) }}
  {% endif %}
{% endif %}



{% set check_query %} 
    SELECT *
    FROM {{model}}
    WHERE {{column_name}} < (SELECT p_low FROM (
       SELECT {% if p_low != None %} PERCENTILE_CONT({{column_name}}, {{p_low}}) OVER()  {% else %} NULL {% endif %} AS p_low
        FROM {{model}}
      LIMIT 1
    ))
    OR {{column_name}} > (SELECT p_high FROM (    
      SELECT {% if p_high != None %} PERCENTILE_CONT({{column_name}}, {{p_high}}) OVER() {% else %} NULL {% endif %} AS p_high
      FROM {{model}}
      LIMIT 1
    ))
{% endset %}

SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
        'column_test' AS test_type,
        '{{ model.database }}' AS project,
        '{{ model.schema }}' AS dataset,
        '{{ model.table }}' AS table,
        '{{column_name}}' AS column,
        'percentile_outliers' AS test_name,
        "Every value should between the p_low-percentile and the p_high-percentile value" AS test_rule,
        '{"p_low" = {{p_low}}, "p_high" = {{p_high}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM ({{check_query}})) AS NUMERIC) AS failing_rows,
        CAST(("""{{check_query}}""") AS STRING) AS query
)

{% endtest %}