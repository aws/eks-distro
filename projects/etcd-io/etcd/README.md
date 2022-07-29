## **Etcd**

| Release | Version                                                       |
|---------|---------------------------------------------------------------|
| 1-20    | ![Version](https://img.shields.io/badge/version-v3.4.18-blue) |
| 1-21    | ![Version](https://img.shields.io/badge/version-v3.4.18-blue) |
| 1-22    | ![Version](https://img.shields.io/badge/version-v3.5.4-blue)  |

### Updating

1. Work with EKS teams to decide on a new version. Review releases and changelogs in upstream [repo](https://github.com/etcd-io/etcd). 
Please review changelogs carefully looking for changes that may affect EKS-D or downstream projects like EKS-A, especially if the new
version is greater than the one used in upstream Kubernetes.
1. Update the `GIT_TAG` file to have the new desired version based on the upstream release tags.
1. Compare the old tag to the new, looking specifically for changes to the `build` file in the root of the repo. 
ex: [3.4.14 compared to 3.4.15](https://github.com/etcd-io/etcd/compare/v3.4.14...v3.4.15). Check for any build flag changes, tag changes, dependencies, etc.
The EKS-D build does not call the build script from upstream directly so pay close attention [build.sh](https://github.com/etcd-io/etcd/blob/main/scripts/build.sh) for changes
to ldflags.
1. Verify the golang version has not changed. The version specified in `go.mod` seems to be kept up to date, but verify against the [Makefile](https://github.com/etcd-io/etcd/blob/main/Makefile#L42)
1. Update checksums and attribution using `make update-attribution-checksums-docker PROJECT=etcd-io/etcd RELEASE_BRANCH=<release_branch>` from the root of the repo.
1. Update the version at the top of this Readme.
