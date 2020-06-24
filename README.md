# Example EKS cluster using Terraform

This repository showcases using Terraform to provision a new VPC and Elastic Kubernetes Service (EKS) cluster with nodes within.

By default, this will create a highly available cluster using public and private subnets, a best practise for production environments.

## Setup variables

In `terraform.tfvars` set the variables you'd like.

`name` and `region` must be defined, everything else is optional.

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

Documentation to check out:
* [EKS user guide](https://docs.aws.amazon.com/eks/latest/userguide)
* [Terraform EKS cluster reference](https://www.terraform.io/docs/providers/aws/r/eks_cluster.html)

Other things:
* Set up the [Kubernetes dashboard](https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html)
* Set up [cluster-autoscaler](https://docs.aws.amazon.com/eks/latest/userguide/cluster-autoscaler.html)
* Configure [control plane logging](https://docs.aws.amazon.com/eks/latest/userguide/control-plane-logs.html)
* Use [Calico for network policy enforcement](https://docs.aws.amazon.com/eks/latest/userguide/calico.html)
* Restrict access to Kubernetes API server with a whitelist
