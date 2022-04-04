# Changelog for v1-22-eks-3

This changelog highlights the changes for [v1-22-eks-4](https://github.com/aws/eks-distro/tree/v1-22-eks-4).

## Component Versions

* Downgraded etcd from v3.5.2 to 2.4.18 due to potential data corruption issue.
  See [upstream etcd issue](https://github.com/etcd-io/etcd/issues/13766).
  We will reassess going back to v3.5.x (or a different version) when this
  problem is fixed.
