terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.46.0"
    }
  }
}

provider "google" {
  project = var.project
}

locals {
  function_name   = "check"
  service_folder = "services"
  service_name_dbt   = var.service_name_dbt
  deployment_name = "dbt"
  dbt_worker_sa  = "serviceAccount:${google_service_account.dbt_worker.email}"
}