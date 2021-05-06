## EKS Distro Repository

| Release | Development Build Status |
| --- | --- |
| 1-18 | [![1-18](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-18-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-18-postsubmit) |
| 1-19 | [![1-19](https://prow.eks.amazonaws.com/badge.svg?jobs=build-1-19-postsubmit)](https://prow.eks.amazonaws.com/?job=build-1-19-postsubmit) |

Amazon **EKS Distro** (EKS-D) is a Kubernetes distribution based on and used by
Amazon Elastic Kubernetes Service (EKS) to create reliable and secure Kubernetes
clusters. With EKS-D, you can rely on the same versions of Kubernetes and its
dependencies deployed by Amazon EKS. This includes the latest upstream updates
as well as extended security patching support. EKS-D follows the same Kubernetes
version release cycle as Amazon EKS, and we provide the bits here. EKS-D provides
the same software that has enabled tens of thousands of Kubernetes clusters on
Amazon EKS.

This GitHub repository has everything required to build the components that make
up the EKS Distro from source.

## Releases

Full documentation for releases can be found on [https://distro.eks.amazonaws.com](https://distro.eks.amazonaws.com).

To receive notifications about new EKS-D releases, subscribe to the EKS-D updates SNS topic: 
`arn:aws:sns:us-east-1:379412251201:eks-distro-updates`

### Kubernetes 1-18

| Release | Manifest |
| --- | --- |
| 3 | [kubernetes-1-18-eks-4](https://distro.eks.amazonaws.com/kubernetes-1-18/kubernetes-1-18-eks-4.yaml) |

### Kubernetes 1-19

| Release | Manifest |
| --- | --- |
| 3 | [kubernetes-1-19-eks-3](https://distro.eks.amazonaws.com/kubernetes-1-19/kubernetes-1-19-eks-3.yaml) |

## Development

The EKS Distro is built using
[Prow](https://github.com/kubernetes/test-infra/tree/master/prow), the
Kubernetes CI/CD system. EKS operates an installation of Prow, which is visible
at https://prow.eks.amazonaws.com/. Please read our
[CONTRIBUTING](CONTRIBUTING.md) guide before making a Pull Request.

## Security

If you discover a potential security issue in this project, or think you may
have discovered a security issue, we ask that you notify AWS Security via our
[vulnerability reporting
page](http://aws.amazon.com/security/vulnerability-reporting/). Please do
**not** create a public GitHub issue.

## License

This project is licensed under the [Apache-2.0 License](LICENSE).
