BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat $(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=aws-iam-authenticator
REPO_OWNER=kubernetes-sigs

BINARY_TARGET_FILES=aws-iam-authenticator
SOURCE_PATTERNS=./cmd/aws-iam-authenticator

PKG=sigs.k8s.io/aws-iam-authenticator
GIT_COMMIT=$(shell git -C $(REPO) describe --always --abbrev=0)
EXTRA_GO_LDFLAGS=-X $(PKG)/pkg.Version=$(GIT_TAG:v%=%) -X $(PKG)/pkg.CommitID=$(GIT_COMMIT)

BINARY_PLATFORMS=linux/amd64 linux/arm64 darwin/amd64 windows/amd64

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

BUILDER_IMAGE=$(EKS_DISTRO_BASE_IMAGE)

include $(BASE_DIRECTORY)/Common.mk

build: validate-cli-version
release: validate-cli-version

.PHONY: validate-cli-version
validate-cli-version: CLI=./$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/$(REPO)
validate-cli-version: $(BINARY_TARGETS)
	$(CLI) version
	@if [[ "$$($(CLI) version --short)" != "$(GIT_TAG:v%=%)" ]]; then \
		echo "Version set incorrectly on cli!"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
