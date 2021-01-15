## Create an EKS Distro Cluster

The best way to create an EKS Distro cluster may be using one of our
[Partners](../community/partners.md). There are links and instructions on that
page for third party methods to install EKS-D.

You may also find a community supported installation method useful. Community
supported installation methods are found on our
[community supported installation page](install/index.md).

## Getting Container Images

If your cluster deploment does not automatically pull container images, you may
need to get them manually.  Container images can be accessed either from the
public ECR registry or built from scratch.

### EKS Distro Container Images

You can pull the images that make up the EKS Distro from the Public ECR Gallery,
and a [pull-all.sh shell
script](https://github.com/aws/eks-distro/blob/main/development/pull-all.sh) is
provided to demonstrate how to do this. You can also browse the [EKS Distro
Container Repository](https://gallery.ecr.aws/?searchTerm=eks-distro&verified=verified)


### Building Your Own Container Images
See the [Build Guide](build.md) for more information about building your own
container images.
