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

  service_folder = "service"
  service_name   = var.service_name

  deployment_name = "dbt"
  dbt_worker_sa  = "serviceAccount:${google_service_account.dbt_worker.email}"
}