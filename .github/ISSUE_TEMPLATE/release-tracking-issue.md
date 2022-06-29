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
- [ ] Merge bot's attribution PR
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
