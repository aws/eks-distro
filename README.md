## EKS Distro Repository
---

| Release | Development Build Status                                                                                                                  |
|---------|-------------------------------------------------------------------------------------------------------------------------------------------|
| 1-28    | [![1-28](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-28-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-28-postsubmit) |
| 1-29    | [![1-29](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-29-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-29-postsubmit) |
| 1-30    | [![1-30](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-30-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-30-postsubmit) |
| 1-31    | [![1-31](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-31-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-31-postsubmit) |

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

## Releases

Full documentation for releases can be found on [https://distro.eks.amazonaws.com](https://distro.eks.amazonaws.com).

To receive notifications about new EKS-D releases, subscribe to the EKS-D updates SNS topic:
`arn:aws:sns:us-east-1:379412251201:eks-distro-updates`

[<img src="docs/contents/certified-kubernetes-1.26-color.svg" height=150>](https://github.com/cncf/k8s-conformance/pull/2507)
<!--
Source: https://github.com/cncf/artwork/tree/master/projects/kubernetes/certified-kubernetes
-->

### Kubernetes 1-31

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 4 | [v1-31-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-31/kubernetes-1-31-eks-4.yaml) | [v1.31.0](https://github.com/kubernetes/kubernetes/release/tag/v1.31.0) |

### Kubernetes 1-30

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 15 | [v1-30-eks-15](https://distro.eks.amazonaws.com/kubernetes-1-30/kubernetes-1-30-eks-15.yaml) | [v1.30.4](https://github.com/kubernetes/kubernetes/release/tag/v1.30.4) |

### Kubernetes 1-29

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 22 | [v1-29-eks-22](https://distro.eks.amazonaws.com/kubernetes-1-29/kubernetes-1-29-eks-22.yaml) | [v1.29.8](https://github.com/kubernetes/kubernetes/release/tag/v1.29.8) |

### Kubernetes 1-28

| Release | Manifest | Kubernetes Version |
| -- | --- | --- |
| 34 | [v1-28-eks-34](https://distro.eks.amazonaws.com/kubernetes-1-28/kubernetes-1-28-eks-34.yaml) | [v1.28.14](https://github.com/kubernetes/kubernetes/release/tag/v1.28.14) |

### Kubernetes 1.18 - 1.27: DEPRECATED

In alignment with the [Amazon EKS release calendar](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#kubernetes-release-calendar),
EKS Distro has discontinued support of Kubernetes v1.18 - v1.26. While there are
no plans to remove these versions' images from EKS Distro ECR, there will be no
more updates, including security fixes, for them.

**Due to the increased security risk this poses, it is HIGHLY recommended that
users of v1.18 - v1.26 update to a supported version (v1.27+) as soon as
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
