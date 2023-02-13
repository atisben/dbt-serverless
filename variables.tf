variable "project" {
  type        = string
  description = "Google Cloud Platform Project ID"
}

variable "service_name_dbt" {
    type = string
    description = "Name of the service as rendered in the google cloud services"
}

variable "service_name_dagster" {
    type = string
    description = "Name of the dagster service as rendered in the google cloud services"
}

variable "dbt_project_dir"{
  type    = string
  description = "Name of the dbt project initialized at the beggining of the project (default is dbt_service)"
}

variable "region" {
  default = "europe-west1"
  type    = string
}
