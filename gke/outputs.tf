output "location" {
  value = var.location
}

output "gke_cluster_name" {
  value = google_container_cluster.primary.name
}

