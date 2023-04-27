/*
    The query below aggregates the results of all the tests

*/

{{ config(materialized='incremental') }}

SELECT * FROM `data-checker-dev.data_checker_audit.*`

/*
    Uncomment the line below to remove records with null `id` values
*/
