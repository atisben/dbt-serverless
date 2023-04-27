
resource "google_cloud_run_v2_job" "default" {
  name     = "${local.service_name}"
  location = "europe-west1"

  template {
    template {
      containers {
        image = "gcr.io/${var.project}/dbt-service:latest" #TO MODIFY: change the name of the image if required
        args = [
          "dbt test --project-dir project --profiles-dir profiles && dbt run --models data_checker.*  --project-dir project --profiles-dir profiles"
        ]
      }
    }
  }
  depends_on = [google_project_service.run]
}


# Generate the scheduler that will trigger the cloud run job
resource "google_cloud_scheduler_job" "cloud_run_job" {
  name = "${local.service_name}-cloud-run-job"
  region = "${var.region}"
  schedule = "* 6 * * *"
  time_zone = "Europe/Paris"

  http_target {
    uri = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/${local.service_name}:run"
    http_method = "POST"
    headers = {User-Agent: "Google-Cloud-Scheduler"}
    oauth_token {
      service_account_email = google_service_account.service_account.email
      scope = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
  depends_on = [google_project_service.scheduler]
}