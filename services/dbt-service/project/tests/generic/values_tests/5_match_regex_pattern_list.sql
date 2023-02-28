{% test match_regex_pattern_list(model, column_name,
                        regex_pattern_list = None,
                        match_on="any", 
                        where_clause=None,
                        key_field = None)%}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- if key_field==None  %}
  {{ exceptions.raise_compiler_error("You have to specify the key_field that is a unique identifier for rows in the table to be able to identify the potential failing rows. Got key_field = " ~ key_field) }}
{% endif %}

{%- if match_on!='any' and match_on!='group'  %}
  {{ exceptions.raise_compiler_error("match_on should be either 'any' or 'all'. Got match_on = " ~ match_on) }}
{% endif %}

{%- if regex_pattern_list == None  %}
  {{ exceptions.raise_compiler_error("You have to provide at least one regex pattern for the data to match. Got regex_pattern_list = " ~ regex_pattern_list) }}
{% endif %}

WITH error_rows AS(
    SELECT * 
    FROM {{ model }}
    WHERE 
    {% for regex_pattern in regex_pattern_list %}
        not REGEXP_CONTAINS({{ column_name }}, r'{{ regex_pattern }}') 
        {%- if not loop.last %}
        {{ " or " if match_on == "any" else " and "}}
        {% endif -%}
        {% endfor %}
    {%- if where_clause != None %}
        AND {{where_clause}}
    {% endif -%}
)

SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{column_name}}' AS column,
        'match_regex_pattern_list' AS test_name,
        "Every value in the column should match the regex patterns provided. " AS test_rule,
        'key_field = {{key_field}}, regex_pattern_list = {{regex_pattern_list | replace("\"","") | replace("\'","")}}, match_on = {{match_on}}, where_clause = {{where_clause}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        '{{key_field}}' AS key_field,
        ARRAY(SELECT {{key_field}} FROM error_rows) AS failed_key_field
    )

{%- endtest -%}