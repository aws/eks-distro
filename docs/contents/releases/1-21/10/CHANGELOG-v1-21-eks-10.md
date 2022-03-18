# Changelog for v1-21-eks-10

This changelog highlights the changes for [v1-21-eks-10](https://github.com/aws/eks-distro/tree/v1-21-eks-10).

## Version Updates

### Kubernetes
**Updated from v1.21.5 to [v1.21.9](https://github.com/kubernetes/kubernetes/releases/tag/v1.21.9)**

### Projects
* **AWS IAM Authenticator for Kubernetes**: v0.5.3 ➞
  [v0.5.5](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.5)
* **CSI external-attacher**: v3.2.0 ➞ [v3.4.0](https://github.com/kubernetes-csi/external-attacher/releases/tag/v3.4.0)
* **CSI external-provisioner**: v2.2.0 ➞ [v3.1.0](https://github.com/kubernetes-csi/external-provisioner/releases/tag/v3.1.0)
* **CSI external-resizer**: v1.2.0 ➞ [v1.4.0](https://github.com/kubernetes-csi/external-resizer/releases/tag/v1.4.0)
* **CSI external-snapshotter**: v4.1.1 ➞ [v4.2.1](https://github.com/kubernetes-csi/external-snapshotter/releases/tag/v4.2.1)
* **CSI livenessprobe**: v2.3.0 ➞ [v2.6.0](https://github.com/kubernetes-csi/livenessprobe/releases/tag/v2.6.0)
* **CSI node-driver-registrar**: v2.2.0 ➞
  [v2.5.0](https://github.com/kubernetes-csi/node-driver-registrar/releases/tag/v2.5.0)
* **etcd**: v3.4.16 ➞ [v3.4.18](https://github.com/etcd-io/etcd/releases/tag/v3.4.18)
* **Metrics Server**: v0.5.2 ➞ [v0.6.1](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.6.1)

### Base Image

Security updates to Amazon Linux 2.

## Patch Changes

### Patches Added

* **0022-EKS-PATCH-AWS-Include-IPv6-addresses-in-NodeAddresse.patch**
  * This patch is taken from a 
    [commit](https://github.com/anguslees/kubernetes/commit/f8ea814e2d459a900bfb5e6f613dbe521b31515b)
    by GitHub user [anguslees](https://github.com/anguslees). Some of this code was originally in 
    [upstream Kubernetes PR #86918](https://github.com/kubernetes/kubernetes/pull/86918), but it was closed without
    being added to Kubernetes because the PR was not merged before legacy cloud providers new feature freeze, which 
    started in Kubernetes 1.21.
  * The change modifies the in-tree cloud provider code to append ipv6 addresses to the Node object advertised by the
    kubelet.

### Patches Removed

* **0013-EKS-PATCH-ConsistentRead-tries-10-times.patch**
  * Commit that was included in change that was cherry-picked by [upstream Kubernetes PR #102656](https://github.com/kubernetes/kubernetes/pull/102656) 
    and [included](https://github.com/kubernetes/kubernetes/commits/v1.21.9?after=b631974d68ac5045e076c86a5c66fba6f128dc72+103&branch=v1.21.9)
    in this version of Kubernetes.
* **0014-EKS-PATCH-Ignore-wait-no-child-processes-error-when-calling-mo.patch**
  * Cherry-picked by [upstream Kubernetes PR #106527](https://github.com/kubernetes/kubernetes/pull/106527) and
    [included](https://github.com/kubernetes/kubernetes/commits/v1.21.9?after=b631974d68ac5045e076c86a5c66fba6f128dc72+73&branch=v1.21.9)
    in this version of Kubernetes.
* **0015-EKS-PATCH-Get-inodes-and-disk-usage-via-pure-go.patch**
  * Commit that was included in change that was cherry-picked by [upstream Kubernetes PR #104021](https://github.com/kubernetes/kubernetes/pull/104021)
    and [included](https://github.com/kubernetes/kubernetes/commits/v1.21.9?before=b631974d68ac5045e076c86a5c66fba6f128dc72+96&branch=v1.21.9)
    in this version of Kubernetes.
* **0016-EKS-PATCH-Add-test-for-counting-inodes-correct-with-hardlinks.patch**
  * Commit that was part of the change that was cherry-picked by upstream Kubernetes PR #104021, as described in the
    patch `0015-EKS-PATCH-Get-inodes-and-disk-usage-via-pure-go.patch` above.
* **0018-dependencies-Update-golang.org-x-net-to-v0.0.0-20211.patch**
  * Cherry-picked by [upstream Kubernetes PR #106961](https://github.com/kubernetes/kubernetes/pull/106961) and
    [included](https://github.com/kubernetes/kubernetes/commits/v1.21.9?after=b631974d68ac5045e076c86a5c66fba6f128dc72+51&branch=v1.21.9)
    in this version of Kubernetes.
