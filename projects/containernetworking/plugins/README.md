## CNI Plugins

| Release | Version                                                      |
|---------|--------------------------------------------------------------|
| 1-28    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-29    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-30    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-31    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-32    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-33    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |
| 1-34    | ![Version](https://img.shields.io/badge/version-v1.5.1-blue) |

### Updating

1. Work with EKS teams to decide on a new version. Review
   [releases](https://github.com/containernetworking/plugins/releases) on the
   `containernetworking/plugins` [repo](https://github.com/containernetworking/plugins).
   Please review changelogs carefully looking for updates that may affect EKS-Distro
   or downstream projects like EKS-Anywhere, especially if the new version is greater than the one used in
   upstream Kubernetes.
2. Update the `GIT_TAG` file to have the new, desired version based on the
   `plugins` release tags.
3. Compare the old tag to the new one, looking specifically for Makefile changes.
   For example:
   [v0.8.7 compared to v0.9.0](https://github.com/containernetworking/plugins/compare/v0.8.7...v0.9.0).
   Check the [scripts/release](https://github.com/containernetworking/plugins/blob/main/scripts/release.sh)
   for any changes to build flags, tags, dependencies, etc.
4. Verify the Golang version has not changed. The version specified in
   [scripts/release](https://github.com/containernetworking/plugins/blob/main/scripts/release.sh) should be the
   source of truth. Be sure to select the correct branch for the release when
   checking the Golang version. If the version has changes, update
   `GOLANG_VERSION` in the release branch.
5. Update CHECKSUMS and attribution by running from project root:
   `make run-attribution-checksums-in-docker RELEASE_BRANCH=<release_branch>`
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
