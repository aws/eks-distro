## CoreDNS

| Release | Version |
| --- | --- |
| 1-18 | ![Version](https://img.shields.io/badge/version-v1.7.0-blue) |
| 1-19 | ![Version](https://img.shields.io/badge/version-v1.8.0-blue) |
| 1-20 | ![Version](https://img.shields.io/badge/version-v1.8.3-blue) |
| 1-21 | ![Version](https://img.shields.io/badge/version-v1.8.4-blue) |


### Updating

1. Work with EKS teams to decide on a new version. Review 
   [releases](https://github.com/coredns/coredn/releases) on the
   `coredns/coredns` [repo](https://github.com/coredns/coredns) and the 
   [changelogs](https://coredns.io/blog/) on project's
   [website](https://coredns.io/). Please review changelogs carefully looking
   for updates that may affect EKS-Distro or downstream projects like 
   EKS-Anywhere, especially if the new version is greater than the one used in
   upstream Kubernetes. For example, v1.8.3 required additional permissions to 
   the default role shipped with Kubernetes since upstream had not updated to 
   v1.8.3 by the time EKS updated.
2. Update the `GIT_TAG` file to have the new, desired version based on the
   `coredns` release tags.
3. Compare the old tag to the new one, looking specifically for Makefile changes.
   For example:
   [v1.8.0 compared to v1.8.3](https://github.com/coredns/coredns/compare/v1.8.0...v1.8.3). 
   Check the `coredns` target for any build flag changes, tag changes,
   dependencies, etc. Check that the manifest target, which is called from the 
   EKS-D Makefile, has not changed.
4. Verify the Golang version has not changed. The version specified in
   [`go.mod`](https://github.com/coredns/coredns/blob/master/go.mod) seems to be
   kept up to date. Be sure to select the correct branch for the release when 
   checking the Golang version. If the version has changes, update 
   `GOLANG_VERSION` in the release branch.
5. Update CHECKSUMS and attribution by using
   `make update-attribution-checksums-docker PROJECT=coredns/coredns RELEASE_BRANCH=<release_branch>`
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
