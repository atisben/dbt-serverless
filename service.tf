# The Cloud Run service
resource "google_cloud_run_service" "dbt" {
  name                       = local.service_name_dbt
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = google_service_account.dbt_worker.email
      containers {
        image = "gcr.io/${var.project}/dbt-service"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata{
    annotations = {
        "run.googleapis.com/ingress" = "internal"
      }
  }

  depends_on = [google_project_service.run]
}


resource "google_cloud_run_service" "dagster" {
  name                       = local.service_name_dagster
  location                   = var.region
  autogenerate_revision_name = true

  template {
    spec {
      service_account_name = google_service_account.dbt_worker.email
      containers {
        image = "gcr.io/${var.project}/dagster-service"
      }
    }
  }
  traffic {
    percent         = 100
    latest_revision = true
  }
  metadata{
    annotations = {
        "run.googleapis.com/ingress" = "internal"
      }
  }

  depends_on = [google_project_service.run]
}
