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
  service_name   = "data-checker"
  service_account  = "serviceAccount:${google_service_account.service_account.email}"
}

# Enable Cloud run service
resource "google_project_service" "run" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable IAM service
resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

# Enable CloudBuild service
resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Scheduler service
resource "google_project_service" "scheduler" {
  service = "cloudscheduler.googleapis.com"
}

# Create the service account
resource "google_service_account" "service_account" {
  account_id   = "${local.service_name}"
  display_name = "${local.service_name} Service Account"
  description  = "Service account used by ${local.service_name} to trigger automated Cloud Run jobs"
}

# Set permissions
data "google_iam_policy" "private" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.service_account.email}",
    ]
  }
}

# Set permissions for the service account
resource "google_project_iam_binding" "service_permissions" {
  for_each = toset([
    "bigquery.dataEditor", "bigquery.jobUser", "storage.objectViewer"
  ])
  project    = "${var.project}"
  role       = "roles/${each.key}"
  members    = [local.service_account]
  depends_on = [google_service_account.service_account]
}

# Create the storage bucket
resource "google_storage_bucket" "storage_bucket" {
  name = "${var.project}-${local.service_name}"
  storage_class = "REGIONAL"
  location = var.region
}
