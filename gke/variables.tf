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
Nodes CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "pods_cidr" {
  type        = string
  default     = "/14"
  description = <<EOF
Pods CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}

variable "services_cidr" {
  type        = string
  default     = "/20"
  description = <<EOF
Services CIDR.
See https://cloud.google.com/kubernetes-engine/docs/how-to/alias-ips#cluster_sizing
EOF
}
