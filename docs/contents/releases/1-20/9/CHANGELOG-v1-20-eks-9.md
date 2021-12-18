# Changelog for v1-20-eks-9

This changelog highlights the changes for [v1-20-eks-9](https://github.com/aws/eks-distro/tree/v1-20-eks-9).

## Version Upgrades

### Kubernetes

* **Upgraded Kubernetes from v1.20.7 to [v1.20.11](https://github.com/kubernetes/kubernetes/releases/tag/v1.20.11)**

### Components

* **AWS-IAM-Authenticator**: upgrade from 0.5.2 to
  [0.5.3](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.3)
* **Metrics Server**: upgraded from 0.4.3 to
  [0.4.5](https://github.com/kubernetes-sigs/metrics-server/releases/tag/v0.4.5)

### Base Image

Security updates to Amazon Linux 2.

## Patch Changes

### Patches Added

* **0015-EKS-PATCH-Fix-kubectl-version-unit-test.patch**
  * Cherry-pick of upstream [Kubernetes PR #103955](https://github.com/kubernetes/kubernetes/pull/103955), which is
    included in Kubernetes 1.23.
  * Fixes configuration requirement that results in test `TestNewCmdVersionWithoutConfigFile` failing for some
    developers.
* **0016-EKS-PATCH-Refine-locking-in-API-Priority-and-Fairnes.patch**
  * Cherry-pick of upstream [Kubernetes PR #104833](https://github.com/kubernetes/kubernetes/pull/104833), which is
    included in Kubernetes 1.23. [Kubernetes PR #105051](https://github.com/kubernetes/kubernetes/pull/105051) was
    opened to cherry-pick this change for 1.20, but it was not approved before the release of the patch version of
    Kubernetes that EKS-Distro uses for 1.20.
  * From the original PR description:
    > Instead of a plain `Mutex`, use an `RWMutex` so that the common operations can proceed in parallel.
* **0017-EKS-PATCH-ConsistentRead-tries-10-times.patch**
  * Taken from a [commit](https://github.com/kubernetes/kubernetes/commit/82cfe9f14f8fb445d682ce2774ea44ce54885e81)
    in [Kubernetes PR #102059](https://github.com/kubernetes/kubernetes/pull/102059/). The change made in the PR is part
    of Kubernetes 1.22.
  * From the original commit message:
    > We've seen clusters where 3 attempts were not enough. Bumping to 10. The slowdown should be negligible and it will reduce retry attempts in the upper layers of kubelet.
* **0018-EKS-PATCH-apiserver-healthz-upper-log-verbosity-for-.patch**
  * Silences `cannot exclude some health checks, no health checks are installed matching "kms-provider-0".`
  * This is logged when external health checker calls "/healthz?exclude=kms-provider-0" against an API server that does
    not enable KMS encryption. These changes reduce such logs to minimize the noise.
* **0019-EKS-PATCH-Get-inodes-and-disk-usage-via-pure-go.patch**
  * Cherry-pick of upstream [Kubernetes PR #96115](https://github.com/kubernetes/kubernetes/pull/96115), which is
    included in Kubernetes 1.22. [Kubernetes PR #104022](https://github.com/kubernetes/kubernetes/pull/104022) was
    opened to cherry-pick this change for 1.20, but it was not approved before the release of the patch version of
    Kubernetes that EKS-Distro uses for 1.20.
  * From the original upstream commit message (with minor formatting edits):
    > Fix inode usage calculation to use filepath.Walk instead of executing an external find. Also calculate the disk usage while at it so we also get rid of the external dependency of `nice` and `du`. (Issue #95172)  
    This is similar to what cadvisor does since commit https://github.com/google/cadvisor/commit/046818d64c0af62a4c5037583b467296bb68626d.  
    This solves three problems: Counts number of inodes correct when there are hardlinks (#96114), Makes kubelet work without GNU findutils (#95186), [and] Makes kubelet work without GNU coreutils (#95172)
* **0020-EKS-PATCH-Ignore-wait-no-child-processes-error-when-.patch**
  * Cherry-pick of upstream [Kubernetes PR #103780](https://github.com/kubernetes/kubernetes/pull/103780), which is
    included in Kubernetes 1.23.
  * This change fixes an issue related to a race condition.
    See [Kubernetes Issue #103753](https://github.com/kubernetes/kubernetes/issues/103753).
  * From the original PR description:
    > I've only fixed the exec commands that are part of Mount() and Unmount() functions and that too in the linux mount helper. Not touching others, since I'm not sure about the implications.

### Patches Removed

* **0001-EKS-PATCH-Added-allowlist-CIDR-flag-use-klog.patch**
  * Removed because it is an unneeded feature, which upstream Kubernetes does not seem interested in including.
* **0009-EKS-PATCH-Allow-override-of-kube-proxy-base-image.patch**
  * Removed because it is an unneeded feature.
* **0010-EKS-PATCH-chunk-target-operatation-for-aws-targ.patch**
  * Included in this version of Kubernetes.
    See [Kubernetes PR #101813](https://github.com/kubernetes/kubernetes/pull/101813)
* **0013-EKS-CHERRYPICK-Pass-additional-flags-to-subpath-moun.patch**
  * Included in this version of Kubernetes.
    See [Kubernetes PR #104348](https://github.com/kubernetes/kubernetes/pull/104348)

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
