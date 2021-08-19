# Amazon EKS Distro

Amazon **EKS Distro** (EKS-D) is a Kubernetes distribution based on and used by
Amazon Elastic Kubernetes Service (EKS) to create reliable and secure Kubernetes
clusters. With EKS-D, you can rely on the same versions of Kubernetes and its
dependencies deployed by Amazon EKS. This includes the latest upstream updates,
as well as extended security patching support. EKS-D follows the same Kubernetes
version release cycle as Amazon EKS, and we provide the bits here. EKS-D
provides the same software that has enabled tens of thousands of Kubernetes
clusters on Amazon EKS.

What is the difference between EKS (the AWS Kubernetes cloud service) and EKS-D?
The main difference is in how they are managed. EKS is a fully managed
Kubernetes platform, while EKS-D is available to install and manage yourself.
You can run EKS-D on-premises, in a cloud, or on your own systems. EKS-D
provides a path to having essentially the same Amazon EKS Kubernetes distribution
running wherever you need to run it.

Once EKS-D is running, you are responsible for managing and
upgrading it yourself. For end users, however, running applications is the
same as with EKS since the two support the same API versions and
same set of components.

In the near future, a supported, packaged product and installation method
for EKS-D will be available under the name EKS Anywhere (EKS-A). To try out
EKS-D for now, instructions in this repository describe how to:

* Build EKS-D from source code

* Install EKS-D using kOps or other installation methods

Check out EKS Distro's [Starting a cluster](users/index.md) page or
refer to the [Build](users/build.md) instructions to build a cluster from scratch.
See the [Partners](users/install/partners.md) page for links to third-party methods for
installing EKS-D.

## Project Tenets (unless you know better ones)

The tenets of the EKS Distro (EKS-D) project are:

1. **The Source**: The goal of the EKS Distro is to be the Kubernetes source for EKS and EKS Anywhere
2. **Simple**: Make using a Kubernetes distribution simple and boring (reliable and secure)
3. **Opinionated Modularity**: Provide opinionated defaults about the best components to include with Kubernetes but give customers the ability to swap them out
4. **Open**: Provide open source tooling backed, validated and maintained by Amazon
5. **Ubiquitous**: Enable customers and partners to integrate a Kubernetes distribution in the most common tooling (Kubernetes installers and distributions, infrastructure as code, and more)
6. **Stand Alone**: Provided for use anywhere without AWS dependencies
7. **Better with AWS**: Enable AWS customers to adopt additional AWS services easily

## Release Channels

The EKS Distro releases Kubernetes versions at the same pace as EKS and issues 
updates as releases in release channels. A release channel tracks minor
versions (`v<major>.<minor>.<point>`) of Kubernetes, and a channel will be
retired when EKS ceases supporting a particular minor version of Kubernetes.
EKS Distro announces new releases and release channels via an SNS topic 
(arn:aws:sns:us-east-1:379412251201:eks-distro-updates) at their launched.
Releases and release channels are structured as Kubernetes Custom
Resource Definitions
([CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)),
and the schema can be found in the
[eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/tree/main/release)
GitHub repository.

You can install the CRD API type, the release channel manifest for EKS-D, and
view the release channel by running the following commands:

```bash
RELEASE_BRANCH=1-21
kubectl apply -f https://distro.eks.amazonaws.com/crds/releasechannels.distro.eks.amazonaws.com-v1alpha1.yaml
kubectl apply -f https://distro.eks.amazonaws.com/releasechannels/${RELEASE_BRANCH}.yaml
kubectl get -o yaml releasechannels
```

## Releases

Releases of the EKS Distro are in-step with versions of components used by or
recommended for use with Amazon EKS. EKS Distro also includes the following
components:

* CNI plugins
* CoreDNS
* etcd
* CSI Sidecars
* aws-iam-authenticator
* Kubernetes Metrics Server
* Kubernetes

All container images for these components are based on Amazon Linux 2 and are
available on the ECR Public Gallery for amd64 and arm64 architectures. New
releases of EKS Distro will be created when there is an updated component version,
a required update in the Amazon Linux 2 base image, or a change required in the build
toolchain (ex: a Go version update).

There are components of Kubernetes, CNI, etcd, and aws-iam-authenticator
that are not delivered as container images. These components are available as
compressed tar archive and executable files. The files have associated sha256
and sha512 sum files provided in release manifests. They are available for download
with names similar to the file (ex: `https://distro.eks.amazonaws.com/..../kubectl.sha256`)

A list of all the components and assets that make up a release, including URIs
to all the compressed archives, binaries, and container images, is available in
the release manifests. You can install the CRD API type, the release
manifest for EKS Distro, and view the release by running the following
commands:

```bash
RELEASE_BRANCH=1-21
RELEASE=3
kubectl apply -f https://distro.eks.amazonaws.com/crds/releases.distro.eks.amazonaws.com-v1alpha1.yaml
kubectl apply -f https://distro.eks.amazonaws.com/kubernetes-${RELEASE_BRANCH}/kubernetes-${RELEASE_BRANCH}-eks-${RELEASE}.yaml
kubectl get release kubernetes-${RELEASE_BRANCH}-eks-${RELEASE}
kubectl get release kubernetes-${RELEASE_BRANCH}-eks-${RELEASE} -o yaml
```

### Release Version Dependencies

The EKS Distro of Kubernetes source repository does not include any AMIs (Amazon
Machine Images), but it does use the EKS Optimized AMI. See the project
repository for the [EKS Optimized AMI](https://github.com/awslabs/amazon-eks-ami)
if you are interested in the AL2 container runtime kernel version.

#### EKS-D 1.21 Version Dependencies
* [v1-21-eks-3](releases/1-21/3/index.md) (August 6, 2021)
* [v1-21-eks-2](releases/1-21/2/index.md) (July 27, 2021)
* [v1-21-eks-1](releases/1-21/1/index.md) (July 19, 2021)

#### EKS-D 1.20 Version Dependencies
* [v1-20-eks-5](releases/1-20/5/index.md) (August 6, 2021)
* [v1-20-eks-4](releases/1-20/4/index.md) (July 27, 2021)
* [v1-20-eks-3](releases/1-20/3/index.md) (July 13, 2021)
* [v1-20-eks-2](releases/1-20/2/index.md) (June 30, 2021)
* [v1-20-eks-1](releases/1-20/1/index.md) (May 18, 2021)

#### EKS-D 1.19 Version Dependencies
* [v1-19-eks-8](releases/1-19/8/index.md) (August 8, 2021)
* [v1-19-eks-7](releases/1-19/7/index.md) (July 27, 2021)
* [v1-19-eks-6](releases/1-19/6/index.md) (July 13, 2021)
* [v1-19-eks-5](releases/1-19/5/index.md) (June 30, 2021)
* [v1-19-eks-4](releases/1-19/4/index.md) (May 6, 2021)
* [v1-19-eks-3](releases/1-19/3/index.md) (April 16, 2021)
* [v1-19-eks-2](releases/1-19/2/index.md) (March 30, 2021)
* [v1-19-eks-1](releases/1-19/1/index.md) (March 4, 2021)

#### EKS-D 1.18 Version Dependencies
* [v1-18-eks-10](releases/1-18/10/index.md) (August 18, 2021)
* [v1-18-eks-9](releases/1-18/9/index.md) (August 6, 2021)
* [v1-18-eks-8](releases/1-18/8/index.md) (July 27, 2021)
* [v1-18-eks-7](releases/1-18/7/index.md) (July 13, 2021)
* [v1-18-eks-6](releases/1-18/6/index.md) (June 30, 2021)
* [v1-18-eks-5](releases/1-18/5/index.md) (May 27, 2021)
* [v1-18-eks-4](releases/1-18/4/index.md) (May 5, 2021)
* [v1-18-eks-3](releases/1-18/3/index.md) (April 16, 2021)
* [v1-18-eks-2](releases/1-18/2/index.md) (March 30, 2021)
* [v1-18-eks-1](releases/1-18/1/index.md) (December 9, 2020)
