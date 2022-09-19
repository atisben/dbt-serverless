# The Cloud Run service
resource "google_cloud_run_service" "dbt" {
  name                       = local.service_name
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = google_service_account.dbt_worker.email
      containers {
        image = "gcr.io/${var.project}/dbt-service"
        env {
          name  = "BUCKET_NAME"
          value = "test"
        }
        # env {
        #   name  = "FUNCTION_NAME"
        #   value = google_cloudfunctions_function.function.https_trigger_url
        # }
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
  }

  depends_on = [google_project_service.run]
}

# Set service access
resource "google_cloud_run_service_iam_binding" "binding" {
  location = google_cloud_run_service.dbt.location
  service = google_cloud_run_service.dbt.name
  role = "roles/run.invoker"
  members = ["serviceAccount:${google_service_account.dbt_worker.email}"]
}

