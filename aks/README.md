# Example AKS cluster using Terraform

This repository showcases using Terraform to provision a new network and AKS cluster with nodes within.

## Install and configure

Ensure that `kubectl`, `az`, and `terraform` are installed first.

Initialise the Azure CLI if you haven't already:

```shell
az login
```

## Setup variables

Fill out `terraform.tfvars` with the variables you'd like.

Required variables are `location`, and `name`, the Azure location/region, and name you'd like your cluster.

For reference, running `az account list-locations -o table` will get a list of regions to use.

Availability zones can be configured for high availability [if the chosen region supports it](https://docs.microsoft.com/en-us/azure/aks/availability-zones#limitations-and-region-availability). An example `terraform.tfvars`:

```
name               = "mycluster"
location           = "westus2"
availability_zones = ["1", "2", "3"]
node_count         = 3
min_count          = 3
max_count          = 6
```

## Provisioning

```shell
terraform init
terraform apply
```

## Configure kubectl

```shell
az aks get-credentials --resource-group mycluster --name mycluster
```

## Test it works

```shell
kubectl get nodes -o wide
```

## Tearing down

```shell
terraform destroy
```

## What now?

* [AKS documentation](https://docs.microsoft.com/en-us/azure/aks/) for more information on AKS itself.
* [Terraform AKS documentation](https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html) for more details on customising the cluster.
