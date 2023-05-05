This dbt package contains tests that can be (re)used across dbt projects.

# Use dbt tests as an ad-hoc package

Inside your dbt project, create a file named `packages.yml` at the root of the project. Inside, specify the package that you want to install like so:
```yml
packages:
  - git: "https://[TOKEN]@github.com/<git repo>"
    revision: master
```
The revision field corresponds to the branch or the tag you want to install on your project. The main is most likely the most stable version.

Once your `packages.yml` file is complete and saved, run the following command in your terminal (the working directory of your terminal have to be the source of your dbt project):

```sh
dbt deps
```

dbt will import the dependencies you specified in your project in a new folder called `dbt_packages`.

# Available generic tests

## Content
## [Generic tests](#generic-tests-1)

### [Column tests](#Column_tests)
- [average_between](#average_between)
- [consistent_casing](#consistent_casing)
- [date_format](#date_format)
- [macth_like_pattern_list](#macth_like_pattern_list)
- [match_regex_pattern_list](#match_regex_pattern_list)
- [max_between](#max_between)
- [median_between](#median_between)
- [min_between](#min_between)
- [not_null_proportion](#not_null_proportion)
- [null_proportion](#null_proportion)
- [percentile_between](#percentile_between)
- [percentile_outliers](#percentile_outliers)
- [stddev_between](#stddev_between)
- [sum_between](#sum_between)
- [unique_proportion](#unique_proportion)
- [unwanted_characters](#unwanted_characters)
- [values_between](#values_between)
- [values_in_set](#values_in_set)

### [Metadata tests](#Metadata_tests)

-[column_count](#column_count)
-[column_type_in_list](#column_type_in_list)
-[row_count](#row_count)
-[table_recency_below](#table_recency_below)

### [Row tests](#Row_tests)
-[unique_combination_of_columns](#unique_combination_of_columns)

### [Stat tests](#Stat_tests)
-[categorical_outliers](#categorical_outliers)
-[compare_aggregate_to_rework](#compare_aggregate_to_rework)
-[test_ref_comparison](#test_ref_comparison)



# Generic tests

Test output format:

| timestamp | test_type | project | dataset | table | column | test_name | test_rule | test_params | key_field | result | failing_rows | test_status | query |
|-----------|-----------|---------|---------|-------|--------|-----------|-----------|-------------|-----------|--------|--------------|-------------|-------|

## **Column Tests**

### **average_between**

Expect the average of values in the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
test:
    - average_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

## **consistent_casing**
Expect all values of the column to have a consistant casing (i.e. column should not have values "Paris", "paris" and "PARIS" at the same time)

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file

**Usage:**

YAML:
```yml
tests:
    - consistent_casing:
        column_name: my_column
```

*Applies to*: **Column** (String types)

------------------------------------------------------------------------------------------------

### **date_format**

Expect the date column to have the same date format as the one provided.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `format` (list) | Date format the column should respect (see [here](https://cloud.google.com/bigquery/docs/reference/standard-sql/format-elements#format_elements_date_time) for more information on how to form your date format) | Yes

**Usage:**

YAML:
```yml
tests:
    - date_format:
        column_name: my_column
        format: "%Y-%m-%e"
```

*Applies to*: **Column** (Date types)

------------------------------------------------------------------------------------------------

## **match_like_pattern_list**
Expect values of the column to match all or any of the 'like' patterns provided.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `like_pattern_list` (list)| List of *like patterns** for the values to match. if you want to insert anti-slash('\') or quotes into your patterns remember to escape them with '\' | Yes
| `match_on` (string)|  | No, default any (True if any expression is matched),  group (True if all the expressions are matched)
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No

*like patterns are patterns as we defined them in SQL via the [LIKE clause](https://sql.sh/cours/where/like).

**Usage:**

YAML:
```yml
tests:
    - match_like_pattern_list:
        column_name: my_column

        like_pattern_list: 
        - campaign\\__\\_test\\_fb
        - campaign\\__\\_test\\_insta
        match_on: "any"
        where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}

```

*Applies to*: **Column** (String types)


------------------------------------------------------------------------------------------------

## **match_regex_pattern_list**

Expect values of the column to match all or any of the regex patterns provided.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `regex_pattern_list` (list)| List of regex patterns for the values to match. if you want to insert anti-slash('\') or quotes into your patterns remember to escape them with '\' | Yes
| `match_on` (string)|  | No, default any (True if any expression is matched),  group (True if all the expressions are matched)
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No

**Usage:**

YAML:
```yml
tests:
- match_regex_pattern_list:
    column_name: my_column
    like_pattern_list: 
    - campaign\\__\\_test\\_fb
    - campaign\\__\\_test\\_insta
    match_on: "any"
    where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}
```

*Applies to*: **Column** (String types)


------------------------------------------------------------------------------------------------

### **max_between**
Expect the maximum value of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - max_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **median_between**
Expect the median value of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined
|`respect_nulls` (bool) | Ignore nulls if set to `False`| No (default: `False`)

**Usage:**

YAML:
```yml
tests:
    - median_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
        respect_nulls: true
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **min_between**
Expect the minimum value of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - min_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
```

*Applies to*: **Column** (Numeric types)


------------------------------------------------------------------------------------------------

### **not_null_proportion**
Expect the proportion of not-null values of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - not_null_proportion:
        column_name: my_column
        min_value: 0
        max_value: 0.5
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **null_proportion**
Expect the proportion of null values of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - null_proportion:
        column_name: my_column
        min_value: 0
        max_value: 0.5
```


*Applies to*: **Column**

------------------------------------------------------------------------------------------------

### **percentile_between**
Expect the p-percentile value of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined
| `p` (float) | Percentile to consider. Must be between 0 and 1| Yes
**Usage:**

YAML:
```yml
tests:
    - percentile_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
        p: 0.5
```


*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

## **percentile_outliers**
Expect values of the column to be between the p-low and the p-high percentile values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `p_low` (float) | Lower bound for percentile range. Must be between 0 and 1 | Yes if `p_high` is not defined
| `p_high` (float) | Upper bound for percentile range. Must be between 0 and 1 | Yes if `p_low` is not defined

**Usage:**

YAML:
```yml
tests:
    - dbt_alerting_55.consistent_casing:
        column_name: my_column
        p_low: 0.2
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **stddev_between**
Expect the standard deviation value of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - stddev_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **sum_between**
Expect the sum of all the values of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - sum_between:
        column_name: my_column
        min_value: 1234
        max_value: 10000
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **unique_proportion**
Expect the proportion of unique values of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive). Must be between 0 and 1 as it's a proportion| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - unique_proportion:
        column_name: my_column
        min_value: 0
        max_value: 0.5
```

*Applies to*: **Column**

------------------------------------------------------------------------------------------------



## **unwanted_characters**
Expect values to not contain any of the provided unwanted characters.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `char_list` (list)| List of unwanted characters or strings in the column values | Yes


**Usage:**

YAML:
```yml
tests:
    - unwanted_characters:
        column_name: my_column
        char_list:
        - "$"
        - "£"
        - "%"
```


*Applies to*: **Column** (String types)

*Trigram*: **rcs**

------------------------------------------------------------------------------------------------

## **values_between**

Expect values of the column to be between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No


**Usage:**

YAML:
```yml
tests:
    - values_between: 
        column_name: my_column
        min_value: 10
        max_value: 350
        where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}

```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

## **values_in_set**

Expect all values of the column to be one of the provided list of allowed values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config fill
| `value_set` (list)| List of allowed values in the column  | Yes
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No


**Usage:**

YAML:
```yml
tests:
    - values_in_set: 
        column_name: my_column
        value_set:
        - Value1
        - Value2
        - Value3
        where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}
```

*Applies to*: **Column** (String or Numeric types)

------------------------------------------------------------------------------------------------

## **Metadata Tests**

### **Column count**

Expects table to have a number of columns between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
tests:
    - column_count:
        min_value: 5
        max_value: 15
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------

### **column_type_in_list**

Expect the column to have one of the type provided in the list of types given as input.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `column_type_list` (list) | List of types that are allowed for the column | Yes

**Usage:**

YAML:
```yml
tests:
    - column_type_in_list:
        column_name: my_column
        column_type_list:
        - INT64
        - FLOAT
```

*Applies to*: **Column**

------------------------------------------------------------------------------------------------


### **row_count**

Expects table to have a number of rows between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined
| `where_clause` (string) | SQL exception contained after WHERE in the query| No

**Usage:**

YAML:
```yml
tests:
    - row_count:
        min_value: 15000
        max_value: 17000
        where_clause: value BETWEEN 1 AND 1000
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------

### **table_recency_below**

Expects table be created below a certain time threshold

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `minute` (number) | Upper bound recency value | Yes 

**Usage:**

YAML:
```yml
tests:
    - table_recency_below:
        minute: 60
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------

## **Row Tests**

### **unique_combination_of_columns**
Expect the given combination of columns to be unique on every record.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `combination_of_columns` (list) | List of columns composing the wanted combination| Yes

**Usage:**

YAML:
```yml
test:
    - unique_combination_of_columns:
        combination_of_columns:
        - id
        - country_code
        - date
        - campaign_name
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------


## **Stat Tests**


### **categorical_outliers**

Expect all the values in the column to not have a frequency of apparition freater than the one specified. 

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `max_proportion` (float) | Maximum proportion of apparition of a value | Yes

**Usage:**

YAML:
```yml
test:
    - categorical_outliers:
        column_name: my_column
        max_proportion: 0.6
```


*Applies to*: **Column** (String types)

------------------------------------------------------------------------------------------------



### **compare_aggregates**

Give a comparison table of two models by comparing aggregates on given columns on given periods of time. This test never fails as it is more a visualisation than a test

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `model_ref` (string) | project.dataset.table, the model to which we want to compare aggregate values | Yes
| `dimension_list` (list) | List of columns to group by to apply the aggregations | Yes
| `metric_list` (list) | List of columns on which we want to apply the aggregation operator | Yes
| `aggregation` (string) | BQ function of aggregation that we want to apply on the metrics (AVG,MAX,MIN,SUM,...)| Yes
| `where_clause_test` (string) | Filter the processed data in the ref for the current model. This should be written as a regular SQL where clause **without** the WHERE key word. | No
| `where_clause_ref` (string) | Filter the processed data in the test for the reference model to be compared against. This should be written as a regular SQL where clause **without** the WHERE key word. | No


**Usage:**

YAML:
```yml
- dbt_alerting_55.compare_aggregate:
    model_ref: fiftyfive-launchpad-ds-test.dbt_pierrick.testing_table 
    dimension_list: 
    - UserCategory
    metric_list: 
    - Age	
    - FloatColumn
    - AgePlusFloat	
    aggregation: AVG
    where_clause_test: Age > 13
    where_clause_ref: Age > 15

```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------


### **ztest_ref_comparison**

Apply a ztest on a metric distribution and compares it with a reference. A z-test is a statistical test to determine whether two population means are different when the variances are known and the sample size is large. A z-test is a hypothesis test in which the z-statistic follows a normal distribution

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `model` (dbt model) | Default model the test is applied to | Yes
| `ref_model` (string) | Model of the table used as a reference for the distribution. This should be written as a regular SQL  table **project.dataset.table** | Yes
| `key_field` (string)| Dimension used to aggregate the results of the test to be compared with the reference table| Yes
| `ref_key_field` (string)| Dimension used to aggregate the results of the test to be compared with the test table | Yes
| `metric_variable` (string) | Variable used to compute the zscore. | Yes
| `ref_metric_variable` (string) | Variable from the reference table used to compute the zscore. | Yes
| `filter` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No
| `ref_filter` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No
| `score_threshold` (numeric) | Threshold used by the test to detect au faulty distriution (default is > 2.5) | No


**Usage:**

YAML:
```yml
tests:
    - ztest_ref_comparison:
        key_field: campaign_ID
        ref_key_field: campaign_ID
        metric_variable: revenue
        filter:  channel_lvl0 = "sem"
        ref_model: my-project.my-ref-dataset.my_ref_table_*
        ref_metric_variable: revenue
        ref_filter:  _TABLE_SUFFIX BETWEEN '20220101' AND '20220131'
    
```

*Applies to*: **Column** (String types)






