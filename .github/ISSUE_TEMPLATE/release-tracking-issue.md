---
name: Release Tracking Issue
about: Handy template for release tracking
title: 'Releases: '
labels: release
assignees: ''

---
### Handle Existing PRs (Mon)
- [ ] For PRs created by `eks-distro-pr-bot` in the below repos, review and merge changes
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls/eks-distro-pr-bot)
- [ ]  For PRs not created by `eks-distro-pr-bot` in the below repos, review and merge all un-held/non-WIP/production-ready/non-breaking PRs intended for the release or release process; follow up with the authors of the remaining PRs about if the changes are intended for the release and, if so, what additional work needs to be done.
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)

### Check for new project versions (Mon/Tues)
#### EKS
  - [ ] kubernetes/kubernetes
  - [ ] kubernetes/cloud-provider-aws
  - [ ] kubernetes-sigs/aws-iam-authenticator
  - [ ] containernetworking/plugins
  - [ ] coredns/coredns
  - [ ] etcd-io/etcd
#### EKS-D
  - [ ] [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server/releases)
  - [ ] [kubernetes-csi/external-attacher](https://github.com/kubernetes-csi/external-attacher/releases)
  - [ ] [kubernetes-csi/external-provisioner](https://github.com/kubernetes-csi/external-provisioner/releases)
  - [ ] [kubernetes-csi/external-resizer](https://github.com/kubernetes-csi/external-resizer/releases)
  - [ ] [kubernetes-csi/external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter/releases)
  - [ ] [kubernetes-csi/livenessprobe](https://github.com/kubernetes-csi/livenessprobe/releases)
  - [ ] [kubernetes-csi/node-driver-registrar](https://github.com/kubernetes-csi/node-driver-registrar/releases)

### Check for patch changes (Mon/Tues)
  - [ ] Check for patches for all versions

### Start Code Freeze (Tues)
- [ ] Announce code freeze, via slack, for Non-Release Related Changes

### Recheck for new PRs (Wed)
- [ ] After all the release-related changes are done, recheck for new PRs created by `eks-distro-pr-bot` in the below repos; review and merge them
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls/eks-distro-pr-bot)

### *Duplicate the following sections for each branch being released*:

---

{RELEASE_BRANCH}

### Cut Dev Release (Wed AM)
- [ ] Open and merge dev release PR {RELEASE_BRANCH}
- [ ] Confirm [Prow jobs](https://prow.eks.amazonaws.com/?repo=aws%2Feks-distro&type=postsubmit&job=*1-2*) `dev-release-{RELEASE_BRANCH}-postsubmit` and `build-{RELEASE_BRANCH}-postsubmit` finished successfully

### Cut Prod Release (Thurs AM)
- [ ] Open and merge prod release PR {RELEASE_BRANCH}
- [ ] Confirm prod release was successful
  - [ ] [Prow jobs](https://prow.eks.amazonaws.com/?repo=aws%2Feks-distro&type=postsubmit&job=*1-2*) `prod-release-{RELEASE_BRANCH}-postsubmit` and `build-{RELEASE_BRANCH}-postsubmit` finished successfully
  - [ ] Release manifest is available and looks right
  - [ ] Images are in [ECR](https://gallery.ecr.aws/eks-distro) 

### Announce Release (Thurs PM)
*NOTE: upcoming releases do not get announced*
- [ ] Update docs (Running `make docs` + any additional manual changes) 
- [ ] Get PR reviewed and merged
- [ ] Confirm docs changes
  - [ ] Check [website](https://distro.eks.amazonaws.com/) was updated
  - [ ] Check that SNS was received
- [ ] Tag release
- [ ] Generate Release on GitHub from tag
- [ ] Verify [Release on GitHub](https://github.com/aws/eks-distro/releases) was created successfully
- [ ] Notify release Slack channel

---

### Post Release Tasks (Thurs PM)
- [ ] Open EKS-A PR (see [example](https://github.com/aws/eks-anywhere-build-tooling/pull/965))
- [ ] Open BottleRocket PR  –– 1.22+ only (see [example](https://github.com/bottlerocket-os/bottlerocket/pull/2230))
- [ ] Open Rover PR
