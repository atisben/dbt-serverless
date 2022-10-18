terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.53"
    }
  }
}

provider "google" {
  project = var.project
}

locals {
  function_folder = "function"
  function_name   = "check"

  service_folder = "services"
  service_name_dbt   = var.service_name_dbt
  service_name_dagster = var.service_name_dagster

  deployment_name = "dbt"
  dbt_worker_sa  = "serviceAccount:${google_service_account.dbt_worker.email}"
}