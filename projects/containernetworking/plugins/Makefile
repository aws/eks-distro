export RELEASE_BRANCH?=1-18
export RELEASE?=1

REPO?=plugins
CLONE_URL?=https://github.com/containernetworking/$(REPO).git
GIT_TAG?=$(shell cat GIT_TAG)
BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)

ifeq ("$(REPO)","")
	$(error No repository name was provided.)
endif

ifeq ("$(CLONE_URL)","")
	$(error No clone url was provided.)
endif

ifeq ("$(GIT_TAG)","")
	$(error No git tag was provided.)
endif

.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG)

.PHONY: tarballs
tarballs:  binaries
	build/create_tarballs.sh $(REPO) $(GIT_TAG)

.PHONY: release
release:
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(RELEASE_BRANCH) $(RELEASE) containernetworking/plugins
	echo "Done kubernetes/kubernetes"

.PHONY: all
all: release

docker:

docker-push:

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"

