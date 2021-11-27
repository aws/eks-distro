BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat ./$(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?=$(shell cat ./$(RELEASE_BRANCH)/GOLANG_VERSION)

REPO=release-src
REPO_OWNER=kubernetes
# REPO cant be releae since there is a phony release target
# using release-src and overriding component
COMPONENT=$(REPO_OWNER)/release

GO_RUNNER_IMAGE_COMPONENT?=kubernetes/go-runner
KUBE_PROXY_BASE_IMAGE_COMPONENT?=kubernetes/kube-proxy-base

LICENSE_PACKAGE_FILTER=./go-runner.go
IPTABLES_WRAPPER=$(OUTPUT_DIR)/iptables-wrapper

REPO_SUBPATH=images/build/go-runner
BINARY_TARGET_FILES=go-runner
SOURCE_PATTERNS=.

DOCKERFILE_FOLDER=./docker/$(IMAGE_NAME)

HAS_RELEASE_BRANCHES=true

include $(BASE_DIRECTORY)/Common.mk


$(call IMAGE_TARGETS_FOR_NAME, kube-proxy-base): $(IPTABLES_WRAPPER)

$(ATTRIBUTION_TARGETS): fix-licenses

$(IPTABLES_WRAPPER): $(GIT_CHECKOUT_TARGET)
	@mkdir -p $(@D)
	cp $(REPO)/images/build/debian-iptables/buster/iptables-wrapper $@

.PHONY: local-images
local-images: go-runner/images/amd64 kube-proxy-base/images/amd64

.PHONY: images
images: go-runner/images/push kube-proxy-base/images/push

.PHONE: fix-licenses
fix-licenses: $(GATHER_LICENSES_TARGETS)
	build/fix_licenses.sh $(OUTPUT_DIR)
