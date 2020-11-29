export RELEASE_BRANCH?=1-18
export RELEASE?=1
export DEVELOPMENT?=false
export AWS_ACCOUNT_ID?=$(shell aws sts get-caller-identity --query Account --output text)
export AWS_REGION?=us-west-2
export BASE_IMAGE?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com/eks-distro/base:f4d4b49260f98e6cd8a713c182b1abb040a6c813
export IMAGE_REPO?=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com
KUBE_BASE_TAG?=v0.4.2-ea45689a0da457711b15fa1245338cd0b636ad4b
export KUBE_PROXY_BASE_IMAGE?=$(IMAGE_REPO)/kubernetes/kube-proxy-base:$(KUBE_BASE_TAG)
export GO_RUNNER_IMAGE?=$(IMAGE_REPO)/kubernetes/go-runner:$(KUBE_BASE_TAG)
ARTIFACT_BUCKET?=my-s3-bucket
RELEASE_AWS_PROFILE?=default

ifdef MAKECMDGOALS
TARGET=$(MAKECMDGOALS)
else
TARGET=$(DEFAULT_GOAL)
endif

.PHONY: setup
setup:
	bash ./ecr-public/setup.sh
	AWS_DEFAULT_PROFILE=$(RELEASE_AWS_PROFILE) bash ./ecr-public/get-credentials.sh

.PHONY: build
build: makes
	@echo 'Done' $(TARGET)

.PHONY: release
release: setup makes
	AWS_DEFAULT_PROFILE=$(RELEASE_AWS_PROFILE) bash build/lib/create_final_dir.sh $(RELEASE_BRANCH) $(RELEASE) $(ARTIFACT_BUCKET)
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
clean:
	@echo 'Done' $(TARGET)

makes:
	make -C projects/containernetworking/plugins $(TARGET)
	make -C projects/coredns/coredns $(TARGET)
	make -C projects/etcd-io/etcd $(TARGET)
	make -C projects/kubernetes-csi/external-attacher $(TARGET)
	make -C projects/kubernetes-csi/external-provisioner $(TARGET)
	make -C projects/kubernetes-csi/external-resizer $(TARGET)
	make -C projects/kubernetes-csi/external-snapshotter $(TARGET)
	make -C projects/kubernetes-csi/livenessprobe $(TARGET)
	make -C projects/kubernetes-csi/node-driver-registrar $(TARGET)
	make -C projects/kubernetes-sigs/aws-iam-authenticator $(TARGET)
	make -C projects/kubernetes-sigs/metrics-server $(TARGET)
	make -C projects/kubernetes/release $(TARGET)
	make -C projects/kubernetes/kubernetes $(TARGET)
