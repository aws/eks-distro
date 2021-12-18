# Changelog for v1-18-eks-13

This changelog highlights the changes for [v1-18-eks-13](https://github.com/aws/eks-distro/tree/v1-18-eks-13).

## Version Upgrades

### Components

* **AWS-IAM-Authenticator**: upgrade from 0.5.2 to
  [0.5.3](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases/tag/v0.5.3)

### Base Image

Security updates to Amazon Linux 2.

## Patch Changes

### Patches Added

* **0019-EKS-PATCH-Skip-TestLoopbackHostPortIPv6-run-on-non-I.patch**
  * Cherry-pick of upstream [Kubernetes PR #94376](https://github.com/kubernetes/kubernetes/pull/94376), which is
    included in Kubernetes 1.20.
  * Fixes `TestLoopbackHostPortIPv6` test failure if there is no IPv6 loopback device configured.
* **0020-EKS-PATCH-apiserver-healthz-upper-log-verbosity-for-.patch**
  * Silences `cannot exclude some health checks, no health checks are installed matching "kms-provider-0".`
  * This is logged when external health checker calls "/healthz?exclude=kms-provider-0" against an API server that does
    not enable KMS encryption. These changes reduce such logs to minimize the noise.

### Patches Removed

* **0001-EKS-PATCH-Added-allowlist-CIDR-flag-use-klog.patch**
  * Removed because it is an unused feature, which upstream Kubernetes does not seem interested in including.
* **0004-EKS-PATCH-Lookup-sts-endpoint-from-custom-map.patch**
  * Related to the now-removed `0001-EKS-PATCH-Added-allowlist-CIDR-flag-use-klog.patch`. See removal note above.

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
