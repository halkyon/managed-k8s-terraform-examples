project_id      = "my-project-123"
location        = "australia-southeast1-a"
name            = "mycluster"

node_pools = [
  {
    name               = "nodes-preemptible"
    preemptible        = true
    initial_node_count = 1
    min_node_count     = 1
    max_node_count     = 8
    machine_type       = "n2-standard-2"
    disk_type          = "pd-standard"
    disk_size_gb       = 40
    tags               = []
    labels = {
      preemptible = "true"
    }
  }
]