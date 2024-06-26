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

A supported installation method for EKS-D is available with [EKS
Anywhere (EKS-A)][eks-a]. To try out EKS-D without EKS-A, the instructions in
this website describe how to:

[eks-a]: https://anywhere.eks.amazonaws.com/

* Build EKS-D from source code

* Install EKS-D using kOps or other installation methods

Check out EKS Distro's [Starting a cluster](users/index.md) page.
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

EKS Distro releases Kubernetes versions at the same pace as EKS and issues
updates as releases in release channels. A release channel tracks minor
versions (`v<major>.<minor>.<point>`) of Kubernetes, and a channel will be
retired when EKS ceases supporting a particular minor version of Kubernetes.
EKS Distro announces new releases and release channels via an SNS topic
(arn:aws:sns:us-east-1:379412251201:eks-distro-updates) at their launch.
Releases and release channels are structured as Kubernetes Custom
Resource Definitions
([CRDs](https://kubernetes.io/docs/concepts/extend-kubernetes/api-extension/custom-resources/)),
and the schema can be found in the
[eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/tree/main/release)
GitHub repository.

You can install the CRD API type, the release channel manifest for EKS-D, and
view the release channel by running the following commands:

```bash
RELEASE_BRANCH=1-30
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
RELEASE_BRANCH=1-30
RELEASE=8
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

#### EKS-D 1.30 Version Dependencies
* [v1-30-eks-8](releases/1-30/8/index.md) (June 24, 2024)
* [v1-30-eks-7](releases/1-30/7/index.md) (June 07, 2024)
* [v1-30-eks-6](releases/1-30/6/index.md) (May 31, 2024)
* [v1-30-eks-5](releases/1-30/5/index.md) (May 28, 2024)

#### EKS-D 1.29 Version Dependencies
* [v1-29-eks-15](releases/1-29/15/index.md) (June 24, 2024)
* [v1-29-eks-14](releases/1-29/14/index.md) (June 07, 2024)
* [v1-29-eks-13](releases/1-29/13/index.md) (May 31, 2024)
* [v1-29-eks-12](releases/1-29/12/index.md) (May 28, 2024)
* [v1-29-eks-11](releases/1-29/11/index.md) (May 13, 2024)
* [v1-29-eks-10](releases/1-29/10/index.md) (April 29, 2024)
* [v1-29-eks-9](releases/1-29/9/index.md) (April 12, 2024)
* [v1-29-eks-8](releases/1-29/8/index.md) (March 29, 2024)
* [v1-29-eks-7](releases/1-29/7/index.md) (March 15, 2024)
* [v1-29-eks-6](releases/1-29/6/index.md) (March 01, 2024)
* [v1-29-eks-5](releases/1-29/5/index.md) (February 19, 2024)
* [v1-29-eks-4](releases/1-29/4/index.md) (February 01, 2024)
* [v1-29-eks-3](releases/1-29/3/index.md) (January 19, 2024)
* [v1-29-eks-2](releases/1-29/2/index.md) (January 5, 2024)
* [v1-29-eks-1](releases/1-29/1/index.md) (December 16, 2023)

#### EKS-D 1.28 Version Dependencies
* [v1-28-eks-26](releases/1-28/26/index.md) (June 24, 2024)
* [v1-28-eks-25](releases/1-28/25/index.md) (June 07, 2024)
* [v1-28-eks-24](releases/1-28/24/index.md) (May 31, 2024)
* [v1-28-eks-23](releases/1-28/23/index.md) (May 28, 2024)
* [v1-28-eks-22](releases/1-28/22/index.md) (May 13, 2024)
* [v1-28-eks-21](releases/1-28/21/index.md) (April 29, 2024)
* [v1-28-eks-20](releases/1-28/20/index.md) (April 12, 2024)
* [v1-28-eks-19](releases/1-28/19/index.md) (March 29, 2024)
* [v1-28-eks-18](releases/1-28/18/index.md) (March 15, 2024)
* [v1-28-eks-17](releases/1-28/17/index.md) (March 01, 2024)
* [v1-28-eks-16](releases/1-28/16/index.md) (February 19, 2024)
* [v1-28-eks-15](releases/1-28/15/index.md) (February 01, 2024)
* [v1-28-eks-14](releases/1-28/14/index.md) (January 19, 2024)
* [v1-28-eks-13](releases/1-28/13/index.md) (January 05, 2024)
* [v1-28-eks-12](releases/1-28/12/index.md) (December 22, 2023)
* [v1-28-eks-11](releases/1-28/11/index.md) (December 08, 2023)
* [v1-28-eks-10](releases/1-28/10/index.md) (November 28, 2023)
* [v1-28-eks-9](releases/1-28/9/index.md) (November 10, 2023)
* [v1-28-eks-8](releases/1-28/8/index.md) (October 27, 2023)
* [v1-28-eks-7](releases/1-28/7/index.md) (October 13, 2023)
* [v1-28-eks-6](releases/1-28/6/index.md) (September 28, 2023)
* [v1-28-eks-5](releases/1-28/5/index.md) (September 14, 2023)
* [v1-28-eks-4](releases/1-28/4/index.md) (September 7, 2023)
* [v1-28-eks-3](releases/1-28/3/index.md) (August 31, 2023)
* [v1-28-eks-2](releases/1-28/2/index.md) (August 17, 2023)
* [v1-28-eks-1](releases/1-28/1/index.md) (August 3, 2023)


#### EKS-D 1.27 Version Dependencies
* [v1-27-eks-33](releases/1-27/33/index.md) (June 24, 2024)
* [v1-27-eks-32](releases/1-27/32/index.md) (June 07, 2024)
* [v1-27-eks-31](releases/1-27/31/index.md) (May 31, 2024)
* [v1-27-eks-30](releases/1-27/30/index.md) (May 28, 2024)
* [v1-27-eks-29](releases/1-27/29/index.md) (May 13, 2024)
* [v1-27-eks-28](releases/1-27/28/index.md) (April 29, 2024)
* [v1-27-eks-27](releases/1-27/27/index.md) (April 12, 2024)
* [v1-27-eks-26](releases/1-27/26/index.md) (March 29, 2024)
* [v1-27-eks-25](releases/1-27/25/index.md) (March 15, 2024)
* [v1-27-eks-24](releases/1-27/24/index.md) (March 01, 2024)
* [v1-27-eks-23](releases/1-27/23/index.md) (February 19, 2024)
* [v1-27-eks-22](releases/1-27/22/index.md) (February 01, 2024)
* [v1-27-eks-21](releases/1-27/21/index.md) (January 19, 2024)
* [v1-27-eks-20](releases/1-27/20/index.md) (January 05, 2024)
* [v1-27-eks-19](releases/1-27/19/index.md) (December 22, 2023)
* [v1-27-eks-18](releases/1-27/18/index.md) (December 08, 2023)
* [v1-27-eks-17](releases/1-27/17/index.md) (November 28, 2023)
* [v1-27-eks-16](releases/1-27/16/index.md) (November 10, 2023)
* [v1-27-eks-15](releases/1-27/15/index.md) (October 27, 2023)
* [v1-27-eks-14](releases/1-27/14/index.md) (October 13, 2023)
* [v1-27-eks-13](releases/1-27/13/index.md) (September 28, 2023)
* [v1-27-eks-12](releases/1-27/12/index.md) (September 15, 2023)
* [v1-27-eks-11](releases/1-27/11/index.md) (September 01, 2023)
* [v1-27-eks-10](releases/1-27/10/index.md) (August 17, 2023)
* [v1-27-eks-9](releases/1-27/9/index.md) (August 04, 2023)
* [v1-27-eks-8](releases/1-27/8/index.md) (July 20, 2023)
* [v1-27-eks-7](releases/1-27/7/index.md) (July 06, 2023)
* [v1-27-eks-6](releases/1-27/6/index.md) (June 22, 2023)
* [v1-27-eks-5](releases/1-27/5/index.md) (June 09, 2023)
* [v1-27-eks-4](releases/1-27/4/index.md) (May 24, 2023)
* [v1-27-eks-3](releases/1-27/3/index.md) (May 24, 2023)
* [v1-27-eks-2](releases/1-27/2/index.md) (May 24, 2023)
* [v1-27-eks-1](releases/1-27/1/index.md) (May 24, 2023)

#### EKS-D 1.26 Version Dependencies (DEPRECATED)
* [v1-26-eks-39](releases/1-26/39/index.md) (June 24, 2024)
* [v1-26-eks-38](releases/1-26/38/index.md) (June 07, 2024)
* [v1-26-eks-37](releases/1-26/37/index.md) (May 31, 2024)
* [v1-26-eks-36](releases/1-26/36/index.md) (May 28, 2024)
* [v1-26-eks-35](releases/1-26/35/index.md) (May 13, 2024)
* [v1-26-eks-34](releases/1-26/34/index.md) (April 29, 2024)
* [v1-26-eks-33](releases/1-26/33/index.md) (April 12, 2024)
* [v1-26-eks-32](releases/1-26/32/index.md) (March 29, 2024)
* [v1-26-eks-31](releases/1-26/31/index.md) (March 15, 2024)
* [v1-26-eks-30](releases/1-26/30/index.md) (March 01, 2024)
* [v1-26-eks-29](releases/1-26/29/index.md) (February 19, 2024)
* [v1-26-eks-28](releases/1-26/28/index.md) (February 01, 2024)
* [v1-26-eks-27](releases/1-26/27/index.md) (January 19, 2024)
* [v1-26-eks-26](releases/1-26/26/index.md) (January 05, 2024)
* [v1-26-eks-25](releases/1-26/25/index.md) (December 22, 2023)
* [v1-26-eks-24](releases/1-26/24/index.md) (December 08, 2023)
* [v1-26-eks-23](releases/1-26/23/index.md) (November 28, 2023)
* [v1-26-eks-22](releases/1-26/22/index.md) (November 10, 2023)
* [v1-26-eks-21](releases/1-26/21/index.md) (October 27, 2023)
* [v1-26-eks-20](releases/1-26/20/index.md) (October 13, 2023)
* [v1-26-eks-19](releases/1-26/19/index.md) (September 28, 2023)
* [v1-26-eks-18](releases/1-26/18/index.md) (September 15, 2023)
* [v1-26-eks-17](releases/1-26/17/index.md) (September 01, 2023)
* [v1-26-eks-16](releases/1-26/16/index.md) (August 17, 2023)
* [v1-26-eks-15](releases/1-26/15/index.md) (August 04, 2023)
* [v1-26-eks-14](releases/1-26/14/index.md) (July 20, 2023)
* [v1-26-eks-13](releases/1-26/13/index.md) (July 06, 2023)
* [v1-26-eks-12](releases/1-26/12/index.md) (June 22, 2023)
* [v1-26-eks-11](releases/1-26/11/index.md) (June 09, 2023)
* [v1-26-eks-10](releases/1-26/10/index.md) (May 24, 2023)
* [v1-26-eks-9](releases/1-26/9/index.md) (May 11, 2023)
* [v1-26-eks-8](releases/1-26/8/index.md) (April 27, 2023)
* [v1-26-eks-7](releases/1-26/7/index.md) (April 13, 2023)
* [v1-26-eks-6](releases/1-26/6/index.md) (March 29, 2023)
* [v1-26-eks-5](releases/1-26/5/index.md) (March 15, 2023)
* [v1-26-eks-4](releases/1-26/4/index.md) (March 10, 2023)
* [v1-26-eks-3](releases/1-26/3/index.md) (February 23, 2023)
* [v1-26-eks-2](releases/1-26/2/index.md) (February 22, 2023)
* [v1-26-eks-1](releases/1-26/1/index.md) (February 8, 2023)

#### EKS-D 1.25 Version Dependencies (DEPRECATED)
* [v1-25-eks-40](releases/1-25/40/index.md) (May 28, 2024)
* [v1-25-eks-39](releases/1-25/39/index.md) (May 13, 2024)
* [v1-25-eks-38](releases/1-25/38/index.md) (April 29, 2024)
* [v1-25-eks-37](releases/1-25/37/index.md) (April 12, 2024)
* [v1-25-eks-36](releases/1-25/36/index.md) (March 29, 2024)
* [v1-25-eks-35](releases/1-25/35/index.md) (March 15, 2024)
* [v1-25-eks-34](releases/1-25/34/index.md) (March 01, 2024)
* [v1-25-eks-33](releases/1-25/33/index.md) (February 19, 2024)
* [v1-25-eks-32](releases/1-25/32/index.md) (February 01, 2024)
* [v1-25-eks-31](releases/1-25/31/index.md) (January 19, 2024)
* [v1-25-eks-30](releases/1-25/30/index.md) (January 05, 2024)
* [v1-25-eks-29](releases/1-25/29/index.md) (December 22, 2023)
* [v1-25-eks-28](releases/1-25/28/index.md) (December 08, 2023)
* [v1-25-eks-27](releases/1-25/27/index.md) (November 28, 2023)
* [v1-25-eks-26](releases/1-25/26/index.md) (November 10, 2023)
* [v1-25-eks-25](releases/1-25/25/index.md) (October 27, 2023)
* [v1-25-eks-24](releases/1-25/24/index.md) (October 13, 2023)
* [v1-25-eks-23](releases/1-25/23/index.md) (September 28, 2023)
* [v1-25-eks-22](releases/1-25/22/index.md) (September 15, 2023)
* [v1-25-eks-21](releases/1-25/21/index.md) (September 01, 2023)
* [v1-25-eks-20](releases/1-25/20/index.md) (August 17, 2023)
* [v1-25-eks-19](releases/1-25/19/index.md) (August 04, 2023)
* [v1-25-eks-18](releases/1-25/18/index.md) (July 20, 2023)
* [v1-25-eks-17](releases/1-25/17/index.md) (July 06, 2023)
* [v1-25-eks-16](releases/1-25/16/index.md) (June 22, 2023)
* [v1-25-eks-15](releases/1-25/15/index.md) (June 09, 2023)
* [v1-25-eks-14](releases/1-25/14/index.md) (May 24, 2023)
* [v1-25-eks-13](releases/1-25/13/index.md) (May 11, 2023)
* [v1-25-eks-12](releases/1-25/12/index.md) (April 27, 2023)
* [v1-25-eks-11](releases/1-25/11/index.md) (April 13, 2023)
* [v1-25-eks-10](releases/1-25/10/index.md) (March 29, 2023)
* [v1-25-eks-9](releases/1-25/9/index.md) (March 16, 2023)
* [v1-25-eks-8](releases/1-25/8/index.md) (March 10, 2023)
* [v1-25-eks-7](releases/1-25/7/index.md) (February 23, 2023)
* [v1-25-eks-6](releases/1-25/6/index.md) (February 22, 2023)
* [v1-25-eks-5](releases/1-25/5/index.md) (February 5, 2023)
* [v1-25-eks-4](releases/1-25/4/index.md) (February 2, 2023)
* [v1-25-eks-3](releases/1-25/3/index.md) (January 24, 2023)
* [v1-25-eks-2](releases/1-25/2/index.md) (January 11, 2023)
* [v1-25-eks-1](releases/1-25/1/index.md) (December 29, 2022)

#### EKS-D 1.24 Version Dependencies (DEPRECATED)
* [v1-24-eks-36](releases/1-24/36/index.md) (February 01, 2024)
* [v1-24-eks-35](releases/1-24/35/index.md) (January 19, 2024)
* [v1-24-eks-34](releases/1-24/34/index.md) (January 05, 2024)
* [v1-24-eks-33](releases/1-24/33/index.md) (December 22, 2023)
* [v1-24-eks-32](releases/1-24/32/index.md) (December 08, 2023)
* [v1-24-eks-31](releases/1-24/31/index.md) (November 28, 2023)
* [v1-24-eks-30](releases/1-24/30/index.md) (November 10, 2023)
* [v1-24-eks-29](releases/1-24/29/index.md) (October 27, 2023)
* [v1-24-eks-28](releases/1-24/28/index.md) (October 13, 2023)
* [v1-24-eks-27](releases/1-24/27/index.md) (September 28, 2023)
* [v1-24-eks-26](releases/1-24/26/index.md) (September 15, 2023)
* [v1-24-eks-25](releases/1-24/25/index.md) (September 01, 2023)
* [v1-24-eks-24](releases/1-24/24/index.md) (August 17, 2023)
* [v1-24-eks-23](releases/1-24/23/index.md) (August 04, 2023)
* [v1-24-eks-22](releases/1-24/22/index.md) (July 20, 2023)
* [v1-24-eks-21](releases/1-24/21/index.md) (July 06, 2023)
* [v1-24-eks-20](releases/1-24/20/index.md) (June 22, 2023)
* [v1-24-eks-19](releases/1-24/19/index.md) (June 09, 2023)
* [v1-24-eks-18](releases/1-24/18/index.md) (May 24, 2023)
* [v1-24-eks-17](releases/1-24/17/index.md) (May 11, 2023)
* [v1-24-eks-16](releases/1-24/16/index.md) (April 27, 2023)
* [v1-24-eks-15](releases/1-24/15/index.md) (April 13, 2023)
* [v1-24-eks-14](releases/1-24/14/index.md) (March 29, 2023)
* [v1-24-eks-13](releases/1-24/13/index.md) (March 16, 2023)
* [v1-24-eks-12](releases/1-24/12/index.md) (March 10, 2023)
* [v1-24-eks-11](releases/1-24/11/index.md) (February 23, 2023)
* [v1-24-eks-9](releases/1-24/9/index.md) (February 08, 2023)
* [v1-24-eks-8](releases/1-24/8/index.md) (January 25, 2023)
* [v1-24-eks-7](releases/1-24/7/index.md) (January 12, 2023)
* [v1-24-eks-6](releases/1-24/6/index.md) (December 29, 2022)
* [v1-24-eks-5](releases/1-24/5/index.md) (December 16, 2022)
* [v1-24-eks-4](releases/1-24/4/index.md) (December 01, 2022)
* [v1-24-eks-3](releases/1-24/3/index.md) (November 11, 2022)
* [v1-24-eks-2](releases/1-24/2/index.md) (October 26, 2022)
* [v1-24-eks-1](releases/1-24/1/index.md) (October 10, 2022)

#### EKS-D 1.23 Version Dependencies (DEPRECATED)
* [v1-23-eks-33](releases/1-23/33/index.md) (October 13, 2023)
* [v1-23-eks-32](releases/1-23/32/index.md) (September 28, 2023)
* [v1-23-eks-31](releases/1-23/31/index.md) (September 15, 2023)
* [v1-23-eks-30](releases/1-23/30/index.md) (September 01, 2023)
* [v1-23-eks-29](releases/1-23/29/index.md) (August 17, 2023)
* [v1-23-eks-28](releases/1-23/28/index.md) (August 04, 2023)
* [v1-23-eks-27](releases/1-23/27/index.md) (July 20, 2023)
* [v1-23-eks-26](releases/1-23/26/index.md) (July 06, 2023)
* [v1-23-eks-25](releases/1-23/25/index.md) (June 22, 2023)
* [v1-23-eks-24](releases/1-23/24/index.md) (June 09, 2023)
* [v1-23-eks-23](releases/1-23/23/index.md) (May 24, 2023)
* [v1-23-eks-22](releases/1-23/22/index.md) (May 11, 2023)
* [v1-23-eks-21](releases/1-23/21/index.md) (April 27, 2023)
* [v1-23-eks-20](releases/1-23/20/index.md) (April 13, 2023)
* [v1-23-eks-19](releases/1-23/19/index.md) (March 29, 2023)
* [v1-23-eks-18](releases/1-23/18/index.md) (March 16, 2023)
* [v1-23-eks-17](releases/1-23/17/index.md) (March 10, 2023)
* [v1-23-eks-16](releases/1-23/16/index.md) (February 23, 2023)
* [v1-23-eks-14](releases/1-23/14/index.md) (February 08, 2023)
* [v1-23-eks-13](releases/1-23/13/index.md) (January 25, 2023)
* [v1-23-eks-12](releases/1-23/12/index.md) (January 12, 2023)
* [v1-23-eks-11](releases/1-23/11/index.md) (December 29, 2022)
* [v1-23-eks-10](releases/1-23/10/index.md) (December 16, 2022)
* [v1-23-eks-9](releases/1-23/9/index.md) (December 01, 2022)
* [v1-23-eks-8](releases/1-23/8/index.md) (November 11, 2022)
* [v1-23-eks-7](releases/1-23/7/index.md) (October 26, 2022)
* [v1-23-eks-6](releases/1-23/6/index.md) (October 10, 2022)
* [v1-23-eks-5](releases/1-23/5/index.md) (September 2, 2022)
* [v1-23-eks-4](releases/1-23/4/index.md) (August 4, 2022)
* [v1-23-eks-3](releases/1-23/3/index.md) (July 2, 2022)
* [v1-23-eks-2](releases/1-23/2/index.md) (June 17, 2022)
* [v1-23-eks-1](releases/1-23/1/index.md) (June 2, 2022)

#### EKS-D 1.22 Version Dependencies (DEPRECATED)
* [v1-22-eks-28](releases/1-22/28/index.md) (May 24, 2023)
* [v1-22-eks-27](releases/1-22/27/index.md) (May 11, 2023)
* [v1-22-eks-26](releases/1-22/26/index.md) (April 27, 2023)
* [v1-22-eks-25](releases/1-22/25/index.md) (April 13, 2023)
* [v1-22-eks-24](releases/1-22/24/index.md) (March 29, 2023)
* [v1-22-eks-23](releases/1-22/23/index.md) (March 16, 2023)
* [v1-22-eks-22](releases/1-22/22/index.md) (March 10, 2023)
* [v1-22-eks-21](releases/1-22/21/index.md) (February 23, 2023)
* [v1-22-eks-19](releases/1-22/19/index.md) (February 08, 2023)
* [v1-22-eks-18](releases/1-22/18/index.md) (January 25, 2023)
* [v1-22-eks-17](releases/1-22/17/index.md) (January 12, 2023)
* [v1-22-eks-16](releases/1-22/16/index.md) (December 29, 2022)
* [v1-22-eks-15](releases/1-22/15/index.md) (December 16, 2022)
* [v1-22-eks-14](releases/1-22/14/index.md) (December 01, 2022)
* [v1-22-eks-13](releases/1-22/13/index.md) (November 11, 2022)
* [v1-22-eks-12](releases/1-22/12/index.md) (October 26, 2022)
* [v1-22-eks-11](releases/1-22/11/index.md) (October 10, 2022)
* [v1-22-eks-10](releases/1-22/10/index.md) (September 2, 2022)
* [v1-22-eks-9](releases/1-22/9/index.md) (July 2, 2022)
* [v1-22-eks-8](releases/1-22/8/index.md) (June 20, 2022)
* [v1-22-eks-7](releases/1-22/7/index.md) (May 17, 2022)
* [v1-22-eks-6](releases/1-22/6/index.md) (May 1, 2022)
* [v1-22-eks-5](releases/1-22/5/index.md) (April 20, 2022)
* [v1-22-eks-4](releases/1-22/4/index.md) (March 28, 2022)
* [v1-22-eks-3](releases/1-22/3/index.md) (March 17, 2022)
* [v1-22-eks-2](releases/1-22/2/index.md) (March 17, 2022)
* [v1-22-eks-1](releases/1-22/1/index.md) (March 6, 2022)

#### EKS-D 1.21 Version Dependencies (DEPRECATED)
* [v1-21-eks-26](releases/1-21/26/index.md) (February 08, 2023)
* [v1-21-eks-25](releases/1-21/25/index.md) (January 25, 2023)
* [v1-21-eks-24](releases/1-21/24/index.md) (January 12, 2023)
* [v1-21-eks-23](releases/1-21/23/index.md) (December 29, 2022)
* [v1-21-eks-22](releases/1-21/22/index.md) (December 16, 2022)
* [v1-21-eks-21](releases/1-21/21/index.md) (November 11, 2022)
* [v1-21-eks-20](releases/1-21/20/index.md) (October 26, 2022)
* [v1-21-eks-19](releases/1-21/19/index.md) (October 10, 2022)
* [v1-21-eks-18](releases/1-21/18/index.md) (September 1, 2022)
* [v1-21-eks-17](releases/1-21/17/index.md) (July 28, 2022)
* [v1-21-eks-16](releases/1-21/16/index.md) (July 2, 2022)
* [v1-21-eks-15](releases/1-21/15/index.md) (June 20, 2022)
* [v1-21-eks-14](releases/1-21/14/index.md) (May 17, 2022)
* [v1-21-eks-13](releases/1-21/13/index.md) (May 1, 2022)
* [v1-21-eks-12](releases/1-21/12/index.md) (April 20, 2022)
* [v1-21-eks-11](releases/1-21/11/index.md) (March 17, 2022)
* [v1-21-eks-10](releases/1-21/10/index.md) (March 17, 2022)
* [v1-21-eks-9](releases/1-21/9/index.md) (February 18, 2022)
* [v1-21-eks-8](releases/1-21/8/index.md) (January 19, 2022)
* [v1-21-eks-7](releases/1-21/7/index.md) (December 18, 2021)
* [v1-21-eks-6](releases/1-21/6/index.md) (October 26, 2021)
* [v1-21-eks-5](releases/1-21/5/index.md) (September 21, 2021)
* [v1-21-eks-4](releases/1-21/4/index.md) (August 18, 2021)
* [v1-21-eks-3](releases/1-21/3/index.md) (August 6, 2021)
* [v1-21-eks-2](releases/1-21/2/index.md) (July 27, 2021)
* [v1-21-eks-1](releases/1-21/1/index.md) (July 19, 2021)

#### EKS-D 1.20 Version Dependencies (DEPRECATED)
* [v1-20-eks-22](releases/1-20/22/index.md) (October 26, 2022)
* [v1-20-eks-21](releases/1-20/21/index.md) (October 10, 2022)
* [v1-20-eks-20](releases/1-20/20/index.md) (September 2, 2022)
* [v1-20-eks-19](releases/1-20/19/index.md) (July 28, 2022)
* [v1-20-eks-18](releases/1-20/18/index.md) (July 2, 2022)
* [v1-20-eks-17](releases/1-20/17/index.md) (June 20, 2022)
* [v1-20-eks-16](releases/1-20/16/index.md) (May 17, 2022)
* [v1-20-eks-15](releases/1-20/15/index.md) (May 1, 2022)
* [v1-20-eks-14](releases/1-20/14/index.md) (April 20, 2022)
* [v1-20-eks-13](releases/1-20/13/index.md) (March 17, 2022)
* [v1-20-eks-12](releases/1-20/12/index.md) (March 17, 2022)
* [v1-20-eks-11](releases/1-20/11/index.md) (February 18, 2022)
* [v1-20-eks-10](releases/1-20/10/index.md) (January 19, 2022)
* [v1-20-eks-9](releases/1-20/9/index.md) (December 17, 2021)
* [v1-20-eks-8](releases/1-20/8/index.md) (October 26, 2021)
* [v1-20-eks-7](releases/1-20/7/index.md) (September 21, 2021)
* [v1-20-eks-6](releases/1-20/6/index.md) (August 18, 2021)
* [v1-20-eks-5](releases/1-20/5/index.md) (August 6, 2021)
* [v1-20-eks-4](releases/1-20/4/index.md) (July 27, 2021)
* [v1-20-eks-3](releases/1-20/3/index.md) (July 13, 2021)
* [v1-20-eks-2](releases/1-20/2/index.md) (June 30, 2021)
* [v1-20-eks-1](releases/1-20/1/index.md) (May 18, 2021)

#### EKS-D 1.19 Version Dependencies (DEPRECATED)
* [v1-19-eks-22](releases/1-19/22/index.md) (July 28, 2022)
* [v1-19-eks-21](releases/1-19/21/index.md) (July 2, 2022)
* [v1-19-eks-20](releases/1-19/20/index.md) (June 20, 2022)
* [v1-19-eks-19](releases/1-19/19/index.md) (May 17, 2022)
* [v1-19-eks-18](releases/1-19/18/index.md) (May 1, 2022)
* [v1-19-eks-17](releases/1-19/17/index.md) (April 20, 2022)
* [v1-19-eks-16](releases/1-19/16/index.md) (March 17, 2022)
* [v1-19-eks-15](releases/1-19/15/index.md) (March 17, 2022)
* [v1-19-eks-14](releases/1-19/14/index.md) (February 18, 2022)
* [v1-19-eks-13](releases/1-19/13/index.md) (January 19, 2022)
* [v1-19-eks-12](releases/1-19/12/index.md) (December 17, 2021)
* [v1-19-eks-11](releases/1-19/11/index.md) (October 26, 2021)
* [v1-19-eks-10](releases/1-19/10/index.md) (September 21, 2021)
* [v1-19-eks-9](releases/1-19/9/index.md) (August 18, 2021)
* [v1-19-eks-8](releases/1-19/8/index.md) (August 8, 2021)
* [v1-19-eks-7](releases/1-19/7/index.md) (July 27, 2021)
* [v1-19-eks-6](releases/1-19/6/index.md) (July 13, 2021)
* [v1-19-eks-5](releases/1-19/5/index.md) (June 30, 2021)
* [v1-19-eks-4](releases/1-19/4/index.md) (May 6, 2021)
* [v1-19-eks-3](releases/1-19/3/index.md) (April 16, 2021)
* [v1-19-eks-2](releases/1-19/2/index.md) (March 30, 2021)
* [v1-19-eks-1](releases/1-19/1/index.md) (March 4, 2021)

#### EKS-D 1.18 Version Dependencies (DEPRECATED)
* [v1-18-eks-17](releases/1-18/17/index.md) (March 17, 2022)
* [v1-18-eks-16](releases/1-18/16/index.md) (March 17, 2022)
* [v1-18-eks-15](releases/1-18/15/index.md) (February 18, 2022)
* [v1-18-eks-14](releases/1-18/14/index.md) (January 18, 2022)
* [v1-18-eks-13](releases/1-18/13/index.md) (December 17, 2021)
* [v1-18-eks-12](releases/1-18/12/index.md) (October 26, 2021)
* [v1-18-eks-11](releases/1-18/11/index.md) (September 22, 2021)
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
