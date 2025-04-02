# 3.5.x introduced separate go.mod files for etcd server and etcdctl
# our build tooling around licenses + attribution is setup around go.mod files
# for 3.5.x we are going to create separate attribution files
SOURCE_PATTERNS=. .
GO_MOD_PATHS=server etcdctl

# create default attribution name and save licenses in default _output/attribution folder instead
# of with etcd prefix
ETCD_ATTRIBUTION_OVERRIDE=

# this changed between 3.4.x and 3.5.x
ROOT_MODULE=go.etcd.io/etcd/api/v3
