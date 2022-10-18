{% test compare_aggregate(model,
                             model2,
                             date_col1,
                             date_col2,
                             window1_start,
                             window1_end,
                             window2_start,
                             window2_end,
                             dimension_list,
                             metric_list,
                             aggregation,
                             where_clause1=None,
                             where_clause2=None) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='OK',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

-- Compare a list of metrics between two portions of the same table 
WITH current_window_data AS(
    SELECT {{dimension_list | join(',')}},
    {% for metric in metric_list %}
    {{aggregation}}({{metric}}) AS {{aggregation}}_{{metric}} {% if not loop.last %},{% endif %}
    {% endfor %}
    FROM {{model}}
    WHERE CAST({{date_col1}} AS TIMESTAMP) BETWEEN TIMESTAMP('{{window1_start}}') AND TIMESTAMP('{{window1_end}}')
    {% if where_clause1 != None %}
    AND {{where_clause1}}
    {% endif %}
    GROUP BY {{dimension_list | join(',')}}
),

compare_window_data AS(
    SELECT {{dimension_list | join(',')}},
    {% for metric in metric_list %}
    {{aggregation}}({{metric}}) AS {{aggregation}}_{{metric}} {% if not loop.last %},{% endif %}
    {% endfor %}
    FROM {{model2}}
    WHERE CAST({{date_col2}} AS TIMESTAMP) BETWEEN TIMESTAMP('{{window2_start}}') AND TIMESTAMP('{{window2_end}}')
    {% if where_clause2 != None %}
    AND {{where_clause2}}
    {% endif %}
    GROUP BY {{dimension_list | join(',')}}
)
    SELECT
        {% for dim in dimension_list %}
        {{dim}},
        {% endfor %}
        {% for metric in metric_list %}
        current_window_data.{{aggregation}}_{{metric}} AS {{aggregation}}_{{metric}}_window1 ,
        {% endfor %}

        {% for metric in metric_list %}
        compare_window_data.{{aggregation}}_{{metric}} AS {{aggregation}}_{{metric}}_window2 ,
        {% endfor %}
        "OK" AS test_status
    FROM
        current_window_data INNER JOIN compare_window_data USING({{dimension_list | join(',')}})


{% endtest %}