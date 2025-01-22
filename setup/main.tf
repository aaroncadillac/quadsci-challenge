variable "region" {
  type = string
  default = "northamerica-south1"
}

variable "network_name" {
  type = string
}

variable "subnetwork_name" {
  type = string
}

variable "vertex_instance_type" {
  type = string
}

variable "gke_service_account_id" {
  type = string
}

variable "gke_service_account_name" {
  type = string
}

variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
}

variable "project_name" {
  type = string
}

variable "gke_cluster_name" {
  type = string
}

variable "gke_primary_node_name" {
  type = string
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

resource "google_workbench_instance" "vertex_instance" {
  name = "quadsci-vertex-instance"
  location = var.region
  
  gce_setup {
    machine_type      = var.vertex_instance_type
    disable_public_ip = true

    network_interfaces {
      network = var.network_name
      subnet  = var.subnetwork_name
    }
  }
}

resource "google_cloud_run_v2_service" "cloud_run_service" {
  name     = "quadsci-hello-world-service"
  location = var.region
  deletion_protection = false
  ingress = "INGRESS_TRAFFIC_INTERNAL_ONLY"

  template {
    containers {
      image = "image"
      ports {
        name = "http"
        container_port = 8000
      }
    }
  }
}

resource "google_service_account" "gke_service_account" {
  account_id   = var.gke_service_account_id
  display_name = var.gke_service_account_name
}

resource "google_container_cluster" "gke-cluster" {
  name                     = var.gke_cluster_name
  location                 = var.region
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_node" {
  name        = var.gke_primary_node_name
  location    = var.region
  cluster     = google_container_cluster.gke-cluster.name
  node_count  = 1

  node_config {
    preemptible     = true
    machine_type    = "e2-medium"
    service_account = google_service_account.gke_service_account.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  network_config {
    additional_node_network_configs {
      network = var.network_name
      subnetwork = var.subnetwork_name
    }

  }
}

output "vertex_uri" {
  value = google_workbench_instance.vertex_instance.proxy_uri
}

output "cloud_run_uri" {
  value = google_cloud_run_v2_service.cloud_run_service.uri
}

output "gke_endpoint" {
  value = google_container_cluster.gke-cluster.endpoint
}