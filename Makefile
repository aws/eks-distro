RELEASE_BRANCH?="1-18"
RELEASE?="1"
DEVELOPMENT?=false
AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
AWS_REGION?=us-west-2
IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
BASE_IMAGE?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/eks-distro/base:26f234d9da8bc4423bacb539caaece931808d28b
KUBE_PROXY_BASE_IMAGE?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/kubernetes/kube-proxy-base:v0.4.2-ea45689a0da457711b15fa1245338cd0b636ad4b
GO_RUNNER_IMAGE?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/kubernetes/go-runner:v0.4.2-ea45689a0da457711b15fa1245338cd0b636ad4b
ARTIFACT_BUCKET?=my-s3-bucket

ifdef MAKECMDGOALS
TARGET=$(MAKECMDGOALS)
else
TARGET=$(DEFAULT_GOAL)
endif

presubmit-cleanup = \
	if [ `echo $(1)|awk '{$1=$1};1'` == "build" ]; then \
		make -C $(2) clean; \
	fi

.PHONY: build
build: makes
	@echo 'Done' $(TARGET)

.PHONY: release
release: makes
	bash build/lib/create_final_dir.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET)
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

.PHONY: clean
clean: makes
	@echo 'Done' $(TARGET)

makes:
	make -C projects/kubernetes/kubernetes $(TARGET)                 RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} KUBE_PROXY_BASE_IMAGE=${KUBE_PROXY_BASE_IMAGE} GO_RUNNER_IMAGE=${GO_RUNNER_IMAGE}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes/kubernetes")
	make -C projects/containernetworking/plugins $(TARGET)
	$(call presubmit-cleanup, $(TARGET), "projects/containernetworking/plugins")
	make -C projects/coredns/coredns $(TARGET)                       RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/coredns/coredns")
	make -C projects/etcd-io/etcd $(TARGET)                          RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/etcd-io/etcd")
	make -C projects/kubernetes-csi/external-attacher $(TARGET)      RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-attacher")
	make -C projects/kubernetes-csi/external-provisioner $(TARGET)   RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-provisioner")
	make -C projects/kubernetes-csi/external-resizer $(TARGET)       RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-resizer")
	make -C projects/kubernetes-csi/external-snapshotter $(TARGET)   RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/external-snapshotter")
	make -C projects/kubernetes-csi/livenessprobe $(TARGET)          RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/livenessprobe")
	make -C projects/kubernetes-csi/node-driver-registrar $(TARGET)  RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-csi/node-driver-registrar")
	make -C projects/kubernetes-sigs/aws-iam-authenticator $(TARGET) RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-sigs/aws-iam-authenticator")
	make -C projects/kubernetes-sigs/metrics-server $(TARGET)        RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} BASE_IMAGE=${BASE_IMAGE} IMAGE_REPO=${IMAGE_REPO}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes-sigs/metrics-server")
	make -C projects/kubernetes/release $(TARGET)                    RELEASE_BRANCH=${RELEASE_BRANCH} RELEASE=${RELEASE} DEVELOPMENT=${DEVELOPMENT} AWS_REGION=${AWS_REGION} AWS_ACCOUNT_ID=${AWS_ACCOUNT_ID} KUBE_PROXY_BASE_IMAGE=${KUBE_PROXY_BASE_IMAGE} GO_RUNNER_IMAGE=${GO_RUNNER_IMAGE} BASE_IMAGE=${BASE_IMAGE}
	$(call presubmit-cleanup, $(TARGET), "projects/kubernetes/release")
