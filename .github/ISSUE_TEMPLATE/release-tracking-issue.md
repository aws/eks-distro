---
name: Release Tracking Issue
about: Handy template for release tracking
title: 'Releases: '
labels: release
assignees: ''

---

## KEY
✏️ –– PR opened
`1-XX` –– used a placeholder for release branch (e.g., `1-23`) in inline code formatted text
`Z` –– used a placeholder for release number (e.g., `3`) in inline code formatted text

---
## {RELEASE_VERSION_NUMBER}

### Handle Existing PRs and Start Code Freeze for Non-Release Related Changes
- [ ] For PRs created by `eks-distro-pr-bot` in the below repos, review and merge changes
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls/eks-distro-pr-bot)
- [ ]  For non-EKS-D-bot PRs in the below repos,  review and merge all un-held/non-WIP/production-ready/non-breaking PRs intended for the release or release process; follow up with the authors of the remaining PRs about if the changes are intended for the release and, if so, what additional work needs to be done.
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls?q=is%3Apr+is%3Aopen+-author%3Aeks-distro-pr-bot)

### Check for and Make Any Additional Release-Related Changes
- [ ]  Check for new project versions
  - [ ] kubernetes/kubernetes
  - [ ] containernetworking/plugins
  - [ ] coredns/coredns
  - [ ] [kubernetes-sigs/metrics-server](https://github.com/kubernetes-sigs/metrics-server/releases)
  - [ ] [kubernetes-sigs/aws-iam-authenticator](https://github.com/kubernetes-sigs/aws-iam-authenticator/releases)
  - [ ] etcd-io/etcd
  - [ ] [kubernetes-csi/external-attacher](https://github.com/kubernetes-csi/external-attacher/releases)
  - [ ] [kubernetes-csi/external-provisioner](https://github.com/kubernetes-csi/external-provisioner/releases)
  - [ ] [kubernetes-csi/external-resizer](https://github.com/kubernetes-csi/external-resizer/releases)
  - [ ] [kubernetes-csi/external-snapshotter](https://github.com/kubernetes-csi/external-snapshotter/releases)
  - [ ] [kubernetes-csi/livenessprobe](https://github.com/kubernetes-csi/livenessprobe/releases)
  - [ ] [kubernetes-csi/node-driver-registrar](https://github.com/kubernetes-csi/node-driver-registrar/releases)
- [ ] Check for patch changes
- [ ] After all the release-related changes are done, recheck for new PRs created by `eks-distro-pr-bot` in the below repos; review and merge them
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls/eks-distro-pr-bot)

### Cut Release
- [ ] Open and merge dev release PR
- [ ] Confirm [Prow jobs](https://prow.eks.amazonaws.com/?repo=aws%2Feks-distro&type=postsubmit&job=*1-2*) `dev-release-1-XX-postsubmit` and `build-1-XX-postsubmit` finished successfully
- [ ] Open and merge prod release PR
- [ ] Confirm prod release was successful
  - [ ] [Prow jobs](https://prow.eks.amazonaws.com/?repo=aws%2Feks-distro&type=postsubmit&job=*1-2*) `prod-release-1-XX-postsubmit` and `build-1-XX-postsubmit` finished successfully
  - [ ]  Release manifest is available and looks right (`https://distro.eks.amazonaws.com/kubernetes-1-XX/kubernetes-1-XX-eks-Z.yaml`)
  - [ ] Images are in [ECR](https://gallery.ecr.aws/eks-distro) 

### Announce Release (*1.19 - 1.22 only*)
- [ ] Update docs (`RELEASE_BRANCH=1-XX make docs` + additional manual changes) and get someone to actually review PR
- [ ] Confirm docs changes
  - [ ] Check [website](https://distro.eks.amazonaws.com/) was updated
  - [ ] Check that SNS was received
- [ ] Tag release (`RELEASE_GIT_TAG=v1-XX-eks-Z RELEASE_GIT_COMMIT_HASH=<docs_commit_hash> make tag)`
- [ ] Generate [Release on GitHub](https://github.com/aws/eks-distro/releases) from tag  (`RELEASE_BRANCH=1-XX make github-release`)
- [ ] Notify Slack channel

### Update Other Projects
- [ ] Open EKS-A PR (see [example](https://github.com/aws/eks-anywhere-build-tooling/pull/965))
- [ ] Open BottleRocket PR  –– 1.22 - 1.23 only (see [example](https://github.com/bottlerocket-os/bottlerocket/pull/2230))
- [ ] Update BottleRocket
