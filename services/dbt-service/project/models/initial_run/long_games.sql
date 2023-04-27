
-- Use the `ref` function to select from other models
{{ config(schema='input_data') }}

SELECT *
FROM {{ ref('baseball_games' ) }}
WHERE duration_minutes > 180
