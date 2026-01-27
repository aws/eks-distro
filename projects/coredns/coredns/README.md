## CoreDNS

| Release | Version                                                       |
|---------|---------------------------------------------------------------|
| 1-28    | ![Version](https://img.shields.io/badge/version-v1.10.1-blue) |
| 1-29    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-30    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-31    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-32    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-33    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-34    | ![Version](https://img.shields.io/badge/version-v1.11.4-blue) |
| 1-35    | ![Version](https://img.shields.io/badge/version-v1.12.4-blue) |

### Updating

1. Work with EKS teams to decide on a new version. Review
   [releases](https://github.com/coredns/coredns/releases) on the
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
5. Update CHECKSUMS and attribution by running from project root:
   `make run-attribution-checksums-in-docker RELEASE_BRANCH=<release_branch>`
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.


### Golang Version

EKS-Distro has decided to build projects with EKS-Go 1.18+ to maintain and backport the applicable security updates of upstream Golang.
