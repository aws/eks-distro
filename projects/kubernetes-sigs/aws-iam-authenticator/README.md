## AWS IAM Authenticator

| Release | Version |
| --- | --- |
| 1-18 | ![Version](https://img.shields.io/badge/version-v0.5.3-blue) |
| 1-19 | ![Version](https://img.shields.io/badge/version-v0.5.3-blue) |
| 1-20 | ![Version](https://img.shields.io/badge/version-v0.5.3-blue) |
| 1-21 | ![Version](https://img.shields.io/badge/version-v0.5.3-blue) |


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
   Check the `aws-iam-authenticator` target for any build flag changes, tag 
   changes, dependencies, etc. Check that the manifest target, which is called 
   from the EKS-D Makefile, has not changed.
4. Verify the Golang version has not changed. The version specified in
   [`go.mod`](https://github.com/kubernetes-sigs/aws-iam-authenticator/blob/master/go.mod)
   seems to be kept up to date. Be sure to select the correct branch for the 
   release when checking the Golang version.
5. Update CHECKSUMS and attribution by using
   `make update-attribution-checksums-docker PROJECT=kubernetes-sigs/aws-iam-authenticator RELEASE_BRANCH=<release_branch>` 
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
