# Changelog for v1-18-eks-4

This changelog highlights the changes for [v1-18-eks-4](https://github.com/aws/eks-distro/tree/v1-18-eks-4).


## Version Upgrades 

### Kubernetes

Upgraded Kubernetes from v1.18.9 to [v1.18.16](https://github.com/kubernetes/kubernetes/releases/tag/v1.18.16).

### Base Image

Ungraded base image (Amazon Linux 2) version to include the latest security fixes.


## Patches 

### Removed Patch

* **0017-EKS-PATCH-Accept-healthy-instances-in-list-of-active.patch**
  * Removed because these changes were cherry-picked by upstream Kubernetes and included in the version of Kubernetes 
    used by this release of EKS-D.
  * See upstream Kubernetes [PR #97164](https://github.com/kubernetes/kubernetes/pull/97164) for additional information.

### Additional Changes to Patches
Below are additional changes to the patches in this minor release of EKS-D. These changes are functionally immaterial 
and do not impact the use or application of the patches.

  * The two patches that came after the removed patch were renamed to keep constancy for the numbering in the patch 
   filenames. The numbers in their filenames were decremented by one.
    * **0018**-EKS-PATCH-Delete-leaked-volume-<...>-kno.patch --> **0017**-EKS-PATCH-Delete-leaked-volume-<...>-kno.patch
    * **0019**-2021-25735_1_18.patch --> **0018**-2021-25735_1_18.patch
  * Minor modifications to the patches themselves to match code changes in the upgraded Kubernetes version.
    

