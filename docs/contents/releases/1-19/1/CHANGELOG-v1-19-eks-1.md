# Changelog for v1-19-eks-1

This changelog highlights the changes for [v1-19-eks-1)](https://github.com/aws/eks-distro/tree/v1-19-eks-1).

## Upgrade Kubernetes Versions

* Upgraded Kubernetes to 1.19.6

## Patches 

### Patches Removed
_The following patches were in EKS-D [v1.18.1](https://github.com/aws/eks-distro/tree/v1-18-eks-1/projects/kubernetes/kubernetes/1-18/patches)
but were removed in the version._

**Patches that were removed because their changes were made in upstream Kubernetes 1.19:**
* 0007-EKS-PATCH-fix-aws-loadbalancer-nodePort-cannot-chang.patch
  * See [PR #89562](https://github.com/kubernetes/kubernetes/pull/89562)
* 0008-EKS-PATCH-aws-Fix-address-sorting-of-multiple-interf.patch
  * See [PR #91889](https://github.com/kubernetes/kubernetes/pull/91889)
* 0009-EKS-PATCH-fix-aws-loadbalancer-vpc-cidr-calculation.patch
  * See [PR #92227](https://github.com/kubernetes/kubernetes/pull/92227)
* 0010-EKS-PATCH-refine-aws-loadbalancer-worker-node-SG-rul.patch
  * See [PR #92224](https://github.com/kubernetes/kubernetes/pull/92224)
* 0011-EKS-PATCH-Allow-UDP-for-AWS-NLB.patch
  * See [PR #92109](https://github.com/kubernetes/kubernetes/pull/92109)
* 0017-EKS-PATCH-Accept-healthy-instances-in-list-of-active.patch
  * See [PR #85920](https://github.com/kubernetes/kubernetes/pull/85920)

**Patches that were removed for another reason:**
* 0013-EKS-PATCH-aws_credentials-update-ecr-url-validation-.patch
  * Adds support for ECR endpoints in isolated AWS regions. There is an open PR ([#95415](https://github.com/kubernetes/kubernetes/pull/95415))
    for upstream Kubernetes that applies these changes.
  * This patch will likely be added back to a future release for 1.19.
* 0018-EKS-PATCH-Delete-leaked-volume-if-driver-doesn-t-kno.patch
  * This patch was added to 1.18.2 but was not available at the initial release of 1.19. It will be added to a future 
    release for 1.19.
    
### Patches Added
_The following patches were not in EKS-D [v1.18](https://github.com/aws/eks-distro/tree/v1-18-eks-1/projects/kubernetes/kubernetes/1-18/patches)
but were added in the version._

* **0010-EKS-PATCH-additional-subnet-configuration-for-AWS-el.patch** 
  * This patch applies changes from upstream Kubernetes [PR #97431](https://github.com/kubernetes/kubernetes/pull/97431).  
    At the time of this changelog's creation, this PR is tagged to be part of the Kubernetes v1.21 release.
  * These changes allow for AWS CloudProvider to consider all subnets that are not tagged explicitly for another cluster
    when provisioning NLB/CLB for service resources. Previously, cluster tags were required for auto-discovery. In 
    addition, this patch provides an annotation to configure the subnets manually. See the above-linked, upstream PR 
    description for additional details.
* **0012-EKS-PATCH-allow-override-of-kube-proxy-base-image**
  * This patch enabled the ability to override the kube-proxy base image used. The motivation for this change is to 
    provide the ability to get security fixes that may not yet be available in the upstream base image.

### Patch Name and Order Changes
For patches that were carried over from the previous release, there were some minor changes in the patch order (and thus
the start of each impacted patch's filename). These differences are functionally immaterial and do not impact the use or
application of the patches.

## Component Versions

| Component             | Version           |
|-----------------------|-------------------|
| aws-iam-authenticator | 0.5.2             |
| cni-plugins           | 0.8.7             |
| coredns               | 1.8.0             |
| etcd                  | 3.4.14            |
| external-attacher     | 3.0.1             |
| external-provisioner  | 2.0.3             |
| external-resizer      | 1.0.1             |
| external-snapshotter  | 3.0.2             |
| kubernetes            | 1.18.9 --> 1.19.6 |
| livenessprobe         | 2.1.0             |
| metrics-server        | 0.4.0             |
| node-driver-registrar | 2.0.1             |
