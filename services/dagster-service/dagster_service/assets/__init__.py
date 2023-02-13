from dagster_dbt import load_assets_from_dbt_project

from dagster import file_relative_path


DBT_PROJECT_PATH = file_relative_path(__file__, "../../../dbt-service/dbt_service")
DBT_PROFILES = file_relative_path(__file__, "../../../dbt-service/profiles")

dbt_assets = load_assets_from_dbt_project(
    project_dir=DBT_PROJECT_PATH, profiles_dir=DBT_PROFILES, key_prefix=["dbt_service"]
)