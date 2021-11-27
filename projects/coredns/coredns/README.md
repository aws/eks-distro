## **Coredns**

| Release | Version |
| --- | --- |
| 1-18 | ![Version](https://img.shields.io/badge/version-v1.7.0-blue) |
| 1-19 | ![Version](https://img.shields.io/badge/version-v1.8.0-blue) |
| 1-20 | ![Version](https://img.shields.io/badge/version-v1.8.3-blue) |
| 1-21 | ![Version](https://img.shields.io/badge/version-v1.8.3-blue) |


### Updating

1. Work with EKS teams to decide on new version.  Review releases and changelogs in upstream [repo](https://github.com/coredns/coredns). 
Please review changelogs carefully looking for changes that may affect EKS-D or downstream projects like EKS-A especially if the new
version if greater than the one used in upstream Kubernetes. For ex, 1.8.3 required additional permissions to the default role
shipped with Kubernetes since upstream had not updated to 1.8.3 by the team EKS updated.
1. Update the `GIT_TAG` file to have the new desired version based on the upstream release tags.
1. Compare the old tag to the new, looking specifically for Makefile changes. 
ex: [1.8.0 compared to 1.8.3](https://github.com/coredns/coredns/compare/v1.8.0...v1.8.3). Check the `coredns` target for
any build flag changes, tag changes, dependencies, etc. Check that the manifest target has not changed, this is called
from our Makefile.
1. Verify the golang version has not changed. The version specified in `go.mod` seems to be kept up to date.
1. Update checksums and attribution using `make update-attribution-checksums-docker PROJECT=coredns/coredns RELEASE_BRANCH=<release_branch>` from the root of the repo.
1. Update the version at the top of this Readme.
