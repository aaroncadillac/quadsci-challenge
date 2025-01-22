variable "region" {
  type = string
  default = "northamerica-south1"
}

variable "project_name" {
  type = string
}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
}

provider "google" {
  credentials = file("quadsci-access.json")
  project = "quadsci-exercise-aaron"
  region  = var.region
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = var.project_name
  service = each.key
}