---
name: Release Tracking Issue
about: Handy template for release tracking
title: 'Releases: '
labels: release
assignees: ''

---

## KEY
**✏️ –– PR opened**

---
## {RELEASE_VERSION_NUMBER}
- [ ]  Check for new project versions
  - [ ] kubernetes/kubernetes
  - [ ] containernetworking/plugins
  - [ ] coredns/coredns
  - [ ] kubernetes-sigs/metrics-server
  - [ ] kubernetes-sigs/aws-iam-authenticator
  - [ ] etcd-io/etcd
  - [ ] kubernetes-csi/external-snapshotter
  - [ ] kubernetes-csi/external-attacher
  - [ ] kubernetes-csi/external-provisioner
  - [ ] kubernetes-csi/external-resizer
  - [ ] kubernetes-csi/livenessprobe
  - [ ] kubernetes-csi/node-driver-registrar
- [ ] Check for patch changes
- [ ] After all the release-related changes are done, recheck for new PRs created by `eks-distro-pr-bot` in the below repos; review and merge them
  - [ ] [eks-distro](https://github.com/aws/eks-distro/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-build-tooling](https://github.com/aws/eks-distro-build-tooling/pulls/eks-distro-pr-bot)
  - [ ] [eks-distro-prow-jobs](https://github.com/aws/eks-distro-prow-jobs/pulls/eks-distro-pr-bot)
- [ ] Cut dev release
- [ ] Cut prod release
- [ ] Confirm release manifest looks right
- [ ] Confirm images are in ECR 
- [ ] Update docs
  - [ ] Include notification about updating asap
- [ ] Tag release
- [ ] Notify Slack channel
- [ ] Update EKS-A 
- [ ] Update BottleRocket
