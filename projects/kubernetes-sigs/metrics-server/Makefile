BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=metrics-server
COMPONENT=kubernetes-sigs/$(REPO)

BINARY_TARGET_FILES=metrics-server
SOURCE_PATTERNS=./cmd/metrics-server

PKG="sigs.k8s.io/metrics-server/pkg"
GIT_COMMIT=$(shell git -C $(REPO) describe --always --abbrev=0)
BUILD_DATE=$(shell git -C $(REPO) show -s --format=format:%ct HEAD)
EXTRA_GO_LDFLAGS=-X $(PKG)/version.gitVersion=$(GIT_TAG) -X $(PKG)/version.gitCommit=$(GIT_COMMIT) -X $(PKG)/version.buildDate=$(BUILD_DATE)

HAS_RELEASE_BRANCHES=true

IMAGE_TARGET=$(RELEASE_VARIANT)

include $(BASE_DIRECTORY)/Common.mk


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
