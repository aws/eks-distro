# EKS Distro Release Runbook

After the first release, the process is the same, but not all the steps need to be completed unless there is a change.

Reference [build-locally](building-locally.md) for additional machine setup and make targets.

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
    * Create ${RELEASE_BRANCH}/GIT_TAG files for other versioned components (etcd, coredns, metrics-server,
      aws-iam-authenticator)
        * Work with EKS team to gather these requirements based on the EKS release, by default use same version as
          previous release
        * Create new presubmit jobs for each project with the new RELEASE_BRANCH
    * Create ${RELEASE_BRANCH}/GIT_TAG files for the `kubernetes/release` project
        * Use [common.sh](https://github.com/kubernetes/kubernetes/blob/master/build/common.sh) from upstream for the correct RELEASE_BRANCH
          tag to determine `__default_go_runner_version`
        * Find the [release](https://github.com/kubernetes/release/releases) which provided that base image and update the GIT_TAG
        * Create new presubmit jobs for project
    * Update kops `cluster_wait.sh` to apply the coredns fix to new version
    * Update kops version to version of kops, which supports new kubernetes version
         * Typically, it will be a beta version because kops stable releases lag a bit behind kubernetes releases. See
           [kOps Releases & Versioning](https://kops.sigs.k8s.io/welcome/releases/) and
           [releases](https://github.com/kubernetes/kops/releases/).
    * Create projects/kubernetes/kubernetes/${RELEASE_BRANCH}/PAUSE_TAG and set to upstream tag
        * (ex: [here](https://github.com/kubernetes/kubernetes/blob/v1.21.0/build/pause/Makefile#L20))
	* Create projects/kubernetes/kubernetes/${RELEASE_BRANCH}/CHECKSUMS using
		*  `RELEASE_BRANCH=${RELEASE_BRANCH} make checksums`
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


### Updating project dependencies
The projects we maintain as part of EKS-D can not always be updated to the latest version from upstream.
EKS-D matches the versions used in the cloud EKS service and generally dependency projects are not heavily updated
during the life cycle of a specific Kubernetes release life cycle.  To account for security related fixes upstream
we occasionally need to update specific dependencies for some of the projects in this repo.

1. **Identify dependencies in need of updating**: Be sure to include the `RELEASE_BRANCH=<>` along with each make call
if updating a released branch project.
    * Based on our automated Dependeabot alerts or Inspector V2 scans
    * Identify fix versions
    * *Releases* `export RELEASE_BRANCH=<>` before starting this process.
1. **Navigate to the specific [project folder](https://github.com/aws/eks-distro/tree/main/projects):**
    * `cd $(REPO)`
1. **Check out the project repository:**
    * `make checkout-repo`
1. **Update $(REPO)/go.mod file to new version of dependency:**
    * if it is a simple dependency, not overridden in a replace block, run `go get -u dep@version`
    * if there are a number of dependencies to update, it may be easier to manually change the version in the go.mod file
    * if the dependency is an implicit dependency brought in via another, you may need to add a replace override
    * pay close attention to replace override blocks, these may need updating as well
    * `go mod why` and `go mod graph` could be helpful in determining which dependency is pulling in implicit dependenciesZZZ
1.  **Note**  
    * After go.mod has been updated run `make update-vendor-for-dep-patch`
        * a number upstream projects which vendor their deps have a specific script for updating the vendor directly.
        For ex [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter/blob/master/release-tools/update-vendor.sh)
        if this is the case, add `VENDOR_UPDATE_SCRIPT=<path-in-repo>` to the project Makefile
        * by default, this will run `go mod vendor && go mod tidy`
    * `make patch-for-dep-update` will generate a new patch file including the go.sum/mod file changes along with the vendor
    directory if upstream vends deps.
        * the script will launch your git editor to fill in the commit message and body. Please try to include the CVE number
        along with any upstream PR this may be based off and which upstream version includes the fix.  This information will
        help in future maintenance of these patches.
    * `make build` to generate new checksums
        * can use `make update-attribution-checksums-docker` if you prefer to build in docker. See [building locally](building-locally.md)
        for more info