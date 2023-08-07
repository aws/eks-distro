BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=release-src
REPO_OWNER=kubernetes
# REPO can't be release since there is a phony release target
# using release-src and overriding component
COMPONENT=$(REPO_OWNER)/release
CLONE_URL=https://github.com/$(COMPONENT).git

GO_RUNNER_IMAGE_COMPONENT?=kubernetes/go-runner
KUBE_PROXY_BASE_IMAGE_COMPONENT?=kubernetes/kube-proxy-base
IMAGE_NAMES=go-runner kube-proxy-base

# Name of base image to be used when building the kube-proxy-base image
KUBE_PROXY_BASE_BASE_IMAGE_NAME=eks-distro-minimal-base-iptables

BINARY_TARGET_FILES=go-runner
GO_MOD_PATHS=images/build/go-runner
# create default attribution name and save licenses in default _output/attribution folder instead
# of with go-runner prefix
GO_RUNNER_ATTRIBUTION_OVERRIDE=

DOCKERFILE_FOLDER=./docker/$(IMAGE_NAME)

HAS_RELEASE_BRANCHES=true

FIX_LICENSES_GO_RUNNER_TARGET=$(REPO)/images/build/go-runner/LICENSE

include $(BASE_DIRECTORY)/Common.mk


$(GATHER_LICENSES_TARGETS): | $(FIX_LICENSES_GO_RUNNER_TARGET)

# For 1.24 the project is built with 1.18 to match upstream but for some
# unknown reason the go-licenses project does not properly parse the go module
# with using 1.18 golang. This kind of an ugly solution
# but since we have not seen this anywhere else with 1.18 based projects the hope is
# this is super specific to this project and not something we have to do elsewhere
# if we start seeing this elsewhere we should dig in more and try to fix go-licenses
_output/1-24/attribution/go-license.csv: GOLANG_VERSION=1.17

$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): BASE_IMAGE_NAME=$(KUBE_PROXY_BASE_BASE_IMAGE_NAME)

$(ATTRIBUTION_TARGETS): fix-licenses


.PHONY: fix-licenses
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
