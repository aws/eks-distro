BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=etcd
REPO_OWNER=etcd-io

BINARY_TARGET_FILES=etcd etcdctl
SOURCE_PATTERNS=./ ./
EXTRA_GOBUILD_FLAGS=-installsuffix cgo

ROOT_MODULE=go.etcd.io/etcd
ifeq (1-22,$(RELEASE_BRANCH))
ROOT_MODULE=go.etcd.io/etcd/api/v3
endif

EXTRA_GO_LDFLAGS=-X $(ROOT_MODULE)/version.GitSHA=$(shell git -C $(REPO) rev-parse --short $(GIT_TAG))

# When creating a local image IMAGE_PLATFORMS will be either linux/amd64 or linux/arm64
IMAGE_OUTPUT_DIR=$(OUTPUT_DIR)/images/bin/$(IMAGE_PLATFORMS)
BUILD_OCI_TARS=true

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

ifeq (1-22,$(RELEASE_BRANCH))
ATTRIBUTION_TARGETS=ATTRIBUTION.txt ETCDCTL_ATTRIBUTION.txt
GATHER_LICENSES_TARGETS=$(OUTPUT_DIR)/attribution/go-license.csv $(OUTPUT_DIR)/etcdctl/attribution/go-license.csv
GO_MOD_DOWNLOAD_TARGETS=$(REPO)/eks-distro-go-mod-download $(REPO)/etcdctl/eks-distro-go-mod-download
endif

include $(BASE_DIRECTORY)/Common.mk

ifeq (1-22,$(RELEASE_BRANCH))
_output/1-22/bin/etcd/linux-amd64/etcdctl \
	$(REPO)/etcdctl/eks-distro-go-mod-download \
	$(OUTPUT_DIR)/etcdctl/attribution/go-license.csv: REPO_SUBPATH=./etcdctl

$(OUTPUT_DIR)/etcdctl/attribution/go-license.csv $(RELEASE_BRANCH)/ETCDCTL_ATTRIBUTION.txt: LICENSES_OUTPUT_DIR=$(OUTPUT_DIR)/etcdctl
endif

########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
