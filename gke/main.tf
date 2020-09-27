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

provider "google-beta" {
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

data "google_container_engine_versions" "versions" {
  provider       = google-beta
  location       = var.location
  version_prefix = var.version_prefix
}

resource "google_container_cluster" "primary" {
  provider                 = google-beta
  name                     = var.name
  location                 = var.location
  initial_node_count       = 1
  remove_default_node_pool = true
  enable_shielded_nodes    = true
  maintenance_policy {
    recurring_window {
      start_time = var.maintenance_start_time
      end_time   = var.maintenance_end_time
      recurrence = var.maintenance_recurrence
    }
  }
  release_channel {
    channel = var.release_channel
  }
  min_master_version = data.google_container_engine_versions.versions.latest_master_version
  node_version       = data.google_container_engine_versions.versions.latest_node_version
  network            = google_compute_network.network.self_link
  subnetwork         = google_compute_subnetwork.nodes.self_link
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_cidr
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

  # For vertically autoscaling pod resources.
  # See https://cloud.google.com/kubernetes-engine/docs/how-to/vertical-pod-autoscaling
  vertical_pod_autoscaling {
    enabled = true
  }

  # Some interesting configuration options for security.
  # See https://www.terraform.io/docs/providers/google/r/container_cluster.html
  #
  # database_encryption {
  #   state = "ENCRYPTED"
  #   key_name = "projects/[KEY_PROJECT_ID]/locations/[LOCATION]/keyRings/[RING_NAME]/cryptoKeys/[KEY_NAME]"
  # }
  # boot_disk_kms_key = "projects/[KEY_PROJECT_ID]/locations/[LOCATION]/keyRings/[RING_NAME]/cryptoKeys/[KEY_NAME]"
  # sandbox_config {
  #   sandbox_type = "gvisor"
  # }
  # pod_security_policy_config {
  #   enabled = true
  # }
  # network_policy {
  #   enabled  = true
  #   provider = "CALICO"
  # }
  # addons_config {
  #   network_policy_config {
  #     disabled = false
  #   }
  # }
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

resource "google_container_node_pool" "node_pool" {
  count              = length(var.node_pools)
  name               = format("%s-pool", lookup(var.node_pools[count.index], "name", format("%03d", count.index + 1)))
  cluster            = google_container_cluster.primary.name
  location           = var.location
  initial_node_count = lookup(var.node_pools[count.index], "initial_node_count", 1)
  autoscaling {
    min_node_count = lookup(var.node_pools[count.index], "min_node_count", 1)
    max_node_count = lookup(var.node_pools[count.index], "max_node_count", 2)
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
    machine_type = lookup(var.node_pools[count.index], "machine_type", "n1-standard-1")
    preemptible  = lookup(var.node_pools[count.index], "preemptible", false)
    disk_size_gb = lookup(var.node_pools[count.index], "disk_size_gb", 40)
    disk_type    = lookup(var.node_pools[count.index], "disk_type", "pd-standard")
    metadata = {
      disable-legacy-endpoints = "true"
    }
    shielded_instance_config {
      enable_integrity_monitoring = true
      enable_secure_boot          = true
    }
  }
  # Allow external changes to initial_node_count without interference from Terraform.
  lifecycle {
    ignore_changes = [initial_node_count]
  }
}
