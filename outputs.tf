output "dbt_service_url" {
  value = google_cloud_run_service.dbt.status[0].url
}

output "dagster_service_url" {
  value = google_cloud_run_service.dagster.status[0].url
}