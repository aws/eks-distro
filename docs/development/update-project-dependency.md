# Updating project dependencies

The projects we maintain as part of EKS-D can not always be updated to the latest version from upstream.
EKS-D matches the versions used in the cloud EKS service and generally dependency projects are not heavily updated
during the life cycle of a specific Kubernetes release life cycle.  To account for security related fixes upstream
we occasionally need to update specific dependencies for some of the projects in this repo.

## Typical workflow
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
        * `go mod why` and `go mod graph` could be helpful in determining which dependency is pulling in implicit dependencies
    * pay close attention to replace override blocks, these may need updating as well
1.  **After go.mod has been updated, run vendor update scripts**  
    * run `make update-vendor-for-dep-patch`
        * a number upstream projects which vendor their deps have a specific script for updating the vendor directly.
        For ex [external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter/blob/master/release-tools/update-vendor.sh)
        if this is the case, add `VENDOR_UPDATE_SCRIPT=<path-in-repo>` to the project Makefile
        * by default, this will run `go mod vendor && go mod tidy`
1.  **Generate a new patch file**
    * `make patch-for-dep-update` will generate a new patch file including the go.sum/mod file changes along with the vendor
    directory if upstream vends deps.
        * the script will launch your git editor to fill in the commit message and body. Please try to include the CVE number
        along with any upstream PR this may be based off and which upstream version includes the fix.  This information will
        help in future maintenance of these patches.
1.  **Generate new checksums**
    * `make build` 
        * can use `make update-attribution-checksums-docker` if you prefer to build in docker. See [building locally](building-locally.md) for more info

1.  **Things to remember**
	* If there's an alert that recommends a specific version to fix it, but it hasn't been incorporated in the last few versions from upstream, there's a good chance it's because they decided the versions are not affected. For example, there's a vulnerability in some part of a package that the code doesn't use. 
	  * Search for the CVE ID in the relevant repository code, issues, PRs etc to see if there's some conversation about it.
	  * Check the release notes of the fixed version; there may be more information on who is affected and why it might or might not apply to us. 
	Reference any link or conversation you find in the documentation for the CVE for that version

	* If the above doesn't turn anything up, the issue may not apply, _only if the version is still in support_. Out of support version will *not* get patched and the vulnerability may definitely apply to them. So blanket "not affected" cannot be assumed for all versions. 

	* If the vulnerability alert is new and nothing exists upstream yet, create an issue for it using the proper process for submitting security issues for the repo in question. If you can tackle the fix, consider doing so and submitting the PR.

	* There may be many false positives in the vulnerability alerts. So the main value of this process is discovering if upstream has fixed something that affects out of support K8s version that we still support (>9 months ago) and we need to backport the fix to our additional supported versions. 