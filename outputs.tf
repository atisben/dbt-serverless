output "dbt_service_url" {
  value = google_cloud_run_service.dbt.status[0].url
}
