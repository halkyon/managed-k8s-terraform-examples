variable "name" {
  type        = string
  description = "Name of the cluster."
}

variable "region" {
  type        = string
  description = "AWS region the cluster will reside in."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR."
}

variable "subnet_addtl_bits" {
  type        = number
  default     = 4
  description = <<EOF
Additional bits added to VPC CIDR, to determine subnet size.
e.g. a VPC CIDR of 10.0.0.0/16 and 4 additional bits will yield 10.0.*.0/20 subnets.
EOF
}

variable "num_zones" {
  type        = number
  default     = 2
  description = <<EOF
Number of availability zones the cluster will reside in.
This needs to be at least 2, due to EKS restrictions.
See https://aws.amazon.com/about-aws/global-infrastructure/regions_az/ for more details.
EOF
}

variable "disk_size" {
  type        = number
  default     = 100
  description = "Disk size for nodes, in GB."
}

variable "instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for nodes"
}

variable "desired_size" {
  type        = number
  default     = 2
  description = <<EOF
Autoscaling group desired size for nodes. This value is only used initially on cluster creation.
Changes made externally to this value (i.e. through the AWS console, or via autoscaling processes)
will not be overridden.
EOF
}

variable "min_size" {
  type        = number
  default     = 2
  description = "Autoscaling group minimum size for nodes."
}

variable "max_size" {
  type        = number
  default     = 4
  description = "Autoscaling group maximum size for nodes."
}
