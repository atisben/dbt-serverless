

resource "google_cloud_run_job" "dbt-job" {
  name          = "dbt-job"
  location      = "${var.region}"
  image         = "gcr.io/${var.project}/dbt-service:latest"
  command       = ["dbt", "run"]
  service_account_name = "serviceAccount:${google_service_account.dbt_worker.email}"
  timeout_seconds = 3600
}

output "dbt-job-url" {
  value = data.google_cloud_run_service.dbt-job.status[0].url
}

resource "google_cloud_scheduler_job" "example" {
  name           = "example"
  schedule       = "0 0 * * *"
  time_zone      = "UTC"
  target_service = google_cloud_run_service.dbt-job.status[0].url # Use the URL output from google_cloud_run_service

  http_target {
    http_method = "POST"
    uri         = "https://${google_cloud_run_service.dbt-job.status[0].url}/" # Use the URL output from google_cloud_run_service in the URI
    body        = jsonencode({
      "input": "my-input"
    })
    headers = {
      "Content-Type" = "application/json"
    }
  }
}