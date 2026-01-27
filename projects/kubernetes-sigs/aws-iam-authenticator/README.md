## AWS IAM Authenticator

| Release | Version                                                       |
|---------|---------------------------------------------------------------|
| 1-28    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-29    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-30    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-31    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-32    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-33    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-34    | ![Version](https://img.shields.io/badge/version-v0.6.29-blue) |
| 1-35    | ![Version](https://img.shields.io/badge/version-v0.7.10-blue) |


### Updating

1. Review [releases](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases)
   and changelogs in the `kubernetes-sigs/aws-iam-authenticator`
   [repo](https://github.com/kubernetes-sigs/aws-iam-authenticator). Please
   review changelogs carefully looking for updates that may affect EKS-Distro or
   downstream projects like EKS-Anywhere.
2. Update the `GIT_TAG` file to have the new, desired version based on the
   `aws-iam-authenticator` release tags.
3. Compare the old tag to the new one, looking specifically for Makefile changes.
   For example:
   [v0.5.2 compared to v0.5.3](https://github.com/kubernetes-sigs/aws-iam-authenticator/compare/v0.5.2...v0.5.3).
   Check the `$(OUTPUT)/bin/%: $(SOURCES)` target for any build flag changes, tag
   changes, dependencies, etc. Check the [gorelease config](https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/.goreleaser.yaml)
   for LDFLAGS changes, these should match what is in their Makefile and the EKS-D Makefile.
4. Verify the Golang version has not changed. The version specified in
   [`go.mod`](https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/go.mod)
   seems to be kept up to date. Be sure to select the correct branch for the
   release when checking the Golang version.
5. Update CHECKSUMS and attribution by running from project root:
   `make run-attribution-checksums-in-docker RELEASE_BRANCH=<release_branch>`
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
