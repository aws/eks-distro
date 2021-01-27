BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
export RELEASE_BRANCH?=1-18
export RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/RELEASE)
GIT_TAG?=$(shell cat GIT_TAG)
ifeq ("$(PULL_NUMBER)","")
    ARTIFACT_TAG?=$(GIT_TAG)
else
    ARTIFACT_TAG?=$(GIT_TAG).$(PULL_NUMBER)
endif
ARTIFACT_BUCKET?=$(shell cat $(BASE_DIRECTORY)/release/ARTIFACT_BUCKET)

REPO=plugins
COMPONENT=containernetworking/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG) $(ARTIFACT_TAG)

.PHONY: tarballs
tarballs:  binaries
	build/create_tarballs.sh $(REPO) $(ARTIFACT_TAG)

.PHONY: release
release: tarballs
	$(BASE_DIRECTORY)/release/copy_artifacts.sh $(COMPONENT) $(RELEASE_BRANCH) $(RELEASE)
	$(BASE_DIRECTORY)/release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) $(REPO)
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

docker:

docker-push:

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"

