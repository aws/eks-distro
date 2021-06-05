# EKS Distro Release Runbook

After the first release, the process is the same, but not all the steps need to be completed
unless there is a change.

Prow jobs are in the [eks-distro-prow-jobs repo](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro).  
All other changes are to this package. 

### Create new Kubernetes minor version
1. **Prow Build Job**: Create and merge Prow build job for new release
   * copy previous job, ex: build-1-20-postsubmits.yaml, and change RELEASE_BRANCH
1. **Prow Presubmit Job**: Create presubmit for new release
   * copy previous job, ex: kubernetes-1-20-presubmits.yaml, and change RELEASE_BRANCH
1. **Create EKS Distro PR**: Create kubernetes RELEASE_BRANCH:
   * release/${RELEASE_BRANCH}/development/RELEASE (set to 0)
   * release/${RELEASE_BRANCH}/production/RELEASE (set to 0)
   * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG (set to upstream tag)
   * copy ATTRIBUTION.txt and GOLANG_VERSION from previous release branch folder to the new
   * Add release/${RELEASE_BRANCH}/patches with the patches from the EKS team
   * Create projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE using
      * `RELEASE_BRANCH=${RELEASE_BRANCH} make update-version`
   * Create ${RELASE_BRANCH}/GIT_TAG files for other versioned components (etcd, coredns, metrics-server, aws-iam-authenticator)
      * Work with EKS team to gather these requirements based on the EKS release, by default use same version as previous release
      * Create new presubmit jobs for each project with the new RELEASE_BRANCH
   * Update kops `cluster_wait.sh` to apply the coredns fix to new version
1. **Prow Release Jobs**: Create dev + prod release jobs from previous release jobs
   * dev-release-1-20-postsubmits.yaml
   * prod-release-1-20-postsubmits.yaml   

### Release
1. **Create EKS Distro Develop Release PR**
   * release/${RELEASE_BRANCH}/development/RELEASE (increment)
1. **Create EKS Distro Prod Release PR**
   * release/${RELEASE_BRANCH}/production/RELEASE (increment)
   * update projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE
      * `RELEASE_BRANCH=${RELEASE_BRANCH} make update-version`
1. **Docs PR**
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/index.md
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/CHANGELOG<...>.md
   * docs/contents/releases/${RELEASE_BRANCH}/${RELEASE}/release-announcement.txt
   * docs/contents/index.md
   * README
   * release/DEFAULT_RELEASE_BRANCH 
1. **Tag Repository**: Tag the repository. For example:
   * `git tag -a v1-19-eks-1 -m v1-19-eks-1`
   * `git push origin v1-19-eks-1` # Replace 'origin' if you call the upstream repo something else
1. **k8s Conformance**: Submit PR similar to https://github.com/cncf/k8s-conformance/pull/1499
