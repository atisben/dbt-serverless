{% test compare_aggregate(
    model,
    model2,
    dimension_list,
    metric_list,
    aggregation,
    where_clause_ref=None,
    where_clause_test=None
) %}

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

{% set check_query %}

SELECT  
    *
FROM(
    SELECT {{dimension_list | join(',')}}
    {% for metric in metric_list %}
        {{aggregation}}({{metric}}) AS {{aggregation}}_{{metric}} {% if not loop.last %},{% endif %}
    {% endfor %}
    FROM {{model_ref}}
    {% if where_clause_ref != None %}
        WHERE {{where_clause_ref}}
    {% endif %}
    GROUP BY {{dimension_list | join(',')}}
) AS ref
FULL OUTER JOIN(
    SELECT {{dimension_list | join(',')}}
    {% for metric in metric_list %}
        {{aggregation}}({{metric}}) AS {{aggregation}}_{{metric}} {% if not loop.last %},{% endif %}
    {% endfor %}
    FROM {{model}}
    {% if where_clause_test != None %}
        AND {{where_clause_test}}
    {% endif %}
    GROUP BY {{dimension_list | join(',')}}
) AS test
USING {{dimension_list | join(',')}}
WHERE TRUE
{% for metric in metric_list %}
    AND ref.{{aggregation}}_{{metric}} != test.{{aggregation}}_{{metric}}
{% endfor %} 


{% endset %}

SELECT 
  *, 
  IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
  SELECT
    TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
    'stat_test' AS test_type,
    '{{ model.database }}' AS project,
    '{{ model.schema }}' AS dataset,
    '{{ model.table }}' AS table,
    '{{dimension_list | join(",")}}' AS column,
    'compare_aggregates' AS test_name,
    'Compare an aggregation between the metrics of identical dimensions' AS test_rule,
    '{"dimension_list":{{dimension_list}}, "metric_list":{{metric_list}}, "aggregation":{{aggregation}}, "where_clause_ref":{{where_clause_ref}}, "where_clause_test":{{where_clause_test}}}' AS test_params,
    NULL AS result,
    CAST((SELECT COUNT(*) FROM ({{check_query}})) AS NUMERIC) AS failing_rows,
    CAST(("""{{check_query}}""") AS STRING) AS query

)

{% endtest %}