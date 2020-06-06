variable "name" {}

variable "cluster_subnet_count" {
  default = 2
}

variable "node_subnet_count" {
  default = 2
}

variable "disk_size" {
  default = 100
}

variable "instance_type" {
  default = "t3.medium"
}
