
resource "google_cloud_run_v2_service" "default" {
  name     = "cloudrun-service"
  location = "us-central1"
  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    containers {
      image = "gcr.io/${var.project}/dbt-service:latest"
      args = ["--bucket","test-datachecker", "--filename", "test-bastien.txt",  "--content", "nothing"]
    }
  }
}