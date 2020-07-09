variable "name" {
  description = "Name of cluster."
}

variable "location" {
  description = <<EOF
Azure region to use.
Use `az account list-locations -o table` to get a list of regions.
EOF
}

variable "network_cidr" {
  default     = "10.1.0.0/16"
  description = "CIDR for network containing the cluster."
}

variable "nodes_cidr" {
  default     = "10.1.0.0/20"
  description = "CIDR for subnet where nodes will reside."
}

variable "availability_zones" {
  default     = []
  description = <<EOF
List of availability zones that cluster and nodes spread across for high availability.
e.g. ["1", "2", "3"] for three zones. Not all regions support zones.
See https://docs.microsoft.com/en-us/azure/aks/availability-zones#limitations-and-region-availability
EOF
}

variable "kubernetes_version" {
  default     = "1.16.9"
  description = <<EOF
Kubernetes version.
See https://github.com/Azure/AKS/releases
EOF
}

variable "os_disk_size_gb" {
  default     = 100
  description = "Disk side for nodes, in GB."
}

variable "max_pods_per_node" {
  default     = 250
  description = <<EOF
Maximum pods per node.
See https://docs.microsoft.com/en-us/azure/aks/configure-azure-cni
EOF
}

variable "vm_size" {
  default     = "Standard_D2_v2"
  description = <<EOF
VM size for nodes.
See https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sizes
EOF
}

variable "node_count" {
  default     = 1
  description = "Number of initial nodes to create."
}

variable "min_count" {
  default     = 1
  description = "Autoscaling minimum nodes."
}

variable "max_count" {
  default     = 2
  description = "Autoscaling maximum nodes."
}
