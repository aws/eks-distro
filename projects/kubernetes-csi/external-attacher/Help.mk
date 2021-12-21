


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `external-attacher`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file

##@ Binary Targets
binaries: ## Build all binaries: `csi-attacher` for `linux/amd64 linux/arm64`
_output/bin/external-attacher/linux-amd64/csi-attacher: ## Build `_output/bin/external-attacher/linux-amd64/csi-attacher`
_output/bin/external-attacher/linux-arm64/csi-attacher: ## Build `_output/bin/external-attacher/linux-arm64/csi-attacher`

##@ Image Targets
local-images: ## Builds `external-attacher/images/amd64` as oci tars for presumbit validation
images: ## Pushes `external-attacher/images/push` to IMAGE_REPO
external-attacher/images/amd64: ## Builds/pushes `external-attacher/images/amd64`
external-attacher/images/push: ## Builds/pushes `external-attacher/images/push`

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

##@ Build Targets
build: ## Called via prow presubmit, calls `validate-checksums local-images attribution  attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images `
########### END GENERATED ###########################
