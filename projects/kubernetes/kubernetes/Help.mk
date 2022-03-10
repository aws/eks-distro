


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `kubernetes`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file
patch-repo: ## Patch upstream repo with patches in patches directory

##@ Binary Targets
binaries: ## Build all binaries: `kubelet` for `linux/amd64 linux/arm64`
_output/1-21/bin/linux/amd64/kubelet: ## Build `_output/1-21/bin/linux/amd64/kubelet`

##@ Image Targets
local-images: ## Builds `pause/images/amd64 kube-proxy/images/amd64 kube-apiserver/images/amd64 kube-controller-manager/images/amd64 kube-scheduler/images/amd64` as oci tars for presumbit validation
images: ## Pushes `pause/images/push pause/images/amd64 pause/images/arm64 kube-proxy/images/push kube-proxy/images/amd64 kube-proxy/images/arm64 kube-apiserver/images/push kube-apiserver/images/amd64 kube-apiserver/images/arm64 kube-controller-manager/images/push kube-controller-manager/images/amd64 kube-controller-manager/images/arm64 kube-scheduler/images/push kube-scheduler/images/amd64 kube-scheduler/images/arm64` to IMAGE_REPO
pause/images/amd64: ## Builds/pushes `pause/images/amd64`
kube-proxy/images/amd64: ## Builds/pushes `kube-proxy/images/amd64`
kube-apiserver/images/amd64: ## Builds/pushes `kube-apiserver/images/amd64`
kube-controller-manager/images/amd64: ## Builds/pushes `kube-controller-manager/images/amd64`
kube-scheduler/images/amd64: ## Builds/pushes `kube-scheduler/images/amd64`
pause/images/push: ## Builds/pushes `pause/images/push`
pause/images/arm64: ## Builds/pushes `pause/images/arm64`
kube-proxy/images/push: ## Builds/pushes `kube-proxy/images/push`
kube-proxy/images/arm64: ## Builds/pushes `kube-proxy/images/arm64`
kube-apiserver/images/push: ## Builds/pushes `kube-apiserver/images/push`
kube-apiserver/images/arm64: ## Builds/pushes `kube-apiserver/images/arm64`
kube-controller-manager/images/push: ## Builds/pushes `kube-controller-manager/images/push`
kube-controller-manager/images/arm64: ## Builds/pushes `kube-controller-manager/images/arm64`
kube-scheduler/images/push: ## Builds/pushes `kube-scheduler/images/push`
kube-scheduler/images/arm64: ## Builds/pushes `kube-scheduler/images/arm64`

##@ Checksum Targets
checksums: ## Update checksums file based on currently built binaries.
validate-checksums: # Validate checksums of currently built binaries against checksums file.

##@ Artifact Targets
tarballs: ## Create tarballs by calling build/lib/simple_create_tarballs.sh unless SIMPLE_CREATE_TARBALLS=false, then tarballs must be defined in project Makefile
s3-artifacts: # Prepare ARTIFACTS_PATH folder structure with tarballs/manifests/other items to be uploaded to s3
upload-artifacts: # Upload tarballs and other artifacts from ARTIFACTS_PATH to S3

##@ License Targets
gather-licenses: ## Helper to call $(GATHER_LICENSES_TARGETS) which gathers all licenses
attribution: ## Generates attribution from licenses gathered during `gather-licenses`.
attribution-pr: ## Generates PR to update attribution files for projects

##@ Clean Targets
clean: ## Removes source and _output directory
clean-repo: ## Removes source directory

##@ Helpers
help: ## Display this help
add-generated-help-block: ## Add or update generated help block to document project make file and support shell auto completion

##@ Build Targets
build: ## Called via prow presubmit, calls `validate-checksums local-images attribution upload-artifacts attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images upload-artifacts`
########### END GENERATED ###########################
