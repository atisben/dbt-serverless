{% test ztest_ref_comparison(
  model, 
  key_field, 
  metric_variable, 
  filter = "", 
  ref_model, 
  ref_metric_variable, 
  ref_key_field, 
  ref_filter = "",
  score_threshold = 2.5
  )%}

# statistical test to determine whether two population means are different when the variances are known and the sample size is large

{{ config(
    enabled=true,
    fail_calc = "IF(test_status='PASS',0,1)",
    warn_if = "=2",
    error_if = "=1",
) }}

WITH ref AS (
  SELECT 
    {{ref_key_field}},
    AVG({{ref_metric_variable}}) AS mean_ref,
    STDDEV({{ref_metric_variable}}) AS sigma_ref
  FROM(SELECT * FROM {{ref_model}} WHERE {{ref_key_field}} IS NOT NULL)
  {{ref_filter}}
  GROUP BY 1

),

test AS(
  SELECT 
    {{key_field}},
    AVG({{metric_variable}}) AS mean_test,
    STDDEV({{metric_variable}}) AS sigma_test
  FROM(SELECT * FROM {{model}} WHERE {{key_field}} IS NOT NULL)
  {{filter}}
  GROUP BY 1
),

error_rows AS(
    SELECT
        *
    FROM(
        SELECT  
          IFNULL(test.{{key_field}}, ref.{{ref_key_field}}) AS {{key_field}},
          CASE
              WHEN test.{{key_field}} IS NULL THEN 5
              WHEN ref.{{ref_key_field}} IS NULL THEN 5
              WHEN sigma_ref = 0 OR sigma_test= 0 OR sigma_ref IS NULL OR sigma_test IS NULL THEN 5
              WHEN mean_ref = 0 OR mean_test = 0 OR mean_ref IS NULL OR mean_test IS NULL THEN 5
              ELSE ABS((mean_ref - mean_test)/(SQRT(POW(sigma_ref, 2)+POW(sigma_test, 2))))
          END AS ztest,
          mean_ref,
          mean_test,
          sigma_ref,
          sigma_test
        FROM ref 
        FULL OUTER JOIN test
        ON test.{{key_field}} = ref.{{ref_key_field}}
    )
    WHERE ztest > {{score_threshold}}
)

SELECT *, 
       IF(failing_rows > 0,'FAIL','PASS') AS test_status
FROM
(
    SELECT


    TIMESTAMP(CURRENT_DATETIME('UTC')) AS timestamp,
    'stat_test' AS test_type,
    '{{ model.database }}' AS project,
    '{{ model.schema }}' AS dataset,
    '{{ model.table }}' AS table,
    '{{ column_name }}' AS column,
    'ztest_distribution' AS test_name,
    'Distribution of the reference variable for the given key field should be identical to the distrubution of the tested variable' AS test_rule,
    '{"key_field":{{key_field}}, "metric_variable":{{metric_variable}}, "filter":{{filter}}, "ref_metric_variable":{{ref_metric_variable}}, "ref_key_field":{{ref_key_field}}, "ref_filter":{{ref_filter}}}' AS test_params,
    NULL AS result,
    CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,

)
{% endtest %}