variable "name" {}
variable "region" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "subnet_count" {
  default = 2
}

variable "disk_size" {
  default = 100
}

variable "instance_type" {
  default = "t3.medium"
}
