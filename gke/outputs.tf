output "location" {
  value = var.location
}

output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

output "channel" {
  value = var.release_channel
}

output "channel_default_version" {
  value = data.google_container_engine_versions.versions.release_channel_default_version[var.release_channel]
}

output "channel_latest_master_version" {
  value = data.google_container_engine_versions.versions.latest_master_version
}

output "channel_latest_node_version" {
  value = data.google_container_engine_versions.versions.latest_node_version
}

output "current_master_version" {
  value = google_container_cluster.primary.master_version
}

output "current_node_version" {
  value = google_container_cluster.primary.node_version
}

output "network" {
  value = google_compute_network.network.name
}

output "subnetwork_nodes" {
  value = google_compute_subnetwork.nodes.name
}

output "nodes_cidr" {
  value = google_compute_subnetwork.nodes.ip_cidr_range
}

output "cluster_cidr" {
  value = google_container_cluster.primary.cluster_ipv4_cidr
}

output "services_cidr" {
  value = google_container_cluster.primary.services_ipv4_cidr
}

output "nat_ips" {
  value = google_compute_address.nat[*].address
}
