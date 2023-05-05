{% test unwanted_characters(model, column_name, char_list=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%if char_list == None%}
    {{ exceptions.raise_compiler_error("You have to provide a list of characters that should not be in the values") }}
{% endif %}


{% set check_query %} 
    SELECT *
    FROM
        {{ model }}
    WHERE    
    {%- for char in char_list %}
        {{ column_name }} LIKE r'%\{{ char }}%'
    {%- if not loop.last %}AND{% endif -%}
    {% endfor %}
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
        'unwanted_characters' AS test_name,
        "Values should not include one of the provided characters" AS test_rule,
        '{"char_list" = {{char_list | replace("\"","") | replace("\'","")}}}' AS test_params,
        NULL AS result,
        CAST((SELECT COUNT(*) FROM ({{check_query}})) AS NUMERIC) AS failing_rows,
        CAST(("""{{check_query}}""") AS STRING) AS query

)


{% endtest %}