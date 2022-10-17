

import os

from dagster_dbt import dbt_cli_resource
from dagster_service import assets
from dagster_service.assets import DBT_PROFILES, DBT_PROJECT_PATH

from dagster import load_assets_from_package_module, repository, with_resources


@repository
def dagster_project():
    return with_resources(
        load_assets_from_package_module(assets),
        {
            "dbt": dbt_cli_resource.configured(
                {
                    "project_dir": DBT_PROJECT_PATH,
                    "profiles_dir": DBT_PROFILES,
                },
            ),
        },
    )