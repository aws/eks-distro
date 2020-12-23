## Starting a Cluster

Before you start your cluster, you need to get several container images.
Container images can be accessed either from the public ECR registry or
built from scratch.

### EKS Distro Container Images

You can pull the images that make up the EKS Distro from the Public ECR Gallery,
and a [pull-all.sh shell
script](https://github.com/aws/eks-distro/blob/main/development/pull-all.sh) is
provided to demonstrate how to do this. You can also browse the [EKS Distro
Container Repository](https://gallery.ecr.aws/?searchTerm=eks-distro&verified=verified)

### Building Your Own Container Images
See the [Build Guide](build.md) for more information about building your own
container images.

## Create cluster scripts

You can deploy EKS Distro any way you like, but we use kOps for testing. You
may like to use the testing scripts which are documented in this
[README](https://github.com/aws/eks-distro/blob/main/development/kops/README.md).
