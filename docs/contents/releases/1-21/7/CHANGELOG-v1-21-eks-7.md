# Changelog for v1-21-eks-7

This changelog highlights the changes for [v1-21-eks-7](https://github.com/aws/eks-distro/tree/v1-21-eks-7).

## Version Upgrades

### Kubernetes

* **Upgraded Kubernetes from v1.21.2 to [v1.21.5](https://github.com/kubernetes/kubernetes/releases/tag/v1.21.5)**

### Components

* **AWS-IAM-Authenticator**: upgrade from 0.5.2 to
  [0.5.3](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.3)
* **coreDNS**: upgraded from 1.8.3 to
  [1.8.4](https://github.com/coredns/coredns/releases/tag/v1.8.4)
* **Metrics Server**
  * Upgraded from 0.5.0 to [0.5.20](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.5.2)

### Base Image

Security updates to Amazon Linux 2.

## Patch Changes

### Patches Added

* **0002-EKS-PATCH-Pass-region-to-sts-client.patch**
  * Update to the now-removed `0002-EKS-PATCH-Pass-region-to-sts-client-for-ap-east-1.patch` due because an update
    to `aws-sdk-go`.
* **0013-EKS-PATCH-ConsistentRead-tries-10-times.patch**
  * Taken from a [commit](https://github.com/kubernetes/kubernetes/commit/82cfe9f14f8fb445d682ce2774ea44ce54885e81)
    in [Kubernetes PR #102059](https://github.com/kubernetes/kubernetes/pull/102059/). The change made in the PR is part
    of Kubernetes 1.22.
  * From the original commit message:
    > We've seen clusters where 3 attempts were not enough. Bumping to 10. The slowdown should be negligible and it will reduce retry attempts in the upper layers of kubelet.
* **0014-EKS-PATCH-Ignore-wait-no-child-processes-error-when-calling-mo.patch**
  * Cherry-pick of upstream [Kubernetes PR #103780](https://github.com/kubernetes/kubernetes/pull/103780), which is
    included in Kubernetes 1.23. This change fixes an issue related to a race condition.
    See [Kubernetes Issue #103753](https://github.com/kubernetes/kubernetes/issues/103753).
  * From the original PR description:
    > I've only fixed the exec commands that are part of Mount() and Unmount() functions and that too in the linux mount helper. Not touching others, since I'm not sure about the implications.
* **0015-EKS-PATCH-Get-inodes-and-disk-usage-via-pure-go.patch**
  * Cherry-pick of upstream [Kubernetes PR #96115](https://github.com/kubernetes/kubernetes/pull/96115), which is
    included in Kubernetes 1.22. There was an [upstream PR](https://github.com/kubernetes/kubernetes/pull/104021) opened
    to cherry-pick this change for 1.21, but it was not approved before the release ofthe patch version of Kubernetes
    EKS-Distro uses for 1.21.
  * This patch and the EKS-Distro patch `0016-EKS-PATCH-Add-test-for-counting-inodes-correct-with-hardlinks.patch` are
    tied together. This patch is the first commit in the above-mentioned PRs, while the other one is the second commit
    on the PR.
  * From the original upstream commit message (with minor formatting edits):
    > Fix inode usage calculation to use filepath.Walk instead of executing an external find. Also calculate the disk usage while at it so we also get rid of the external dependency of `nice` and `du`. (Issue #95172)  
    This is similar to what cadvisor does since commit https://github.com/google/cadvisor/commit/046818d64c0af62a4c5037583b467296bb68626d.  
    This solves three problems: Counts number of inodes correct when there are hardlinks (#96114), Makes kubelet work without GNU findutils (#95186), [and] Makes kubelet work without GNU coreutils (#95172)
* **0016-EKS-PATCH-Add-test-for-counting-inodes-correct-with-hardlinks.patch**
  * See `0015-EKS-PATCH-Get-inodes-and-disk-usage-via-pure-go.patch` above.
* **0017-EKS-PATCH-apiserver-healthz-upper-log-verbosity-for-.patch**
  * Silences `cannot exclude some health checks, no health checks are installed matching "kms-provider-0".`
  * This is logged when external health checker calls "/healthz?exclude=kms-provider-0" against an API server that does
    not enable KMS encryption. These changes reduce such logs to minimize the noise.

### Patches Removed

* **0001-EKS-PATCH-Added-allowlist-CIDR-flag-use-klog.patch**
  * Removed because it is an unneeded feature, which upstream Kubernetes does not seem interested in including.
* **0002-EKS-PATCH-Pass-region-to-sts-client-for-ap-east-1.patch**
  * Replaced by `0002-EKS-PATCH-Pass-region-to-sts-client.patch` because of an update to `aws-sdk-go`.
* **0004-EKS-PATCH-Lookup-sts-endpoint-from-custom-map.patch**
  * Removed because an update to `aws-sdk-go` made patch irrelevant.
* **0009-EKS-PATCH-Pass-additional-flags-to-subpath-mount-to-avoid-flak.patch**
  * This patch is a [commit](https://github.com/kubernetes/kubernetes/commit/296b30f14367a42d43f25ad0774d10be55b49f4d)
    in [Kubernetes PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), which is included in Kubernetes
    1.23. This change was cherry-picked in [Kubernetes PR #104347](https://github.com/kubernetes/kubernetes/pull/104347)
    for 1.21 and included this release.
* **0010-EKS-PATCH-Add-missing-interface-method-in-mount_unsupported.go.patch**
  * This patch is a [commit](https://github.com/kubernetes/kubernetes/commit/338f8ba0bf8d4ea5ae13d25065308dd9935b214f)
    in [Kubernetes PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), which is included in Kubernetes
    1.23. This change was cherry-picked in [Kubernetes PR #104347](https://github.com/kubernetes/kubernetes/pull/104347)
    for 1.21 and included this release.
* **0011-EKS-PATCH-Update-the-unit-tests-to-handle-mountFlags.patch**
  * This patch is a [commit](https://github.com/kubernetes/kubernetes/commit/b9b76dba6ee901d330de5dfef39b83e5acb76906)
    in [Kubernetes PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), which is included in Kubernetes
    1.23. This change was cherry-picked in [Kubernetes PR #104347](https://github.com/kubernetes/kubernetes/pull/104347)
    for 1.21 and included this release.
* **0012-EKS-PATCH-Keep-MakeMountArgSensitive-and-add-a-new-signature-t.patch**
  * This patch is a [commit](https://github.com/kubernetes/kubernetes/commit/08bec6da0fcf418f351f86c113620edc7be1849c)
    in [Kubernetes PR #104253](https://github.com/kubernetes/kubernetes/pull/104253), which is included in Kubernetes
    1.23. This change was cherry-picked in [Kubernetes PR #104347](https://github.com/kubernetes/kubernetes/pull/104347)
    for 1.21 and included this release.

### Existing Patches

The existing patches have some minor changes, which are described below. None of these changes impact how patches are
applied or intended result of the patches.

* **Numbers in patch filenames**
  * In past releases, removing a patch would result in the number at the start of all subsequent patch filenames
    (e.g., `0016` in `0016-EKS-PATCH-...`) to decrease so there would be no numerical gaps in the filenames. However,
    this practice made it difficult to track the history of a patch and view changes in PRs because renamed files would
    appear like new files.
  * Due to these reasons, this release preserves the filenames, even if earlier patches are deleted.
* **Patch descriptions**
  * The descriptions of most of the existing patches were improved to provided additional information about them.
* **Minor changes to code in patches**
  * Some patches had minor changes in their diff hunk and files changed due to earlier patches being removed in this
    release.
