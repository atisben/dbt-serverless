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

### [Metric tests](#metric-tests-1)
### [Table Scope](#table-scope-2)
1. [column_count](#columncount)
2. [row_count](#rowcount)

### [Column Scope](#column-scope-2)
1. [average_between](#averagebetween)
2. [max_between](#maxbetween)
3. [median_between](#medianbetween)
4. [min_between](#minbetween)
5. [not_null_proportion](#notnullproportion)
6. [null_proportion](#nullproportion)
7. [quantile_between](#quantilebetween)
8. [stddev_between](#stddevbetween)
9. [sum_between](#sumbetween)
10. [unique_proportion](#uniqueproportion)

### [Rows tests](#rows-tests-1)
### [Table Scope](#table-scope-3)
1. [unique_combination_of_columns](#uniquecombinationofcolumns)

### [Column Scope](#column-scope-3)
1. [consistent_casing](#consistentcasing)
2. [interquartile_outliers](#interquartileoutliers)
3. [match_like_pattern_list](#matchlikepatternlist)
4. [match_regex_pattern_list](#matchregexpatternlist)
5. [unwanted_characters](#unwantedcharacters)
6. [values_between](#valuesbetween)
7. [values_in_set](#valuesinset)
8. [zscore_outliers](#zscoreoutliers)
9. [typo_levenshtein](#typolevenshtein)


### [Other](#other-1)
1. [categorical_outliers](#categoricaloutliers)
2. [column_type_in_list](#columntypeinlist)
3. [compare_aggregates](#compareaggregates)
4. [date_format](#dateformat)
5. [ztest_ref_comparison](#ztestrefcomparison)

# Generic tests

## **Table Tests**

### **column_count**

Expects table to have a number of columns between two values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `min_value` (number) | Lower bound of the accepted range of values (inclusive) | Yes if `max_value` is not defined
| `max_value` (number) | Upper bound of the accepted range of values (inclusive)| Yes if `min_value` is not defined

**Usage:**

YAML:
```yml
- dbt_alerting_55.column_count:
    min_value: 5
    max_value: 15
```

*Applies to*: **Table**

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
- dbt_alerting_55.row_count:
    min_value: 15000
    max_value: 17000
    where_clause: value BETWEEN 1 AND 1000
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------

## **Columnar Tests**

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
- dbt_alerting_55.average_between:
    column_name: my_column
    min_value: 1234
    max_value: 10000
```

*Applies to*: **Column** (Numeric types)

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
- dbt_alerting_55.max_between:
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
- dbt_alerting_55.median_between:
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
- dbt_alerting_55.min_between:
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
- dbt_alerting_55.not_null_proportion:
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
- dbt_alerting_55.null_proportion:
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
- dbt_alerting_55.percentile_between:
    column_name: my_column
    min_value: 1234
    max_value: 10000
    p: 0.5
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
- dbt_alerting_55.stddev_between:
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
- dbt_alerting_55.sum_between:
    column_name: my_column
    min_value: 1234
    max_value: 10000
```

JSON:
```json
"dbt_alerting_55.sum_between":{
    "min_value": 1234,
    "max_value": 10000
}
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
- dbt_alerting_55.unique_proportion:
    column_name: my_column
    min_value: 0
    max_value: 0.5
```

*Applies to*: **Column**

------------------------------------------------------------------------------------------------

## **Values Tests**

Values tests work on a `key_field` principle:
- `key_field` determines the dimension used to check the data
- The test will scan any column of interest, and retrieve the `key_field` that don't respect the check.

> Tips: This field must have a high cardinality so that you can quickly understand which values are failing. An unique id is the optimal choice as you would be alerted of any id that doesn't respect the initial check. However unique keys are not always available.

### **unique_combination_of_columns**
Expect the given combination of columns to be unique on every record.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `combination_of_columns` (list) | List of columns composing the wanted combination| Yes

**Usage:**

YAML:
```yml
- dbt_alerting_55.unique_combination_of_columns:
    key_field: id
    combination_of_columns:
    - id
    - country_code
    - date
    - campaign_name
```

*Applies to*: **Table**

------------------------------------------------------------------------------------------------

## **consistent_casing**
Expect all values of the column to have a consistant casing (i.e. column should not have values "Paris", "paris" and "PARIS" at the same time)

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes

**Usage:**

YAML:
```yml
- dbt_alerting_55.consistent_casing:
    column_name: my_column
    key_field: id
```

*Applies to*: **Column** (String types)

------------------------------------------------------------------------------------------------

## **percentile_outliers**
Expect values of the column to be between the p-low and the p-high percentile values.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `p_low` (float) | Lower bound for percentile range. Must be between 0 and 1 | Yes if `p_high` is not defined
| `p_high` (float) | Upper bound for percentile range. Must be between 0 and 1 | Yes if `p_low` is not defined

**Usage:**

YAML:
```yml
- dbt_alerting_55.consistent_casing:
    column_name: my_column
    key_field: id
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

## **match_like_pattern_list**
Expect values of the column to match all or any of the 'like' patterns provided.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `like_pattern_list` (list)| List of *like patterns** for the values to match. if you want to insert anti-slash('\') or quotes into your patterns remember to escape them with '\' | Yes
| `match_on` (string)|  | No, default any (True if any expression is matched),  group (True if all the expressions are matched)
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No

*like patterns are patterns as we defined them in SQL via the [LIKE clause](https://sql.sh/cours/where/like).

**Usage:**

YAML:
```yml
- dbt_alerting_55.match_like_pattern_list:
    column_name: my_column
    key_field: id
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
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `regex_pattern_list` (list)| List of regex patterns for the values to match. if you want to insert anti-slash('\') or quotes into your patterns remember to escape them with '\' | Yes
| `match_on` (string)|  | No, default any (True if any expression is matched),  group (True if all the expressions are matched)
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No

**Usage:**

YAML:
```yml
- dbt_alerting_55.match_regex_pattern_list:
    column_name: my_column
    key_field: id
    like_pattern_list: 
    - campaign\\__\\_test\\_fb
    - campaign\\__\\_test\\_insta
    match_on: "any"
    where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}
```

*Applies to*: **Column** (String types)


------------------------------------------------------------------------------------------------

## **unwanted_characters**
Expect values to not contain any of the provided unwanted characters.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `char_list` (list)| List of unwanted characters or strings in the column values | Yes


**Usage:**

YAML:
```yml
- dbt_alerting_55.unwanted_characters:
    column_name: my_column
    key_field: id
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
- dbt_alerting_55.values_between: 
    column_name: my_column
    key_field: id
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
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `value_set` (list)| List of allowed values in the column  | Yes
| `where_clause` (string) | Filter the processed data in the test. This should be written as a regular SQL where clause **without** the WHERE key word. | No


**Usage:**

YAML:
```yml
- dbt_alerting_55.values_in_set: 
    column_name: my_column
    key_field: id
    value_set:
    - Value1
    - Value2
    - Value3
    where_clause: date BETWEEN {{ var(today_minus_1) }} AND {{ var(today) }}
```

*Applies to*: **Column** (String or Numeric types)

------------------------------------------------------------------------------------------------

## **zscore_outliers**

Expect z-score values of the `key_field` to follow the column distribution.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `max_pos_zscore` (numeric)| maximum positive z-score value allowed  | No (default to 3)
| `max_neg_zscore` (numeric) | maximum negative z-score value allowed  | No (default to -3)

**Usage:**

YAML:
```yml
- dbt_alerting_55.zscore_outliers: 
    column_name: my_column
    key_field: id
    max_pos_zscore: 3
    min_neg_zscore: -3
    
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------


## Other


### **categorical_outliers**

Expect all the values in the column to not have a frequency of apparition freater than the one specified. 

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `max_proportion` (float) | Maximum proportion of apparition of a value | Yes

**Usage:**

YAML:
```yml
- dbt_alerting_55.categorical_outliers:

    column_name: my_column
    max_proportion: 0.6
```


*Applies to*: **Column** (String types)

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
- dbt_alerting_55.column_type_in_list:
    column_name: my_column
    column_type_list:
    - INT64
    - FLOAT
```

*Applies to*: **Column**

------------------------------------------------------------------------------------------------

### **compare_aggregates**

Give a comparison table of two models by comparing aggregates on given columns on given periods of time. This test never fails as it is more a visualisation than a test

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `model2` (string) | project.dataset.table, the model to which we want to compare aggregate values | Yes
| `date_col1` (string) | Column used to define the column holding dates in the first model | Yes
| `date_col2` (string) | Column used to define the column holding dates in the second model | Yes
| `window1_start` (string) | Begining date of the date range of the firt model considered for the comparison | Yes
| `window1_end` (string) | End date of the date range of the first model considered for the comparison  | Yes
| `window2_start` (string) | Begining date of the date range of the second model considered for the comparison | Yes
| `window2_end` (string) | End date of the date range of the second model considered for the comparison  | Yes
| `dimension_list` (list) | List of columns to group by to apply the aggregations | Yes
| `metric_list` (list) | List of columns on which we want to apply the aggregation operator | Yes
| `aggregation` (string) | BQ function of aggregation that we want to apply on the metrics (AVG,MAX,MIN,SUM,...)| Yes
| `where_clause1` (string) | Filter the processed data in the test for the first model. This should be written as a regular SQL where clause **without** the WHERE key word. | No
| `where_clause2` (string) | Filter the processed data in the test for the second model. This should be written as a regular SQL where clause **without** the WHERE key word. | No


**Usage:**

YAML:
```yml
- dbt_alerting_55.compare_aggregate:
    model2: fiftyfive-launchpad-ds-test.dbt_pierrick.testing_table 
    date_col1: JoinDate
    date_col2: JoinDate
    window1_start: "2022-01-01"
    window1_end: "2022-03-30"
    window2_start: "2000-12-30"
    window2_end: "2026-12-01"
    dimension_list: 
    - UserCategory
    metric_list: 
    - Age	
    - FloatColumn
    - AgePlusFloat	
    aggregation: AVG
    where_clause1: Age > 13
    where_clause2: Age > 15

```

JSON:
```json
"dbt_alerting_55.compare_aggregate":{
    "model2": "fiftyfive-launchpad-ds-test.dbt_pierrick.testing_table" ,
    "date_col1": "JoinDate",
    "date_col2": "JoinDate",
    "window1_start": "2022-01-01",
    "window1_end": "2022-03-30",
    "window2_start": "2000-12-30",
    "window2_end": "2026-12-01",
    "dimension_list": ["UserCategory"],
    "metric_list": ["Age", "FloatColumn", "AgePlusFloat"
    ],	
    "aggregation": "AVG",
    "where_clause1": "Age > 13",
    "where_clause2": "Age > 15"
}
```

*Applies to*: **Column** (Numeric types)

------------------------------------------------------------------------------------------------

### **date_format**

Expect the date column to have the same date format as the one provided.

| Parameter | Description | Mandatory |
|------------|-------------|-----------|
| `column_name` (string) | Column to be tested | Yes if the test is not directly applied at the column level in the config file
| `key_field` (string) | Column to uniquely identify each record. This column will be used to identify faulty records in the output table. | Yes
| `format` (list) | Date format the column should respect (see [here](https://cloud.google.com/bigquery/docs/reference/standard-sql/format-elements#format_elements_date_time) for more information on how to form your date format) | Yes

**Usage:**

YAML:
```yml
- dbt_alerting_55.date_format:
    column_name: my_column
    key_field: id
    format: "%Y-%m-%e"
```

JSON:
```json
"dbt_alerting_55.date_format":{
    "key_field": "id",
    "format": "%Y-%m-%e"
}
```

*Applies to*: **Column** (Date types)


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






