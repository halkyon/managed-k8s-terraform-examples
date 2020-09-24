variable "project_id" {
  type        = string
  description = "GCP project the cluster should reside in."
}

variable "location" {
  type        = string
  description = <<EOF
Location in GCP the cluster should reside in.
This can be either a region, or a zone (for single-zone clusters.)
See https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability
EOF
}

variable "name" {
  type        = string
  description = "Name of the cluster."
}

variable "release_channel" {
  type        = string
  default     = "REGULAR"
  description = <<EOF
Release channel for GKE cluster.
See https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels and
https://cloud.google.com/kubernetes-engine/docs/release-notes-stable
EOF
}

variable "version_prefix" {
  type        = string
  default     = "1.17."
  description = <<EOF
Version prefix for cluster and nodes. This version has to be available in the
selected release channel.
See https://www.terraform.io/docs/providers/google/d/container_engine_versions.html
EOF
}

variable "maintenance_start_time" {
  type        = string
  default     = "2020-01-01T14:00:00Z"
  description = <<EOF
Maintenance start time.
See https://cloud.google.com/kubernetes-engine/docs/how-to/maintenance-windows-and-exclusions
EOF
}

variable "maintenance_end_time" {
  type        = string
  default     = "2020-01-01T18:00:00Z"
  description = <<EOF
Maintenance end time.
See https://cloud.google.com/kubernetes-engine/docs/how-to/maintenance-windows-and-exclusions
EOF
}

variable "maintenance_recurrence" {
  type        = string
  default     = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR"
  description = <<EOF
Maintenance recurrence.
See https://cloud.google.com/kubernetes-engine/docs/how-to/maintenance-windows-and-exclusions
EOF
}

variable "nat_ip_count" {
  type        = number
  default     = 1
  description = <<EOF
Number of NAT IPs to provision.
See https://cloud.google.com/nat/docs/overview and
https://cloud.google.com/nat/docs/ports-and-addresses#ports
EOF
}

variable "initial_node_count" {
  type        = number
  default     = 1
  description = <<EOF
Initial node count. This is only used when first provisioning the cluster.
Any external changes made (i.e. autoscaling) will not be overwritten.
EOF
}

variable "min_node_count" {
  type        = number
  default     = 1
  description = "Minimum node count for autoscaling"
}

variable "max_node_count" {
  type        = number
  default     = 2
  description = "Maximum node count for autoscaling"
}

variable "node_type" {
  type        = string
  default     = "n1-standard-1"
  description = <<EOF
Machine type for nodes.
See https://cloud.google.com/compute/docs/machine-types and
https://cloud.google.com/compute/vm-instance-pricing
EOF
}

variable "node_preemptible" {
  type        = string
  default     = false
  description = <<EOF
Whether or not nodes are preemptible.
See https://cloud.google.com/compute/docs/instances/preemptible
EOF
}

variable "node_disk_type" {
  type        = string
  default     = "pd-ssd"
  description = <<EOF
Node disk type. Can be either "pd-standard" or "pd-ssd".
See https://cloud.google.com/compute/docs/disks/
EOF
}

variable "node_disk_size_gb" {
  type        = string
  default     = 100
  description = "Node disk size, in GB."
}

variable "master_cidr" {
  type        = string
  default     = "172.16.0.0/28"
  description = "Kubernetes control plane CIDR."
}

variable "master_authorized_networks_cidr_blocks" {
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "all"
    }
  ]
  description = "Network addresses to allow access to the Kubernetes control plane."
}

variable "nodes_cidr" {
  type        = string
  default     = "10.1.0.0/20"
  description = <<EOF
IP address range for node IPs.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "cluster_cidr" {
  type        = string
  default     = "/14"
  description = <<EOF
IP address range for the cluster pod IPs.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "services_cidr" {
  type        = string
  default     = "/20"
  description = <<EOF
IP address range of the services IPs in this cluster.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}
