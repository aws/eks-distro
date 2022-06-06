


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `external-provisioner`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file

##@ Binary Targets
binaries: ## Build all binaries: `csi-provisioner` for `linux/amd64 linux/arm64`
_output/1-21/bin/external-provisioner/linux-amd64/csi-provisioner: ## Build `_output/1-21/bin/external-provisioner/linux-amd64/csi-provisioner`
_output/1-21/bin/external-provisioner/linux-arm64/csi-provisioner: ## Build `_output/1-21/bin/external-provisioner/linux-arm64/csi-provisioner`

##@ Image Targets
local-images: ## Builds `external-provisioner/images/amd64` as oci tars for presumbit validation
images: ## Pushes `external-provisioner/images/push` to IMAGE_REPO
external-provisioner/images/amd64: ## Builds/pushes `external-provisioner/images/amd64`
external-provisioner/images/push: ## Builds/pushes `external-provisioner/images/push`

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
update-go-mods: ## Update locally checked-in go sum to assist in vuln scanning
update-vendor-for-dep-patch: ## After bumping dep in go.mod file, uses generic vendor update script or one provided from upstream project
patch-for-dep-update: ## After bumping dep in go.mod file and updating vendor, generates patch

##@ Build Targets
build: ## Called via prow presubmit, calls `validate-checksums attribution local-images  attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images `
########### END GENERATED ###########################
