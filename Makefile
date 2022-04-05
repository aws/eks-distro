BASE_DIRECTORY=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
SUPPORTED_RELEASE_BRANCHES?=$(shell cat $(BASE_DIRECTORY)/release/SUPPORTED_RELEASE_BRANCHES)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
ARTIFACT_BUCKET?=my-s3-bucket

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2
IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)
RELEASE_AWS_PROFILE?=default

USE_PREV_RELEASE_MANIFEST?=false
OPEN_PR?=true
IS_LOCAL_RELEASE_NUMBER_FOR_NEW_RELEASE?=true

RELEASE_GIT_TAG?=v$(RELEASE_BRANCH)-eks-$(RELEASE)
RELEASE_GIT_COMMIT_HASH?=$(shell git rev-parse @)

ALL_PROJECTS=containernetworking_plugins coredns_coredns etcd-io_etcd kubernetes-csi_external-attacher kubernetes-csi_external-resizer \
	kubernetes-csi_livenessprobe kubernetes-csi_node-driver-registrar kubernetes-sigs_aws-iam-authenticator kubernetes-sigs_metrics-server \
	kubernetes-csi_external-snapshotter kubernetes-csi_external-provisioner kubernetes_release kubernetes_kubernetes

ifdef MAKECMDGOALS
TARGET=$(MAKECMDGOALS)
else
TARGET=$(DEFAULT_GOAL)
endif

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

.PHONY: kops-prow-arm
kops-prow-arm: export NODE_INSTANCE_TYPE=t4g.medium
kops-prow-arm: export NODE_ARCHITECTURE=arm64
kops-prow-arm: kops-prereqs
	$(eval MINOR_VERSION=$(subst 1-,,$(RELEASE_BRANCH)))
	if [[ $(MINOR_VERSION) -ge 22 ]]; then \
		export IPV6=true; \
	fi; \
	if [[ $(MINOR_VERSION) -ge 21 ]]; then \
		sleep 5m; \
		RELEASE=$(RELEASE) development/kops/prow.sh; \
	fi;

.PHONY: kops-prow-amd
kops-prow-amd: kops-prereqs
	RELEASE=$(RELEASE) development/kops/prow.sh

.PHONY: kops-prow
kops-prow: kops-prow-amd kops-prow-arm
	@echo 'Done kops-prow'

.PHONT: kops-prereqs
kops-prereqs: postsubmit-build
	ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	cd development/kops && RELEASE=$(RELEASE) ./install_requirements.sh

.PHONY: postsubmit-conformance
postsubmit-conformance: RELEASE:=$(shell echo  $$(($(RELEASE) + 1))).pre
postsubmit-conformance: postsubmit-build kops-prow 
	@echo 'Done postsubmit-conformance'

.PHONY: tag
tag:
	git tag --a $(RELEASE_GIT_TAG) -m $(RELEASE_GIT_TAG) $(RELEASE_GIT_COMMIT_HASH)
	git push upstream $(RELEASE_GIT_TAG)

.PHONY: upload
upload:
	release/generate_crd.sh $(RELEASE_BRANCH) $(RELEASE) $(IMAGE_REPO)
	release/s3_sync.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET) true
	@echo 'Done' $(TARGET)

.PHONY: release
release: $(addprefix makes-release-, $(ALL_PROJECTS)) upload
	@echo 'Done' $(TARGET)

.PHONY: makes-release-%
makes-release-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) release -C $(PROJECT_PATH)

.PHONY: binaries
binaries: $(addprefix makes-binaries-, $(ALL_PROJECTS))
	@echo 'Done' $(TARGET)

.PHONY: makes-binaries-%
makes-binaries-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) binaries -C $(PROJECT_PATH)

.PHONY: run-target-in-docker
run-target-in-docker:
	build/lib/run_target_docker.sh $(PROJECT) $(MAKE_TARGET) $(RELEASE_BRANCH) $(IMAGE_REPO)

.PHONY: update-attribution-checksums-docker
update-attribution-checksums-docker:
	build/lib/update_checksum_docker.sh $(PROJECT) $(RELEASE_BRANCH)

.PHONY: stop-docker-builder
stop-docker-builder:
	docker rm -f -v eks-d-builder

.PHONY: run-buildkit-and-registry
run-buildkit-and-registry:
	docker run -d --name buildkitd --net host --privileged moby/buildkit:v0.9.3-rootless
	docker run -d --name registry  --net host registry:2

.PHONY: stop-buildkit-and-registry
stop-buildkit-and-registry:
	docker rm -v --force buildkitd
	docker rm -v --force registry

.PHONY: clean
clean: $(addprefix makes-clean-, $(ALL_PROJECTS))
	@echo 'Done' $(TARGET)

.PHONY: makes-clean-%
makes-clean-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) clean -C $(PROJECT_PATH)

.PHONY: attribution-files
attribution-files: $(addprefix attribution-files-project-, $(ALL_PROJECTS))
	cat _output/total_summary.txt

.PHONY: attribution-files-project-%
attribution-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	build/update-attribution-files/make_attribution.sh $(PROJECT_PATH) attribution

.PHONY: update-attribution-files
update-attribution-files: add-generated-help-block attribution-files checksum-files
	build/lib/update_go_versions.sh
	build/update-attribution-files/create_pr.sh

.PHONY: checksum-files-project-%
checksum-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	build/update-attribution-files/make_attribution.sh $(PROJECT_PATH) checksums

.PHONY: checksum-files
checksum-files: $(addprefix checksum-files-project-, $(ALL_PROJECTS))
	build/update-attribution-files/create_pr.sh

.PHONY: add-generated-help-block-project-%
add-generated-help-block-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) add-generated-help-block -C $(PROJECT_PATH) RELEASE_BRANCH=1-21

.PHONY: add-generated-help-block
add-generated-help-block: $(addprefix add-generated-help-block-project-, $(ALL_PROJECTS))
	build/update-attribution-files/create_pr.sh

.PHONY: update-release-number
update-release-number:
	go vet ./cmd/release/number
	go run ./cmd/release/number/main.go \
		--branch=$(RELEASE_BRANCH) \
		--openPR=$(OPEN_PR)

.PHONY: update-all-release-numbers
update-all-release-numbers:
	for r_b in $(SUPPORTED_RELEASE_BRANCHES); do RELEASE_BRANCH=$$r_b $(MAKE) update-release-number; done

.PHONY: release-docs
release-docs:
	go vet ./cmd/release/docs
	go run ./cmd/release/docs/main.go \
		--branch=$(RELEASE_BRANCH) \
		--usePrevReleaseManifestForComponentTable=$(USE_PREV_RELEASE_MANIFEST) \
		--openPR=$(OPEN_PR) \
		--isLocalReleaseNumberForNewRelease=$(IS_LOCAL_RELEASE_NUMBER_FOR_NEW_RELEASE)

.PHONY: only-index-md-from-existing-release-manifest
only-index-md-from-existing-release-manifest:
	go vet ./cmd/release/docs
	go run ./cmd/release/docs/main.go \
		--branch=$(RELEASE_BRANCH) \
		--includeIndex=true \
		--includeIndexComponentTable=true \
		--usePrevReleaseManifestForComponentTable=false \
		--includeChangelog=false \
		--includeAnnouncement=false \
		--includeREADME=false \
		--includeDocsIndex=false \
		--force=true

