{% test unwanted_characters(model, column_name, key_field=None, char_list=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='OK',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

{%if char_list == None%}
    {{ exceptions.raise_compiler_error("You have to provide a list of characters that should not be in the values") }}
{% endif %}


WITH error_rows AS (
    SELECT *
    FROM
        {{ model }}
    WHERE    
    {%- for char in char_list %}
        {{ column_name }} LIKE r'%\{{ char }}%'
    {%- if not loop.last %}AND{% endif -%}
    {% endfor %}
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
        'unwanted_characters' AS test_name,
        "Values should not include one of the provided characters" AS test_rule,
        'char_list = {{char_list | replace("\"","") | replace("\'","")}}, key_field = {{key_field}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
)


{% endtest %}