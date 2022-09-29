## EKS Distro Repository

### 🚨🚨🚨 IMPORTANT INFORMATION ABOUT 1.19 SUPPORT 🚨🚨🚨

EKS-D will be discontinuing support of Kubernetes v1.19 soon. While there are no
plans to removed EKS-D 1.19 images from the ECR, there will be no more updates 
to 1.19 once support has stopped. **Due to the increased security risk this poses, 
it is HIGHLY recommended that users of 1.19 update to a supported version 
(1.20 - 1.23) as soon as possible.**

---

| Release | Development Build Status |
| --- | --- |
| 1-20 | [![1-20](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-20-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-20-postsubmit) |
| 1-21 | [![1-21](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-21-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-21-postsubmit) |
| 1-22 | [![1-22](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-22-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-22-postsubmit) |
| 1-23 | [![1-23](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-23-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-23-postsubmit) |

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

### Kubernetes 1-23

| Release | Manifest | Kubernetes Version | 
| --- | --- | --- |
| 5 | [v1-23-eks-5](https://distro.eks.amazonaws.com/kubernetes-1-23/kubernetes-1-23-eks-5.yaml) | [v1.23.9](https://github.com/kubernetes/kubernetes/release/tag/v1.23.9) |

### Kubernetes 1-22

| Release | Manifest | Kubernetes Version | 
| --- | --- | --- |
| 10 | [v1-22-eks-10](https://distro.eks.amazonaws.com/kubernetes-1-22/kubernetes-1-22-eks-10.yaml) | [v1.22.12](https://github.com/kubernetes/kubernetes/release/tag/v1.22.12) |

### Kubernetes 1-21

| Release | Manifest | Kubernetes Version | 
| --- | --- | --- |
| 18 | [v1-21-eks-18](https://distro.eks.amazonaws.com/kubernetes-1-21/kubernetes-1-21-eks-18.yaml) | [v1.21.14](https://github.com/kubernetes/kubernetes/release/tag/v1.21.14) |

### Kubernetes 1-20

| Release | Manifest | Kubernetes Version | 
| --- | --- | --- |
| 20 | [v1-20-eks-20](https://distro.eks.amazonaws.com/kubernetes-1-20/kubernetes-1-20-eks-20.yaml) | [v1.20.15](https://github.com/kubernetes/kubernetes/release/tag/v1.20.15) |


### Kubernetes 1.18 and 1.19: DEPRECATED

EKS Distro has discontinued support of Kubernetes 1.18 and 1.19. While there are
no plans to remove these versions' images from EKS Distro ECR, there will be no
more updates, including security fixes, for them.

**Due to the increased security risk this poses, it is HIGHLY recommended that
users of 1.18 and 1.19 update to a supported version (1.20 - 1.23) as soon as 
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
