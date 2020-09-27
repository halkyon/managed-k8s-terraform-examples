project_id      = "my-project-123"
location        = "australia-southeast1-a"
name            = "mycluster"
node_pools = [
  {
    preemptible    = true
    min_node_count = 1
    max_node_count = 12
    machine_type   = "e2-medium"
    disk_type      = "pd-ssd"
    disk_size_gb   = 20
  }
]
