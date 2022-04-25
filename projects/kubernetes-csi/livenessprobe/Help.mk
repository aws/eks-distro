


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `livenessprobe`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file

##@ Binary Targets
binaries: ## Build all binaries: `livenessprobe` for `linux/amd64 linux/arm64`
_output/1-21/bin/livenessprobe/linux-amd64/livenessprobe: ## Build `_output/1-21/bin/livenessprobe/linux-amd64/livenessprobe`
_output/1-21/bin/livenessprobe/linux-arm64/livenessprobe: ## Build `_output/1-21/bin/livenessprobe/linux-arm64/livenessprobe`

##@ Image Targets
local-images: ## Builds `livenessprobe/images/amd64` as oci tars for presumbit validation
images: ## Pushes `livenessprobe/images/push` to IMAGE_REPO
livenessprobe/images/amd64: ## Builds/pushes `livenessprobe/images/amd64`
livenessprobe/images/push: ## Builds/pushes `livenessprobe/images/push`

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
