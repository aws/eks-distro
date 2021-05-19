# EKS Distro Release Runbook

After the first release, the process is the same, but not all the steps need to be completed
unless there is a change.

Prow jobs are in the [eks-distro-prow-jobs repo](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro).  
All other changes are to this package. 

### Minor Release
1. **Prow Build Job**: Create and merge Prow build job for new release (build-1-20-postsubmits.yaml)
1. **Create EKS Distro PR**: Create various release components:
   * release/${RELEASE_BRANCH}/development/RELEASE (set to 0)
   * release/${RELEASE_BRANCH}/production/RELEASE (set to 0)
   * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG
   * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE
   * Create GIT_TAG files for other components (etcd, coredns, ...)
   * Add support in kops script for new release
1. **Prow Presubmit Job**: Create presubmit for new release (kubernetes-1-20-presubmits.yaml)
1. **Prow Release Jobs**: Create release jobs
   * dev-release-1-20-postsubmits.yaml
   * prod-release-1-20-postsubmits.yaml
1. **Create EKS Distro Patches PR**: Add patches for new release
1. **Create EKS Distro Develop Release PR**
   * release/${RELEASE_BRANCH}/development/RELEASE (increment)
1. **Create EKS Distro Prod Release PR**
   * release/${RELEASE_BRANCH}/production/RELEASE (increment)
1. **Docs PR**
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/index.md
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/CHANGELOG<...>.md
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/release-announcement.txt
   * docs/contents/index.md
   * README
1. **Tag Repository**: Tag the repository. For example:
   * `git tag -a v1-19-eks-1 -m v1-19-eks-1`
   * `git push origin v1-19-eks-1` # Replace 'origin' if you call the upstream repo something else

### Patch Release
1. **Make whatever changes you want for this release**
   * Add patches, change Kubernetes versions, etc.
   * Update whatever Prow Jobs, GIT_TAGs, etc. that are needed for these changes
1. **Update KUBE_GIT_VERSION**
   * In projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE
   * This step can be done as part of the next step(s). It just MUST be done not later than the Prod Release PR, though
   it can be part of that PR.
1. **Do steps 6 - 9 in the above "Minor Release" section**
