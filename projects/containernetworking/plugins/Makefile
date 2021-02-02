GIT_TAG?=$(shell cat GIT_TAG)

REPO=plugins
COMPONENT=containernetworking/$(REPO)
CLONE_URL=https://github.com/$(COMPONENT).git

.PHONY: binaries
binaries:
	build/create_binaries.sh $(REPO) $(CLONE_URL) $(GIT_TAG)

.PHONY: tarballs
tarballs:  binaries
	build/create_tarballs.sh $(REPO) $(GIT_TAG)

.PHONY: build
build: tarballs
	echo "Done $(COMPONENT)"

.PHONY: release
release: tarballs
	echo "Done $(COMPONENT)"

.PHONY: all
all: release

docker:

docker-push:

.PHONY: clean
clean:
	rm -rf $(REPO)
	rm -rf "_output"
