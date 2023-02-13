## **cloud-provider-aws**
| Release | Version                                                       |
|---------|---------------------------------------------------------------|
| 1-22    | ![Version](https://img.shields.io/badge/version-v1.22.7-blue) |
| 1-23    | ![Version](https://img.shields.io/badge/version-v1.23.6-blue) |
| 1-24    | ![Version](https://img.shields.io/badge/version-v1.24.4-blue) |

The AWS cloud provider provides the interface between a Kubernetes cluster and AWS service APIs. This project allows a Kubernetes cluster to provision, monitor and remove AWS resources necessary for operation of the cluster. 

### Updating
1. Work with EKS teams to decide on a new version. Review tags and changelogs in upstream [repo](https://github.com/kubernetes/cloud-provider-aws) since there isn't always a corresponding release for a tag.
2. Update GIT_TAG file based on the version agreed upon with EKS.
3. Update GOLANG_VERSION file to be consistent with the upstream Dockerfile GOLANG_IMAGE arg at the chosen tag. Example [here](https://github.com/kubernetes/cloud-provider-aws/blob/master/Dockerfile#L17)
4. Run `make run-attribution-checksums-in-docker` in this folder.
5. Update CHECKSUMS as necessary (updated by default).
6. Update the version at the top of this Readme.
