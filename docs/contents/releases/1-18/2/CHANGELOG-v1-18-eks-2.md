# Changelog for v1-18-eks-2

This changelog highlights the changes for [v1-18-eks-2)](https://github.com/aws/eks-distro/tree/v1-18-eks-2).

## Patches 

### Patches Added
_The following patches were not in EKS-D [v1.18.1](https://github.com/aws/eks-distro/tree/v1-18-eks-1/projects/kubernetes/kubernetes/1-18/patches)
but were added in the version._

* **0017-EKS-PATCH-Accept-healthy-instances-in-list-of-active.patch** 
  * This patch applies the changes ([PR #85920](https://github.com/kubernetes/kubernetes/pull/85920)) that upstream 
    Kubernetes cherry-picked ([PR #97164](https://github.com/kubernetes/kubernetes/pull/97164)) for 1.18. The changes
    are part of Kubernetes 1.19, so this patch will only apply to 1.18.
  * The changes in this patch fix a bug related to AWS Network Load Balancer (NLB) and cordoned nodes. Previously, 
    cordoned nodes were erroneously not deregistered from an NLB's target group, despite being perceived as already out
    of the target group. Now, with this patch, Cordoned nodes are deregistered from target groups as expected.
