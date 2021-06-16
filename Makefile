BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2
IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
RELEASE_AWS_PROFILE?=default

ifdef MAKECMDGOALS
TARGET=$(MAKECMDGOALS)
else
TARGET=$(DEFAULT_GOAL)
endif

presubmit-cleanup = \
	if [ `echo $(1)|awk '{$1==$1};1'` == "build" ]; then \
		make -C $(2) clean; \
	fi

.PHONY: setup
setup:
	development/ecr/ecr-command.sh install-ecr-public
	development/ecr/ecr-command.sh login-ecr-public

.PHONY: build
build:
	go vet cmd/main_postsubmit.go
	go run cmd/main_postsubmit.go \
		--target=build \
		--release-branch=${RELEASE_BRANCH} \
		--release=${RELEASE} \
		--region=${AWS_REGION} \
		--account-id=${AWS_ACCOUNT_ID} \
		--image-repo=${IMAGE_REPO} \
		--dry-run=true
	@echo 'Done' $(TARGET)

.PHONY: postsubmit-build
postsubmit-build: setup
	go vet cmd/main_postsubmit.go
	go run cmd/main_postsubmit.go \
		--target=release \
		--release-branch=${RELEASE_BRANCH} \
		--release=${RELEASE} \
		--region=${AWS_REGION} \
		--account-id=${AWS_ACCOUNT_ID} \
		--image-repo=${IMAGE_REPO} \
		--artifact-bucket=$(ARTIFACT_BUCKET) \
		--dry-run=false

.PHONY: postsubmit-conformance
postsubmit-conformance: postsubmit-build
	development/kops/prow.sh

.PHONY: tag
tag:
	git tag --force v$(RELEASE_BRANCH)-eks-$(RELEASE)
	git push --force origin tag v$(RELEASE_BRANCH)-eks-$(RELEASE)

.PHONY: upload
upload:
	release/generate_crd.sh $(RELEASE_BRANCH) $(RELEASE) $(IMAGE_REPO)
	release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET)
	@echo 'Done' $(TARGET)

.PHONY: release
release: makes upload
	@echo 'Done' $(TARGET)

.PHONY: binaries
binaries: makes
	@echo 'Done' $(TARGET)

.PHONY: docker
docker: makes
	@echo 'Done' $(TARGET)

.PHONY: docker-push
docker-push: makes
	@echo 'Done' $(TARGET)

.PHONY: update-kubernetes-version
update-kubernetes-version:
	build/update-kubernetes-version/update.sh $(RELEASE_BRANCH)

.PHONY: clean
clean: makes
	@echo 'Done' $(TARGET)
	rm -rf _output

.PHONY: makes
makes:
	make -C projects/kubernetes/release $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes/release")
	make -C projects/kubernetes/kubernetes $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes/kubernetes")
	make -C projects/containernetworking/plugins $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/containernetworking/plugins")
	make -C projects/coredns/coredns $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/coredns/coredns")
	make -C projects/etcd-io/etcd $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/etcd-io/etcd")
	make -C projects/kubernetes-csi/external-attacher $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-attacher")
	make -C projects/kubernetes-csi/external-resizer $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-resizer")
	make -C projects/kubernetes-csi/livenessprobe $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/livenessprobe")
	make -C projects/kubernetes-csi/node-driver-registrar $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/node-driver-registrar")
	make -C projects/kubernetes-sigs/aws-iam-authenticator $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-sigs/aws-iam-authenticator")
	make -C projects/kubernetes-sigs/metrics-server $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-sigs/metrics-server")
	make -C projects/kubernetes-csi/external-snapshotter $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-snapshotter")
	make -C projects/kubernetes-csi/external-provisioner $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-provisioner")

.PHONY: attribution-files
attribution-files:
	build/update-attribution-files/make_attribution.sh projects/containernetworking/plugins
	build/update-attribution-files/make_attribution.sh projects/coredns/coredns
	build/update-attribution-files/make_attribution.sh projects/etcd-io/etcd
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/external-attacher
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/external-resizer
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/livenessprobe
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/node-driver-registrar
	build/update-attribution-files/make_attribution.sh projects/kubernetes-sigs/aws-iam-authenticator
	build/update-attribution-files/make_attribution.sh projects/kubernetes-sigs/metrics-server
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/external-snapshotter
	build/update-attribution-files/make_attribution.sh projects/kubernetes-csi/external-provisioner
	build/update-attribution-files/make_attribution.sh projects/kubernetes/release
	build/update-attribution-files/make_attribution.sh projects/kubernetes/kubernetes

	cat _output/total_summary.txt

.PHONY: update-attribution-files
update-attribution-files: attribution-files
	build/update-attribution-files/create_pr.sh

.PHONY: update-release-number
update-release-number:
	go vet ./cmd/release/number
	go run ./cmd/release/number/main.go \
		--branch=$(RELEASE_BRANCH) \
		--environment=$(RELEASE_ENVIRONMENT)

.PHONY: release-docs
release-docs:
	go vet ./cmd/release/docs
	go run ./cmd/release/docs/main.go \
		--branch=$(RELEASE_BRANCH) \
		--environment=$(RELEASE_ENVIRONMENT)
