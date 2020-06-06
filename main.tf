terraform {
  version = ">= 0.12"
}

provider "aws" {
  version = "~> 2.0"
  region  = var.region
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "${var.name}-vpc"
  }
}

# resource "aws_internet_gateway" "igw" {
#   vpc_id = aws_vpc.vpc.id
# }

# resource "aws_route_table" "publicroutetable" {
#   vpc_id = aws_vpc.vpc.id
#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_internet_gateway.igw.id
#   }
#   tags = {
#     Name = "${var.name}-public-routetable"
#   }
# }

# TODO: public subnet, route table and associations?
# TODO: security group allowing port 443 for k8s?

resource "aws_subnet" "public" {
  count                   = var.subnet_count
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 4, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  tags = {
    Name                     = "${var.name}-public-subnet-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_eks_cluster" "cluster" {
  name     = var.name
  role_arn = aws_iam_role.clusterrole.arn
  vpc_config {
    subnet_ids = aws_subnet.private[*].id
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
  ]
}

# TODO: security group allowing all TCP from public subnet?

resource "aws_subnet" "private" {
  count             = var.subnet_count
  availability_zone = data.aws_availability_zones.available.names[count.index]
  cidr_block        = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  vpc_id            = aws_vpc.vpc.id
  tags = {
    Name                                                    = "${var.name}-private-subnet-${count.index}"
    "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "shared"
    "kubernetes.io/role/internal-elb"                       = "1"
  }
}

resource "aws_eks_node_group" "nodegroup" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.name
  node_role_arn   = aws_iam_role.noderole.arn
  subnet_ids      = aws_subnet.private[*].id
  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }
  disk_size      = var.disk_size
  instance_types = [var.instance_type]
  # Allow external changes to autoscaling desired size without interference from Terraform
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "clusterrole" {
  name = "${var.name}-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "noderole" {
  name = "${var.name}-node-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.clusterrole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.clusterrole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.noderole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.noderole.name
}

output "endpoint" {
  value = aws_eks_cluster.example.endpoint
}
