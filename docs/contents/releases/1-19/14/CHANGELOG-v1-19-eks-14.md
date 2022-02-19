# Changelog for v1-19-eks-14

This changelog highlights the changes for [v1-19-eks-14](https://github.com/aws/eks-distro/tree/v1-19-eks-14).

## Changes

### Base Image

Security updates to Amazon Linux 2.

### Patches Added

* **0022-EKS-PATCH-AWS-Set-max-results-if-its-not-set.patch**
  * Cherry-pick of upstream Kubernetes [PR #106280](https://github.com/kubernetes/kubernetes/pull/106280), which is
    included in Kubernetes 1.24.
  * If max results is not set and instance IDs are not provided for the describe instances call in the aws cloud
    provider, set max results. This prevents an expensive call against the EC2 API, which can result in timeouts.

### Patches Removed

* **0016-EKS-PATCH-apiserver-healthz-upper-log-verbosity-for-.patch**
  * This patched was removed because it assumed that users would have a certain alarm setup, which may not have been the
    case. Users may notice an uptick of "kms-provider-0" errors in logs, as this patch intended to reduce this noise.
