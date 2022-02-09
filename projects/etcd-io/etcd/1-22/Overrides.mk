# 1-22 introduced seperate go.mod files for etcd server and etcdctl
# our build tooling around licenses + attribution is setup around go.mod files
# for 1-22+ we are going to create seperate attribution files
SOURCE_PATTERNS=. .
LICENSE_PACKAGE_FILTER=.
GO_MOD_PATHS=server etcdctl

# create default attribution name and save licneses in default _output/attribution folder instead
# of with etcd prefix
ETCD_ATTRIBUTION_OVERRIDE=

# this changed between 1-21 and 1-22
ROOT_MODULE=go.etcd.io/etcd/api/v3
