


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `etcd`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file
patch-repo: ## Patch upstream repo with patches in patches directory

##@ Binary Targets
binaries: ## Build all binaries: `etcd etcdctl` for `linux/amd64 linux/arm64`
_output/1-21/bin/etcd/linux-amd64/etcd: ## Build `_output/1-21/bin/etcd/linux-amd64/etcd`
_output/1-21/bin/etcd/linux-amd64/etcdctl: ## Build `_output/1-21/bin/etcd/linux-amd64/etcdctl`
_output/1-21/bin/etcd/linux-arm64/etcd: ## Build `_output/1-21/bin/etcd/linux-arm64/etcd`
_output/1-21/bin/etcd/linux-arm64/etcdctl: ## Build `_output/1-21/bin/etcd/linux-arm64/etcdctl`

##@ Image Targets
local-images: ## Builds `etcd/images/amd64` as oci tars for presumbit validation
images: ## Pushes `etcd/images/push etcd/images/amd64 etcd/images/arm64` to IMAGE_REPO
etcd/images/amd64: ## Builds/pushes `etcd/images/amd64`
etcd/images/push: ## Builds/pushes `etcd/images/push`
etcd/images/arm64: ## Builds/pushes `etcd/images/arm64`

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

##@Update Helpers
run-target-in-docker: ## Run `MAKE_TARGET` using builder base docker container
update-attribution-checksums-docker: ## Update attribution and checksums using the builder base docker container
stop-docker-builder: ## Clean up builder base docker container
generate: ## Update UPSTREAM_PROJECTS.yaml

##@ Build Targets
build: ## Called via prow presubmit, calls `validate-checksums attribution local-images upload-artifacts attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images upload-artifacts`
########### END GENERATED ###########################
