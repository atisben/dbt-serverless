# Enable services
resource "google_project_service" "run" {
  service = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cloudbuild" {
  service = "cloudbuild.googleapis.com"
  disable_on_destroy = false
}

# Create a service account
resource "google_service_account" "dbt_worker" {
  account_id   = "dbt-worker"
  display_name = "dbt worker SA"
  description  = "Identity used by a public Cloud Run service to call private Cloud Run services."
}

# Set permissions
data "google_iam_policy" "private" {
  binding {
    role = "roles/run.invoker"
    members = [
      "serviceAccount:${google_service_account.dbt_worker.email}",
    ]
  }
}


# Set permissions
resource "google_project_iam_binding" "service_permissions" {
  for_each = toset([
    "bigquery.dataEditor", "bigquery.jobUser", "storage.objectViewer"
  ])
  project    = "${var.project}"
  role       = "roles/${each.key}"
  members    = [local.dbt_worker_sa]
  depends_on = [google_service_account.dbt_worker]
}

# Create the storage bucket
resource "google_storage_bucket" "storage_bucket" {
  name = "${var.project}-${var.service_name_dbt}"
  storage_class = "REGIONAL"
  location = var.region
}
