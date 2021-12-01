BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
GIT_TAG?=$(shell cat $(RELEASE_BRANCH)/GIT_TAG)
GOLANG_VERSION?="1.13"

REPO=aws-iam-authenticator
REPO_OWNER=kubernetes-sigs

BINARY_TARGET_FILES=aws-iam-authenticator
SOURCE_PATTERNS=./cmd/aws-iam-authenticator
EXTRA_GO_LDFLAGS=-X main.version=$(GIT_TAG) -X main.commit=$(shell git -C $(REPO) rev-list -n 1  "${GIT_TAG}")

BINARY_PLATFORMS=linux/amd64 linux/arm64 darwin/amd64 windows/amd64

HAS_RELEASE_BRANCHES=true
HAS_S3_ARTIFACTS=true

include $(BASE_DIRECTORY)/Common.mk
