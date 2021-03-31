# EKS Distro Release Runbook

Last release PR https://github.com/aws/eks-distro/pull/227/files

After the first release, the process is the same, but not all the steps need to be completed
unless there is a change.

1. **Prow Build Job**: Create and merge Prow build job for new release (build-1-20-postsubmits.yaml)
1. **Create EKS Distro PR**: Create various release components:
   * release/${RELEASE_BRANCH}/development/RELEASE (set to 0)
   * release/${RELEASE_BRANCH}/production/RELEASE (set to 0)
   * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG
   * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE
   * Create GIT_TAG files for other components (etcd, coredns, ...)
   * Add support in kops script for new release
1. **Docs PR**: Create a PR with an empty change log and docs for release
1. **Prow Presubmit Job**: Create presubmit for new release (kubernetes-1-20-presubmits.yaml)
1. **Prow Release Jobs**: Create release jobs
   * dev-release-1-20-postsubmits.yaml
   * prod-release-1-20-postsubmits.yaml
1. **Create EKS Distro Patches PR**: Add patches for new release
1. **Docs PR**: Add patches info to change log
1. **Create EKS Distro Develop Release PR**: Modify components to create a release
   * release/${RELEASE_BRANCH}/development/RELEASE (increment)
1. **Create EKS Distro Release PR**: Modify components to create a release
   * release/${RELEASE_BRANCH}/production/RELEASE (increment)
1. **Docs PR**: Do final update to documentation with CRD
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/index.md
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/CHANGELOG*
   * docs/contents/index.md
   * README
1. **Announcement PR**: When everything is good, create announcement PR
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/release-announcement.txt
