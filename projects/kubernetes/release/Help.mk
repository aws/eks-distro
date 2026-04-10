


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `release-src`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file

##@ Binary Targets
binaries: ## Build all binaries: `go-runner` for `linux/amd64 linux/arm64`
_output/1-35/bin/release-src/linux-amd64/go-runner: ## Build `_output/1-35/bin/release-src/linux-amd64/go-runner`
_output/1-35/bin/release-src/linux-arm64/go-runner: ## Build `_output/1-35/bin/release-src/linux-arm64/go-runner`

##@ Image Targets
local-images: ## Builds `go-runner/images/amd64 kube-proxy-base/images/amd64` as oci tars for presumbit validation
images: ## Pushes `go-runner/images/push kube-proxy-base/images/push` to IMAGE_REPO
go-runner/images/amd64: ## Builds/pushes `go-runner/images/amd64`
kube-proxy-base/images/amd64: ## Builds/pushes `kube-proxy-base/images/amd64`
go-runner/images/push: ## Builds/pushes `go-runner/images/push`
kube-proxy-base/images/push: ## Builds/pushes `kube-proxy-base/images/push`

##@ Checksum Targets
checksums: ## Update checksums file based on currently built binaries.
validate-checksums: # Validate checksums of currently built binaries against checksums file.
all-checksums: ## Update checksums files for all RELEASE_BRANCHes.

##@ Run in Docker Targets
run-all-attributions-in-docker: ## Run `all-attributions` in docker builder container
run-all-attributions-checksums-in-docker: ## Run `all-attributions-checksums` in docker builder container
run-all-checksums-in-docker: ## Run `all-checksums` in docker builder container
run-attribution-in-docker: ## Run `attribution` in docker builder container
run-attribution-checksums-in-docker: ## Run `attribution-checksums` in docker builder container
run-binaries-in-docker: ## Run `binaries` in docker builder container
run-checksums-in-docker: ## Run `checksums` in docker builder container
run-clean-in-docker: ## Run `clean` in docker builder container
run-clean-go-cache-in-docker: ## Run `clean-go-cache` in docker builder container

##@ License Targets
gather-licenses: ## Helper to call $(GATHER_LICENSES_TARGETS) which gathers all licenses
attribution: ## Generates attribution from licenses gathered during `gather-licenses`.
attribution-pr: ## Generates PR to update attribution files for projects
attribution-checksums: ## Update attribution and checksums files.
all-attributions: ## Update attribution files for all RELEASE_BRANCHes.
all-attributions-checksums: ## Update attribution and checksums files for all RELEASE_BRANCHes.

##@ Clean Targets
clean: ## Removes source and _output directory
clean-repo: ## Removes source directory

##@ Helpers
help: ## Display this help
add-generated-help-block: ## Add or update generated help block to document project make file and support shell auto completion

##@Update Helpers
run-target-in-docker: ## Run `MAKE_TARGET` using builder base docker container
stop-docker-builder: ## Clean up builder base docker container
generate: ## Update UPSTREAM_PROJECTS.yaml
update-go-mods: ## Update locally checked-in go sum to assist in vuln scanning
update-vendor-for-dep-patch: ## After bumping dep in go.mod file, uses generic vendor update script or one provided from upstream project
patch-for-dep-update: ## After bumping dep in go.mod file and updating vendor, generates patch
create-ecr-repos: ## Create repos in ECR for project images for local testing

##@ Build Targets
build: ## Called via prow presubmit, calls `validate-checksums attribution local-images   attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums images  `
########### END GENERATED ###########################
