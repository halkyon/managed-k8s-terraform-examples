# Example EKS cluster using Terraform

TODO: This is a work in progress and hasn't been fully tested yet!

This repository showcases using Terraform to provision a new VPC and EKS cluster with nodes within.

This deploys a highly available cluster using public and private subnets, a best practise for production environments.

## Setup variables

In `terraform.tfvars` set the variables you'd like.

`name` and `region` are required.

## Provisioning

```shell
terraform init
terraform apply
```

## Configure kubectl

See [this guide on setting up authentication](https://docs.aws.amazon.com/eks/latest/userguide/managing-auth.html).

## Test it works

```shell
kubectl get nodes -o wide
```

## Tearing down

```shell
terraform destroy
```

## What now?

Check out the [Terraform EKS cluster reference](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html) for more that can be customised.
