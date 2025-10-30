## EKS Distro Repository
---

| Release | Development Build Status                                                                                                                  |
|---------|-------------------------------------------------------------------------------------------------------------------------------------------|
| 1-28    | [![1-28](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-28-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-28-postsubmit) |
| 1-29    | [![1-29](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-29-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-29-postsubmit) |
| 1-30    | [![1-30](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-30-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-30-postsubmit) |
| 1-31    | [![1-31](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-31-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-31-postsubmit) |
| 1-32    | [![1-32](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-32-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-32-postsubmit) |
| 1-33    | [![1-33](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-33-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-33-postsubmit) |
| 1-34    | [![1-34](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-34-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-34-postsubmit) |

[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/6111/badge)](https://bestpractices.coreinfrastructure.org/projects/6111)

Amazon **EKS Distro** (EKS-D) is a Kubernetes distribution based on and used by
Amazon Elastic Kubernetes Service (EKS) to create reliable and secure Kubernetes
clusters. With EKS-D, you can rely on the same versions of Kubernetes and its
dependencies deployed by Amazon EKS. This includes the latest upstream updates,
as well as extended security patching support. EKS-D follows the same Kubernetes
version release cycle as Amazon EKS, and we provide the bits here. EKS-D offers
the same software that has enabled tens of thousands of Kubernetes clusters on
Amazon EKS.

This GitHub repository has everything required to build the components that make
up the EKS Distro from source.

## DEPRECATION NOTICE
As part of an effort to streamline the maintenance of EKS-D, we will be deprecating 
the metrics-server and CSI sidecar projects from EKS-D. Releases for new versions will 
no longer be created after the dates listed below. EKS-D no longer uses these projects, 
and it does not make sense to continue building them. The remaining projects in EKS-D 
will continue to be built for the time being. Additionally, The infrastructure for 
building EKS-D from source code will no longer be maintained, including project 
directories and build scripts. However, we will continue to publish all EKS-D images 
and artifacts to their current repositories and destinations. Users can still access 
and use all released EKS-D components as before.

metrics-server project deprecation: as of 1/16/2025

csi sidecar projects deprecation: as of 3/31/2025

Find the csi sidecar images at their new location here - https://gallery.ecr.aws/csi-components

Please open an issue if you have any concerns.

## Releases

Full documentation for releases can be found on [https://distro.eks.amazonaws.com](https://distro.eks.amazonaws.com).

To receive notifications about new EKS-D releases, subscribe to the EKS-D updates SNS topic:
`arn:aws:sns:us-east-1:379412251201:eks-distro-updates`

[<img src="docs/contents/certified-kubernetes-1.28-color.svg" height=150>](https://github.com/cncf/k8s-conformance/pull/2847)
[<img src="docs/contents/certified-kubernetes-1.32-color.svg" height=150>](https://github.com/cncf/k8s-conformance/pull/3598)
[<img src="docs/contents/certified-kubernetes-1.33-color.svg" height=150>](https://github.com/cncf/k8s-conformance/pull/3774)
<!--
Source: https://github.com/cncf/artwork/tree/master/projects/kubernetes/certified-kubernetes
-->
### Kubernetes 1-34

| Release | Manifest | Kubernetes Version                                                      |
| -- | --- |-------------------------------------------------------------------------|
| 9 | [v1-34-eks-9](https://distro.eks.amazonaws.com/kubernetes-1-34/kubernetes-1-34-eks-9.yaml) | [v1.34.1](https://github.com/kubernetes/kubernetes/release/tag/v1.34.1) |
### Kubernetes 1-33

| Release | Manifest | Kubernetes Version                                                      |
| -- | --- |-------------------------------------------------------------------------|
| 17 | [v1-33-eks-17](https://distro.eks.amazonaws.com/kubernetes-1-33/kubernetes-1-33-eks-17.yaml) | [v1.33.5](https://github.com/kubernetes/kubernetes/release/tag/v1.33.5) |

### Kubernetes 1-32

| Release | Manifest | Kubernetes Version                                                      |
| -- | --- |-------------------------------------------------------------------------|
| 27 | [v1-32-eks-27](https://distro.eks.amazonaws.com/kubernetes-1-32/kubernetes-1-32-eks-27.yaml) | [v1.32.9](https://github.com/kubernetes/kubernetes/release/tag/v1.32.9) |

### Kubernetes 1-31

| Release | Manifest | Kubernetes Version                                                        |
| -- | --- |---------------------------------------------------------------------------|
| 34 | [v1-31-eks-34](https://distro.eks.amazonaws.com/kubernetes-1-31/kubernetes-1-31-eks-34.yaml) | [v1.31.13](https://github.com/kubernetes/kubernetes/release/tag/v1.31.13) |

### Kubernetes 1-30

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 45 | [v1-30-eks-45](https://distro.eks.amazonaws.com/kubernetes-1-30/kubernetes-1-30-eks-45.yaml) | [v1.30.14](https://github.com/kubernetes/kubernetes/release/tag/v1.30.14) |

### Kubernetes 1-29

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 52 | [v1-29-eks-52](https://distro.eks.amazonaws.com/kubernetes-1-29/kubernetes-1-29-eks-52.yaml) | [v1.29.15](https://github.com/kubernetes/kubernetes/release/tag/v1.29.15) |

### Kubernetes 1-28

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 63 | [v1-28-eks-63](https://distro.eks.amazonaws.com/kubernetes-1-28/kubernetes-1-28-eks-63.yaml) | [v1.28.15](https://github.com/kubernetes/kubernetes/release/tag/v1.28.15) |

### Kubernetes 1.18 - 1.27: DEPRECATED

In alignment with the [Amazon EKS release calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar),
EKS Distro has discontinued support of Kubernetes v1.18 - v1.27. While there are
no plans to remove these versions' images from EKS Distro ECR, there will be no
more updates, including security fixes, for them.

**Due to the increased security risk this poses, it is HIGHLY recommended that
users of v1.18 - v1.27 update to a supported version (v1.28+) as soon as
possible.**

## Development

The EKS Distro is built using
[Prow](https://github.com/kubernetes/test-infra/tree/master/prow), the
Kubernetes CI/CD system. EKS operates an installation of Prow, which is visible
at https://prow.eks.amazonaws.com/. Please read our
[CONTRIBUTING](CONTRIBUTING.md) guide before making a Pull Request.

For building EKS Distro locally, refer to the
[building-locally](docs/development/building-locally.md) guide.

For updating project dependencies, refer to the
[update-project-dependency](docs/development/update-project-dependency.md) guide.

## Security

If you discover a potential security issue in this project, or think you may
have discovered a security issue, we ask that you notify AWS Security via our
[vulnerability reporting page](http://aws.amazon.com/security/vulnerability-reporting/).
Please do **not** create a public GitHub issue.

## License

This project is licensed under the [Apache-2.0 License](LICENSE).
