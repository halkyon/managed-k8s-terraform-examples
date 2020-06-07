variable "name" {}
variable "region" {}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "num_zones" {
  default = 2
}

variable "disk_size" {
  default = 100
}

variable "instance_type" {
  default = "t3.medium"
}

variable "desired_size" {
  default = 2
}

variable "min_size" {
  default = 2
}

variable "max_size" {
  default = 4
}
