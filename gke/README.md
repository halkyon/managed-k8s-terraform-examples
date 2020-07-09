# Example GKE cluster using Terraform

This repository showcases using Terraform to provision a new network and a GKE cluster with nodes within.

By default, this will create a highly available cluster using a [NAT gateway](https://cloud.google.com/nat/docs/overview#example-gke) for outgoing traffic from private nodes.

See a [high level overview of the GKE architecture](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-architecture).

## Install and configure

Ensure that `kubectl`, `gcloud`, and `terraform` are installed first.

Ensure the [Google Cloud CLI tools](https://cloud.google.com/sdk/docs/quickstarts) are initalised:

```shell
gcloud init
```

Once initialised, ensure your account is added to the Application Default Credentials (ADC) so Terraform can access them:

```shell
gcloud auth application-default login
```

## Setup variables

In `terraform.tfvars` set the details according to your Google Cloud account.

`project_id`, `location`, and `name` are required to be set.

`location` can be set to a region or zone. See [regional or zone specific cluster docs for more information](https://cloud.google.com/kubernetes-engine/docs/concepts/types-of-clusters#availability).

An example `terraform.tfvars` file of using a single zone cluster with [preemptible nodes](https://cloud.google.com/compute/docs/instances/preemptible):

```
project_id         = "my-project-123"
location           = "australia-southeast1-a"
name               = "mycluster"
node_type          = "n1-standard-1"
node_disk_type     = "pd-standard"
node_disk_size_gb  = 40
node_preemptible   = true
initial_node_count = 1
min_node_count     = 1
max_node_count     = 2
```

Check out a [list of Google Cloud regions and zones](https://cloud.google.com/compute/docs/regions-zones) for reference.

## Provisioning

```shell
terraform init
terraform apply
```

## Configure kubectl

Retrieve the cluster name and location using `terraform show`, then initialise `kubectl` configuration:

```shell
gcloud container clusters get-credentials mycluster --region australia-southeast1-a
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

Check out [`google_container_cluster` Terraform docs](https://www.terraform.io/docs/providers/google/r/container_cluster.html) 
for more details on what GKE parameters can be changed using Terraform.

Some other things:
* [General GKE docs](https://cloud.google.com/kubernetes-engine/docs)
* [Hardening your cluster's security](https://cloud.google.com/kubernetes-engine/docs/how-to/hardening-your-cluster)
