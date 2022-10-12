{% test percentile_outliers(model, column_name, p_low=None, p_high=None, key_field=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='OK',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% if p_low!=None and p_high!=None%}
  {% if p_low > p_high  %}
    {{ exceptions.raise_compiler_error("parameter 'p_low' should not be greater than parameter 'p_high'. Got: " ~ p_low  ~ " > " ~ p_high ) }}
  {% endif %}
{% endif %}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

WITH p_low_value AS(
    SELECT {% if p_low != None %} PERCENTILE_CONT({{column_name}}, {{p_low}}) OVER()  {% else %} NULL {% endif %} AS p_low
    FROM {{model}}
    LIMIT 1
),

p_high_value AS(
    SELECT {% if p_high != None %} PERCENTILE_CONT({{column_name}}, {{p_high}}) OVER() {% else %} NULL {% endif %} AS p_high
    FROM {{model}}
    LIMIT 1
),

error_rows AS(
    SELECT *
    FROM {{model}}
    WHERE {{column_name}} < (SELECT p_low FROM p_low_value)
    OR {{column_name}} > (SELECT p_high FROM p_high_value)
)

SELECT *, 
       IF(failing_rows > 0,'KO','OK') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{column_name}}' AS column,
        'percentile_outliers' AS test_name,
        "Every value should between the p_low-percentile and the p_high-percentile value" AS test_rule,
        'p_low = {{p_low}}, p_high = {{p_high}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)

{% endtest %}