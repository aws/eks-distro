


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `external-snapshotter`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file
patch-repo: ## Patch upstream repo with patches in patches directory

##@ Binary Targets
binaries: ## Build all binaries: `snapshot-controller csi-snapshotter snapshot-validation-webhook` for `linux/amd64 linux/arm64`
_output/1-21/bin/external-snapshotter/linux-amd64/snapshot-controller: ## Build `_output/1-21/bin/external-snapshotter/linux-amd64/snapshot-controller`
_output/1-21/bin/external-snapshotter/linux-amd64/csi-snapshotter: ## Build `_output/1-21/bin/external-snapshotter/linux-amd64/csi-snapshotter`
_output/1-21/bin/external-snapshotter/linux-amd64/snapshot-validation-webhook: ## Build `_output/1-21/bin/external-snapshotter/linux-amd64/snapshot-validation-webhook`
_output/1-21/bin/external-snapshotter/linux-arm64/snapshot-controller: ## Build `_output/1-21/bin/external-snapshotter/linux-arm64/snapshot-controller`
_output/1-21/bin/external-snapshotter/linux-arm64/csi-snapshotter: ## Build `_output/1-21/bin/external-snapshotter/linux-arm64/csi-snapshotter`
_output/1-21/bin/external-snapshotter/linux-arm64/snapshot-validation-webhook: ## Build `_output/1-21/bin/external-snapshotter/linux-arm64/snapshot-validation-webhook`

##@ Image Targets
local-images: ## Builds `csi-snapshotter/images/amd64 snapshot-controller/images/amd64 snapshot-validation-webhook/images/amd64` as oci tars for presumbit validation
images: ## Pushes `csi-snapshotter/images/push snapshot-controller/images/push snapshot-validation-webhook/images/push` to IMAGE_REPO
csi-snapshotter/images/amd64: ## Builds/pushes `csi-snapshotter/images/amd64`
snapshot-controller/images/amd64: ## Builds/pushes `snapshot-controller/images/amd64`
snapshot-validation-webhook/images/amd64: ## Builds/pushes `snapshot-validation-webhook/images/amd64`
csi-snapshotter/images/push: ## Builds/pushes `csi-snapshotter/images/push`
snapshot-controller/images/push: ## Builds/pushes `snapshot-controller/images/push`
snapshot-validation-webhook/images/push: ## Builds/pushes `snapshot-validation-webhook/images/push`

##@ Checksum Targets
checksums: ## Update checksums file based on currently built binaries.
validate-checksums: # Validate checksums of currently built binaries against checksums file.

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
build: ## Called via prow presubmit, calls `validate-checksums attribution local-images  attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images `
########### END GENERATED ###########################
