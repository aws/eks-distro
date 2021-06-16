# EKS Distro Release Runbook

After the first release, the process is the same, but not all the steps need to be completed unless there is a change.

Prow jobs are in the 
[eks-distro-prow-jobs repo](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro).  
All other changes are to this package.

### Create new Kubernetes minor version

1. **Prow Build Postsubmits Job**: In the
   [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro) repo, create and
   merge Prow build-${RELEASE_BRANCH}-postsubmits job for new release
    * In the [jobs/aws/eks-distro](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro) directory,
      copy the previous build job (ex: build-1-21-postsubmits.yaml)
    * Paste the copied yaml file in the directory and change the filename to match the new version
    * In the file, change the following values to match the new version
        * `name` (
          [example](https://github.com/aws/eks-distro-prow-jobs/blob/49377e50748a9bec611aec7bb23873a14aa84e11/jobs/aws/eks-distro/build-1-21-postsubmits.yaml#L17))
        * `RELEASE_BRANCH` (
          [example](https://github.com/aws/eks-distro-prow-jobs/blob/49377e50748a9bec611aec7bb23873a14aa84e11/jobs/aws/eks-distro/build-1-21-postsubmits.yaml#L51))
1. **Prow Presubmits Job**: In the
   [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro) repo, create and
   merge Prow kubernetes-${RELEASE_BRANCH}-presubmits job for new release
    * In the [jobs/aws/eks-distro](https://github.com/aws/eks-distro-prow-jobs/tree/main/jobs/aws/eks-distro) directory,
      copy the previous presubmits job (ex: kubernetes-1-21-presubmits.yaml)
    * Paste the copied yaml file in the directory and change the filename to match the new version
    * In the file, change value under `RELEASE_BRANCH` to match the new version (ex:
      [here](https://github.com/aws/eks-distro-prow-jobs/blob/49377e50748a9bec611aec7bb23873a14aa84e11/jobs/aws/eks-distro/kubernetes-1-21-presubmits.yaml#L39))
1. **Create EKS Distro PR**: Create kubernetes RELEASE_BRANCH:
    * release/${RELEASE_BRANCH}/development/RELEASE (set to 0)
    * release/${RELEASE_BRANCH}/production/RELEASE (set to 0)
    * projects/kubernetes/kubernetes/${RELEASE_BRANCH}/GIT_TAG (set to upstream tag)
    * copy ATTRIBUTION.txt and GOLANG_VERSION from previous release branch folder to the new
    * Add release/${RELEASE_BRANCH}/patches with the patches from the EKS team
    * Create projects/kubernetes/kubernetes/${RELEASE_BRANCH}/KUBE_GIT_VERSION_FILE using
        * `RELEASE_BRANCH=${RELEASE_BRANCH} make update-version`
    * Create ${RELASE_BRANCH}/GIT_TAG files for other versioned components (etcd, coredns, metrics-server,
      aws-iam-authenticator)
        * Work with EKS team to gather these requirements based on the EKS release, by default use same version as
          previous release
        * Create new presubmit jobs for each project with the new RELEASE_BRANCH
    * Update kops `cluster_wait.sh` to apply the coredns fix to new version
1. **Build tooling PR**: Add release channel to release tooling
    * In the [config](https://github.com/aws/eks-distro-build-tooling/tree/main/release/config) directory, create the
      new `RELEASE_BRANCH` folder and create a `${RELEASE_BRANCH}.yaml`, copied from the previous release yaml and
      change `metadata.name` to the new `RELEASE_BRANCH`
        * the rest of the file can stay the same, including the `snsTopicARN`
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
    * release/DEFAULT_RELEASE_BRANCH (if a minor release)
1. **Tag Repository**: Tag the repository. For example:
    * `git tag -a v1-19-eks-1 -m v1-19-eks-1`
    * `git push origin v1-19-eks-1` # Replace 'origin' if you call the upstream repo something else
1. **k8s Conformance**: Submit PR similar to https://github.com/cncf/k8s-conformance/pull/1499
