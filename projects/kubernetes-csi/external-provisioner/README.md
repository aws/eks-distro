## CSI external-provisioner

| Release | Version                                                      |
|---------|--------------------------------------------------------------|
| 1-22    | ![Version](https://img.shields.io/badge/version-v3.5.0-blue) |
| 1-23    | ![Version](https://img.shields.io/badge/version-v3.5.0-blue) |
| 1-24    | ![Version](https://img.shields.io/badge/version-v3.5.0-blue) |
| 1-25    | ![Version](https://img.shields.io/badge/version-v3.5.0-blue) |
| 1-26    | ![Version](https://img.shields.io/badge/version-v3.5.0-blue) |

### Updating

1. Determine the version of CSI external-provisioner to use.
   1. Consult the EKS team and consider options among the 
      [supported versions](https://kubernetes-csi.github.io/docs/external-provisioner.html#supported-versions). 
   2. Review [releases](https://github.com/kubernetes-csi/external-provisioner/releases),
      [tags](https://github.com/kubernetes-csi/external-provisioner/tags),
      and [changelogs](https://github.com/kubernetes-csi/external-provisioner/tree/master/CHANGELOG),
      carefully looking for updates that may affect EKS-Distro or downstream 
      projects like EKS-Anywhere.
2. Update the `GIT_TAG` file to have the new, desired version based on the 
   `external-provisioner` release tags.
3. Compare the old tag to the new one, looking specifically for Makefile changes.
   For example:
   [v2.1.1 compared to v2.2.2](https://github.com/kubernetes-csi/external-provisioner/compare/v2.1.1...v2.2.2).
   Check the `external-provisioner` target for any build flag changes, tag 
   changes, dependencies, etc. Check that the manifest target, which is called
   from the EKS-D Makefile, has not changed.
4. Verify the Golang version has not changed. The Golang version defined in
   [`CSI_PROW_GO_VERSION_BUILD`](https://github.com/kubernetes-csi/external-provisioner/blob/v3.1.1/release-tools/prow.sh#L89)
   is likely the correct one. Be sure to select the correct branch for the
   project version when checking the Golang version.
5. Update CHECKSUMS and attribution by running from project root:
   `make run-attribution-checksums-in-docker RELEASE_BRANCH=<release_branch>` 
   from the root of the EKS-Distro repo.
6. Update the version at the top of this README.
