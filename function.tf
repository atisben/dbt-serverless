# The pub sub topic
resource "google_pubsub_topic" "topic" {
  name = "pubsub-dbt"
}

# Create scheduler job with pubsub subscription
resource "google_cloud_scheduler_job" "job" {
  name        = "dbt-trigger"
  description = "trigger the dbt processing"
  time_zone   = "Europe/Paris"
  region      = var.region
  schedule    = "0 6 * * *"

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.topic.id
    data       = base64encode(jsonencode(tolist([
      {
        "endpoint"="${google_cloud_run_service.dbt.status[0].url}/test/cloudfunction",
        "cli"="test",
        "--profiles-dir"="profiles",
        "--project-dir"=var.dbt_project_dir,
        "--vars"={
          "yesterday"="(date.today() - timedelta(days=1)).strftime('%Y%m%d')",
          "day_before_yesterday"="(date.today() - timedelta(days=2)).strftime('%Y%m%d')",
          "start_year_month"="(date.today() - timedelta(days=1)).strftime('%Y_%m')",
          "first_day_of_month"="(date.today() - timedelta(days=1)).strftime('%Y%m01')",
          "year_month"="(date.today() - timedelta(days=1)).strftime('%Y%m')",
          }
      },
      {
        "endpoint"="${google_cloud_run_service.dbt.status[0].url}/test/cloudfunction",
        "cli"="run",
        "--profiles-dir"="profiles",
        "--project-dir"=var.dbt_project_dir,
        "--vars"={
          "yesterday"="(date.today() - timedelta(days=1)).strftime('%Y%m%d')",
          "day_before_yesterday"="(date.today() - timedelta(days=2)).strftime('%Y%m%d')",
          "start_year_month"="(date.today() - timedelta(days=1)).strftime('%Y_%m')",
          "first_day_of_month"="(date.today() - timedelta(days=1)).strftime('%Y%m01')",
          "year_month"="(date.today() - timedelta(days=1)).strftime('%Y%m')",
          }
      },
      ])))
  }
  depends_on = [
    google_cloud_run_service.dbt
  ]
}


# The Cloud Function
resource "google_cloudfunctions_function" "function" {
  name        = local.function_name
  description = "processing"
  runtime     = "python37"
  region      = var.region

  available_memory_mb   = 512
  source_archive_bucket = google_storage_bucket.source.name
  source_archive_object = google_storage_bucket_object.archive.name
  entry_point           = "pubsub_to_cloudrun"
  service_account_email = google_service_account.dbt_worker.email
   timeout              = 540

  event_trigger {
      event_type= "google.pubsub.topic.publish"
      resource= "projects/${var.project}/topics/pubsub-dbt"
    }

  depends_on = [google_project_service.cloudfunctions]
}

# A dedicated Cloud Storage bucket to store the zip source
resource "google_storage_bucket" "source" {
  name = "${var.project}-source"
}

# Create a fresh archive of the current function folder
data "archive_file" "function" {
  type        = "zip"
  output_path = "temp/function_code_${formatdate("YYYYMMDDhhmmss", timestamp())}.zip"
  source_dir  = local.function_folder
}

# The archive in Cloud Stoage uses the md5 of the zip file
# This ensures the Function is redeployed only when the source is changed.
resource "google_storage_bucket_object" "archive" {
  name = "${local.function_folder}_${data.archive_file.function.output_md5}.zip" # will delete old items

  bucket = google_storage_bucket.source.name
  source = data.archive_file.function.output_path

  depends_on = [data.archive_file.function]
}
