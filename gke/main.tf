terraform {
  required_version = ">= 0.12"
}

locals {
  location_parts = split("-", var.location)
  region         = format("%s-%s", local.location_parts[0], local.location_parts[1])
}

provider "google" {
  version = "~> 3.0"
  project = var.project_id
  region  = local.region
}

resource "google_compute_network" "network" {
  name                    = var.name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "nodes" {
  name                     = "${var.name}-nodes"
  region                   = local.region
  network                  = google_compute_network.network.self_link
  ip_cidr_range            = var.nodes_cidr
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = var.name
  region  = google_compute_subnetwork.nodes.region
  network = google_compute_network.network.self_link
}

resource "google_compute_address" "nat" {
  count  = var.nat_ip_count
  name   = "${var.name}-nat-${count.index}"
  region = google_compute_subnetwork.nodes.region
}

resource "google_compute_router_nat" "nat" {
  name                               = var.name
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  nat_ip_allocate_option             = "MANUAL_ONLY"
  nat_ips                            = google_compute_address.nat[*].self_link
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.nodes.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }
}

resource "google_container_cluster" "primary" {
  name                     = var.name
  location                 = var.location
  initial_node_count       = 1
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  min_master_version       = "latest"
  network                  = google_compute_network.network.self_link
  subnetwork               = google_compute_subnetwork.nodes.self_link
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.pods_cidr
    services_ipv4_cidr_block = var.services_cidr
  }
  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_cidr
  }
  workload_identity_config {
    identity_namespace = "${var.project_id}.svc.id.goog"
  }
  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = false
    }
  }
  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }
}

resource "google_container_node_pool" "primary" {
  name               = "primary"
  cluster            = google_container_cluster.primary.name
  location           = var.location
  initial_node_count = var.initial_node_count
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    machine_type = var.node_type
    preemptible  = var.node_preemptible
    disk_size_gb = var.node_disk_size_gb
    disk_type    = var.node_disk_type
    metadata = {
      disable-legacy-endpoints = "true"
    }
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }
}
