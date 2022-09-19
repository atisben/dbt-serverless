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

# Set service public

# data "google_iam_policy" "noauth" {
#   binding {
#     role = "roles/run.invoker"
#     members = [
#       "allUsers",
#     ]
#   }
# }

# resource "google_cloud_run_service_iam_policy" "noauth" {
#   location = google_cloud_run_service.dbt.location
#   project  = google_cloud_run_service.dbt.project
#   service  = google_cloud_run_service.dbt.name

#   policy_data = data.google_iam_policy.noauth.policy_data
#   depends_on  = [google_cloud_run_service.dbt]
# }
