## Metrics Server

| Release | Version                                                      |
|---------|--------------------------------------------------------------|
| 1-22    | ![Version](https://img.shields.io/badge/version-v0.6.3-blue) |
| 1-23    | ![Version](https://img.shields.io/badge/version-v0.6.3-blue) |
| 1-24    | ![Version](https://img.shields.io/badge/version-v0.6.3-blue) |
| 1-25    | ![Version](https://img.shields.io/badge/version-v0.6.3-blue) |
| 1-26    | ![Version](https://img.shields.io/badge/version-v0.6.3-blue) |


### Updating

1. Review [releases](https://github.com/kubernetes-sigs/metrics-server/releases)
   on the `kubernetes-sigs/metrics-server` 
   [repo](https://github.com/kubernetes-sigs/metrics-server). Please review 
   changelogs carefully looking for updates that may affect EKS-Distro or 
   downstream projects like EKS-Anywhere, especially if the new version is 
   greater than the one used in upstream Kubernetes.
2. Update the `GIT_TAG` file to have the new, desired version based on the
   `metrics-server` release tags.
3. Compare the old tag to the new one, looking specifically for Makefile changes.
   For example:
   [v0.5.0 compared to v0.5.2](https://github.com/kubernetes-sigs/metrics-server/compare/v0.5.0...v0.5.2).
   Check the [metrics-server](https://github.com/kubernetes-sigs/metrics-server/blob/master/Makefile#L35) 
   target for any build flag changes especially LDFLAGS and PKG, tag changes, dependencies, etc. 
4. Verify the Golang version has not changed. The version specified in
   [`go.mod`](https://github.com/kubernetes-sigs/metrics-server/blob/master/go.mod) 
   seems to be kept up to date. Be sure to select the correct branch for the 
   release when checking the Golang version. If the version has changes, update
   `GOLANG_VERSION` in the release branch.
5. Update CHECKSUMS and attribution by running from project root:
   `make run-attribution-checksums-in-docker RELEASE_BRANCH=<release_branch>`
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
