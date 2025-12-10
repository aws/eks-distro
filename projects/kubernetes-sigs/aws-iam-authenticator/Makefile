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

# Environment variables to support copying the internally built artifacts instead of
# rebuilding from EKS-D repo source
ifdef RELEASE_BRANCH
_bootstrap:=$(shell REPO=$(REPO) ./build/bootstrap_copy_release_variables.sh)
export GIT_TAG:=$(shell cat .git_tag)
export GOLANG_VERSION:=$(shell cat .go-version)
export ARTIFACTS_SOURCE_S3_PATH:=$(shell cat .s3_sync_path)
$(if $(GIT_TAG),$(shell rm -f .git_tag),$(error GIT_TAG is empty, .git_tag might be missing))
$(if $(GOLANG_VERSION),$(shell rm -f .go-version),$(error GOLANG_VERSION is empty, .go-version might be missing))
$(if $(ARTIFACTS_SOURCE_S3_PATH),$(shell rm -f .s3_sync_path),$(error ARTIFACTS_SOURCE_S3_PATH is empty, .s3_sync_path might be missing))
endif

PUSH_IMAGES ?= true
BUILD_ARTIFACTS ?= false
COPY_ARTIFACTS_SCRIPT = RELEASE=$(RELEASE) \
	IMAGE_REPO=$(IMAGE_REPO) \
	IMAGE_NAMES="$(REPO_OWNER)/$(REPO)" \
	SOURCE_ECR_REG=$(DEV_ECR_REG) \
	GO_RUNNER_IMAGE=$(GO_RUNNER_IMAGE) \
	MAKE_ROOT=$(MAKE_ROOT) \
	PUSH_IMAGES=$(PUSH_IMAGES) \
	$(BASE_DIRECTORY)/build/lib/copy_internal_build_artifacts.sh && chmod +x _output/*


include $(BASE_DIRECTORY)/Common.mk

build: validate-cli-version
release: validate-cli-version

.PHONY: validate-cli-version
validate-cli-version: CLI=./$(OUTPUT_BIN_DIR)/$(subst /,-,$(BUILDER_PLATFORM))/$(REPO)
validate-cli-version: binaries
	$(CLI) version
	@if [[ "$$($(CLI) version --short)" != "$(GIT_TAG)" ]]; then \
		echo "Version set incorrectly on cli! Expected: $(GIT_TAG), Actual: $$($(CLI) version --short)"; \
		exit 1; \
	fi


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
