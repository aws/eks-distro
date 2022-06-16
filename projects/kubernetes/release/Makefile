BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=release-src
REPO_OWNER=kubernetes
# REPO cant be releae since there is a phony release target
# using release-src and overriding component
COMPONENT=$(REPO_OWNER)/release
CLONE_URL=https://github.com/$(COMPONENT).git

GO_RUNNER_IMAGE_COMPONENT?=kubernetes/go-runner
KUBE_PROXY_BASE_IMAGE_COMPONENT?=kubernetes/kube-proxy-base
IMAGE_NAMES=go-runner kube-proxy-base

# Name of base image to be used when building the kube-proxy-base image
KUBE_PROXY_BASE_BASE_IMAGE_NAME=$(if $(IS_BUILDING_MINIMAL),eks-distro-minimal-base-iptables,eks-distro-base)

LICENSE_PACKAGE_FILTER=./go-runner.go
IPTABLES_WRAPPER=$(OUTPUT_DIR)/iptables-wrapper

BINARY_TARGET_FILES=go-runner
GO_MOD_PATHS=images/build/go-runner
# create default attribution name and save licneses in default _output/attribution folder instead
# of with go-runner prefix
GO_RUNNER_ATTRIBUTION_OVERRIDE=

DOCKERFILE_FOLDER=./docker/$(IMAGE_NAME)

HAS_RELEASE_BRANCHES=true

FIX_LICENSES_GO_RUNNER_TARGET=$(REPO)/images/build/go-runner/LICENSE

include $(BASE_DIRECTORY)/Common.mk


$(GATHER_LICENSES_TARGETS): | $(FIX_LICENSES_GO_RUNNER_TARGET)

$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): $(IPTABLES_WRAPPER)
$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): IMAGE_TARGET=$(RELEASE_VARIANT)
$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): BASE_IMAGE_NAME=$(KUBE_PROXY_BASE_BASE_IMAGE_NAME)

$(ATTRIBUTION_TARGETS): fix-licenses

$(IPTABLES_WRAPPER): $(GIT_CHECKOUT_TARGET)
	@mkdir -p $(@D)
	cp $(REPO)/images/build/debian-iptables/buster/iptables-wrapper $@

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh $(OUTPUT_DIR)

$(FIX_LICENSES_GO_RUNNER_TARGET): | $(GO_MOD_DOWNLOAD_TARGETS)
#go-licenses requires a LICENSE file in each folder with the go.mod
	cp $(REPO)/LICENSE $@


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
########### END GENERATED ###########################
