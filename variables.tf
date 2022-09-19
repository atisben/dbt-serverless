variable "project" {
  type        = string
  description = "Google Cloud Platform Project ID"
}

variable "service_name" {
    type = string
}

variable "region" {
  default = "europe-west1"
  type    = string
}