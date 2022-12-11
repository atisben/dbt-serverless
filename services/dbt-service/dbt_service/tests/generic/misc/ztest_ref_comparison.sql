{% test ztest_ref_comparison(
  model, 
  key_field, 
  metric_variable, 
  ref_model, 
  ref_metric_variable, 
  ref_key_field, 
  filter = "", 
  ref_filter = "",
  score_threshold = 2.5
  )%}

# statistical test to determine whether two population means are different when the variances are known and the sample size is large

{{ config(
    enabled=true,
    fail_calc = "failing_rows",
    warn_if = "=2",
    error_if = "=1",
) }}

WITH reference AS (
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
          IFNULL(test.{{key_field}}, reference.{{ref_key_field}}) AS {{key_field}},
          CASE
              WHEN test.{{key_field}} IS NULL THEN 5
              WHEN reference.{{ref_key_field}} IS NULL THEN 5
              WHEN sigma_ref = 0 OR sigma_test= 0 OR sigma_ref IS NULL OR sigma_test IS NULL THEN 5
              WHEN mean_ref = 0 OR mean_test = 0 OR mean_ref IS NULL OR mean_test IS NULL THEN 5
              ELSE ABS((mean_ref - mean_test)/(SQRT(POW(sigma_ref, 2)+POW(sigma_test, 2))))
          END AS ztest,
          mean_ref,
          mean_test,
          sigma_ref,
          sigma_test
        FROM reference 
        FULL OUTER JOIN test
        ON test.{{key_field}} = reference.{{ref_key_field}}
    )
    WHERE ztest > {{score_threshold}}
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
        '{{metric_variable}}' AS column,
        'zscore_outliers' AS test_name,
        "Distrib of {{metric_variable}} from {{model}} should follow the distrib of {{ref_metric_variable}} from {{ref_model}} for any value of {{key_field}}" AS test_rule,
        'zscore-threshold = {{score_threshold}}' AS test_params,
        CAST((SELECT COUNT(*) FROM error_rows) AS NUMERIC) AS failing_rows,
        ARRAY(SELECT AS STRUCT {{ key_field }} FROM error_rows ) AS result
        
)
{% endtest %}