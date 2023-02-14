{% test column_type_in_list(model, column_name, column_type_list) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{%- set column_name = column_name | upper -%}
{%- set columns_in_relation = adapter.get_columns_in_relation(model) -%}
{%- set column_type_list = column_type_list| map("upper") | list -%}
with relation_columns as (

    {% for column in columns_in_relation %}
    select
        cast('{{ column.name | upper }}' as {{ dbt_utils.type_string() }}) as relation_column,
        cast('{{ column.dtype | upper }}' as {{ dbt_utils.type_string() }}) as relation_column_type
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),
test_data as (

    select
        relation_column_type
    from
        relation_columns
    where
        relation_column = '{{ column_name }}'

)
SELECT *, 
    IF(result = 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT
        TIMESTAMP(CURRENT_DATETIME('Europe/Paris')) AS timestamp,
        '{{model['database']}}' AS project,
        '{{model['schema']}}' AS dataset,
        '{{model['table']}}' AS table,
        '{{column_name}}' AS column,
        'column_type_in_list' AS test_name,
        'column type  should be in ({{ column_type_list | replace("\'","") | replace("\"","")}})' AS test_rule,
        'column_name = {{column_name}}, column_type_list = {{column_type_list | replace("\'","") | replace("\"","")}}' AS test_params,
        CAST(NULL AS NUMERIC) AS min_value ,
        CAST(NULL AS NUMERIC) AS max_value ,
        CAST((SELECT IF(relation_column_type not in ('{{ column_type_list | join("', '") }}'),0,1) AS bin_res FROM test_data) AS NUMERIC) AS result,
    FROM
        test_data
)

{% endtest %}