variable "project" {
  type        = string
  description = "Google Cloud Platform Project ID"
}

variable "service_name" {
    type = string
    description = "Name of the service as rendered in the google cloud services"
}

variable "region" {
  default = "europe-west1"
  type    = string
}

variable "dbt_project_dir"{
  type    = string
  description = "Name of the dbt project used during the dbt init"
}