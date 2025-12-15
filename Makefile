BASE_DIRECTORY:=$(shell git rev-parse --show-toplevel)
RELEASE_BRANCH?=$(shell cat $(BASE_DIRECTORY)/release/DEFAULT_RELEASE_BRANCH)
SUPPORTED_RELEASE_BRANCHES?=$(shell cat $(BASE_DIRECTORY)/release/SUPPORTED_RELEASE_BRANCHES)
RELEASE_ENVIRONMENT?=development
RELEASE?=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/$(RELEASE_ENVIRONMENT)/RELEASE)
PROD_RELEASE=$(shell cat $(BASE_DIRECTORY)/release/$(RELEASE_BRANCH)/production/RELEASE)
OVERRIDE_NUMBER?=-1
WITH_GIT_AND_PR=true
ARTIFACT_BUCKET?=my-s3-bucket

AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2
IMAGE_REPO?=$(if $(AWS_ACCOUNT_ID),$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com,localhost:5000)
RELEASE_AWS_PROFILE?=default

RELEASE_GIT_TAG?=v$(RELEASE_BRANCH)-eks-$(PROD_RELEASE)
RELEASE_GIT_COMMIT_HASH?=$(shell git rev-parse @)

REBUILD_ALL?=false

ALL_PROJECTS=kubernetes_release kubernetes_kubernetes containernetworking_plugins coredns_coredns etcd-io_etcd \
	kubernetes_cloud-provider-aws kubernetes-sigs_aws-iam-authenticator

# CNI is technically not an internal build, but for the purposes of updating metadata files like GIT_TAG and GOLANG_VERSION it is
INTERNALLY_BUILT_PROJECTS=kubernetes_kubernetes kubernetes-sigs_aws-iam-authenticator containernetworking_plugins


ifdef MAKECMDGOALS
TARGET=$(MAKECMDGOALS)
else
TARGET=$(DEFAULT_GOAL)
endif

.PHONY: setup
setup:
	development/ecr/ecr-command.sh install-ecr-public
	development/ecr/ecr-command.sh login-ecr-public

# For components which build the same versions across multiple kube versions
# we use the first version which has the same git_tag as the current project build
# as the buildctl import-cache to try and converge as many builds to the same image in ecr
# This isnt neccessary since on the subsequent builds they should converge, but building
# kube first for newer versions while build all other components gives us the best chance
# to converge on the same image in the first build. This also doesnt handle cases where the
# first version is different but the next 3 are the same, in those cases it would still
# take two builds to converge 
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
		--dry-run=true \
		--rebuild-all=${REBUILD_ALL} \
		--build-kubernetes-first=$(if $(filter $(RELEASE_BRANCH),$(firstword $(SUPPORTED_RELEASE_BRANCHES))),false,true)
	@echo 'Done' $(TARGET)

.PHONY: postsubmit-build
postsubmit-build: setup
	go vet cmd/main_postsubmit.go
	go run cmd/main_postsubmit.go \
		--target=release,clean,clean-go-cache \
		--release-branch=${RELEASE_BRANCH} \
		--release=${RELEASE} \
		--region=${AWS_REGION} \
		--account-id=${AWS_ACCOUNT_ID} \
		--image-repo=${IMAGE_REPO} \
		--artifact-bucket=$(ARTIFACT_BUCKET) \
		--dry-run=false \
		--rebuild-all=${REBUILD_ALL}

.PHONY: kops
kops: export UBUNTU_RELEASE=jammy-22.04
kops: $(if $(CODEBUILD_BUILD_ID),kops-codebuild,kops-prow)

.PHONY: kops-codebuild
kops-codebuild: KOPS_ENTRYPOINT=development/kops/codebuild.sh
kops-codebuild: kops-amd kops-arm
	@echo 'Done kops-codebuild'

.PHONY: kops-prow
kops-prow: KOPS_ENTRYPOINT=development/kops/prow.sh
kops-prow: kops-amd kops-arm
	@echo 'Done kops-prow'

.PHONY: kops-amd
kops-amd: kops-prereqs
	RELEASE=$(RELEASE) $(KOPS_ENTRYPOINT)

.PHONY: kops-arm
kops-arm: export NODE_INSTANCE_TYPE=t4g.medium
kops-arm: export NODE_ARCHITECTURE=arm64
kops-arm: export UBUNTU_RELEASE=jammy-22.04
kops-arm: kops-prereqs
	export IPV6=true; \
	sleep 5m; \
	RELEASE=$(RELEASE) $(KOPS_ENTRYPOINT);

.PHONY: kops-arm-ubuntu-22
kops-arm-ubuntu-22: export UBUNTU_RELEASE=jammy-22.04
kops-arm-ubuntu-22: kops-prereqs
	sleep 10m; \
	RELEASE=$(RELEASE) $(KOPS_ENTRYPOINT);

.PHONY: kops-prereqs
kops-prereqs: $(if $(filter presubmit,$(JOB_TYPE)),,postsubmit-build)
	ssh-keygen -b 2048 -t rsa -f ~/.ssh/id_rsa -q -N ""
	cd development/kops && RELEASE=$(RELEASE) ./install_requirements.sh

.PHONY: postsubmit-conformance
postsubmit-conformance: RELEASE:=$(shell echo  $$(($(RELEASE) + 1))).pre
postsubmit-conformance: postsubmit-build kops
	@echo 'Done postsubmit-conformance'

.PHONY: tag
tag:
	git tag -a $(RELEASE_GIT_TAG) $(RELEASE_GIT_COMMIT_HASH) -m $(RELEASE_GIT_TAG)
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
	$(MAKE) release clean clean-go-cache -C $(PROJECT_PATH)

.PHONY: binaries
binaries: $(addprefix makes-binaries-, $(ALL_PROJECTS))
	@echo 'Done' $(TARGET)

.PHONY: makes-binaries-%
makes-binaries-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) binaries -C $(PROJECT_PATH)

.PHONY: run-target-in-docker
run-target-in-docker:
	build/lib/run_target_docker.sh $(PROJECT) $(MAKE_TARGET) $(IMAGE_REPO) $(RELEASE_BRANCH)

.PHONY: stop-docker-builder
stop-docker-builder:
	docker rm -f -v eks-d-builder

.PHONY: run-buildkit-and-registry
run-buildkit-and-registry:
	docker run -d --name buildkitd --net host --privileged moby/buildkit:v0.12.3
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
	build/update-attribution-files/create_pr.sh attribution

.PHONY: attribution-files-project-%
attribution-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) -C $(PROJECT_PATH) all-attributions

.PHONY: update-attribution-files
update-attribution-files: add-generated-help-block internal-build-files go-mod-files attribution-files

.PHONY: checksum-files-project-%
checksum-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) -C $(PROJECT_PATH) all-checksums

.PHONY: update-checksum-files
update-checksum-files: $(addprefix checksum-files-project-, $(ALL_PROJECTS))
	build/lib/update_go_versions.sh
	build/update-attribution-files/create_pr.sh checksums

.PHONY: go-mod-files-project-%
go-mod-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) -C $(PROJECT_PATH) all-update-go-mods

.PHONY: go-mod-files
go-mod-files: $(addprefix go-mod-files-project-, $(ALL_PROJECTS))
	build/update-attribution-files/create_pr.sh go-mod

.PHONY: internal-build-files-project-%
internal-build-files-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	for release_branch in $(SUPPORTED_RELEASE_BRANCHES); do RELEASE_BRANCH=$$release_branch PUSH_IMAGES="false" $(MAKE) -C $(PROJECT_PATH) update-internal-build-files; done

.PHONY: internal-build-files
internal-build-files: $(addprefix internal-build-files-project-, $(INTERNALLY_BUILT_PROJECTS))
	INTERNALLY_BUILT_PROJECTS="$(INTERNALLY_BUILT_PROJECTS)" build/update-attribution-files/create_pr.sh internal-builds

.PHONY: add-generated-help-block-project-%
add-generated-help-block-project-%:
	$(eval PROJECT_PATH=projects/$(subst _,/,$*))
	$(MAKE) add-generated-help-block -C $(PROJECT_PATH)

.PHONY: add-generated-help-block
add-generated-help-block: $(addprefix add-generated-help-block-project-, $(ALL_PROJECTS))
	build/update-attribution-files/create_pr.sh help

.PHONY: update-release-number
update-release-number:
	go vet ./cmd/release/number
	go run ./cmd/release/number/main.go \
		--branch=$(RELEASE_BRANCH) \
		--isProd=$(is_update_prod_number)

.PHONY: update-dev-release-number
update-dev-release-number:
	$(MAKE) is_update_prod_number=false update-release-number

.PHONY: update-prod-release-number
update-prod-release-number:
	$(MAKE) is_update_prod_number=true update-release-number

.PHONY: update-release-numbers
update-release-numbers: update-dev-release-number update-prod-release-number

.PHONY: update-all-release-numbers
update-all-release-numbers:
	for r_b in $(SUPPORTED_RELEASE_BRANCHES); do RELEASE_BRANCH=$$r_b $(MAKE) update-release-numbers; done

.PHONY: update-all-dev-release-numbers
update-all-dev-release-numbers:
	for r_b in $(SUPPORTED_RELEASE_BRANCHES); do RELEASE_BRANCH=$$r_b $(MAKE) update-dev-release-number; done

.PHONY: update-all-prod-release-numbers
update-all-prod-release-numbers:
	for r_b in $(SUPPORTED_RELEASE_BRANCHES); do RELEASE_BRANCH=$$r_b $(MAKE) update-prod-release-number; done

# See important note about minor releases in the Go function called.
# release-docs is intended to be used to generate release docs for the latest release branch. If this command is used in
# conjunction with release-docs-limited to make all the release docs for a new minor release, WITH_GIT_AND_PR should be
# set to false, as presumably there are additional changes that have been made by multiple run of release-docs-limited.
.PHONY: release-docs
release-docs:
	go vet ./cmd/release/docs
	go run ./cmd/release/docs/main.go \
		--branch=$(RELEASE_BRANCH) \
		--manageGitAndOpenPR=$(WITH_GIT_AND_PR)

# See important note about minor releases in the Go function called.
# release-docs-limited is intended to be used to generate docs for multiple release for new minor releases. This make
# command should be run for all releases from 1 until *** one less than *** the latest prod number. For example, if the
# prod release number is 4, it should be run 3 times and the overrideNumber flag should be used to set the release
# number to 1, then 2, then 3. For the latest release (which is 4 in the example), make release-docs should be used
# instead of release-docs-limited. See that make command's comment for additional information
.PHONY: release-docs-limited
release-docs-limited:
	go vet ./cmd/release/docs
	go run ./cmd/release/docs/main.go \
		--branch=$(RELEASE_BRANCH) \
		--manageGitAndOpenPR=false \
		--releaseAnnouncement=false \
		--optionalOverrideNumber=$(OVERRIDE_NUMBER)

.PHONY: github-release
github-release:
	go vet ./cmd/release/gh-release
	go run ./cmd/release/gh-release/main.go \
		--branch=$(RELEASE_BRANCH) \
		--overrideNumber=$(OVERRIDE_NUMBER)

.PHONY: minor-release-foundation
minor-release-foundation:
	go vet ./cmd/release/minor
	go run ./cmd/release/minor/main.go

.PHONY: print-versions
print-versions:
	go vet ./cmd/print-versions
	go run ./cmd/print-versions/main.go


