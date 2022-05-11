# Updating project dependencies

The projects we maintain as part of EKS-D can not always be updated to the latest version from upstream.
EKS-D matches the versions used in the cloud EKS service and generally dependency projects are not heavily updated
during the life cycle of a specific Kubernetes release life cycle.  To account for security related fixes upstream
we occasionally need to update specific dependencies for some of the projects in this repo.

## Typical workflow

1. Based on our automated Dependeabot alerts or Inspector V2 scans, identify dependencies in need of updating
along with the fix version. **Note** Be sure to include the `RELEASE_BRANCH=<>` along with each make call
if updating a released branch project. It may be easier to just `export RELEASE_BRANCH=<>` before starting this process.
1. In the specific project folder:
    * `make checkout-repo`
    * Update $(REPO)/go.mod file to new version of dependency. There are various options:
        * if it is a simple dependency, not overridden in a replace block, run `go get -u dep@version`
        * if there are a number of dependencies to update, it may be easier to manually change the version in the go.mod file
        * if the dependency is an implicit dependency brought in via another, you may need to add a replace override
        * pay close attention to replace override blocks, these may need updating as well
        * `go mod why` and `go mod graph` could be helpful in determining which dependency is pulling in implicit dependencies
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
