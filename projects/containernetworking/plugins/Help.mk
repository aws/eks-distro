


########### DO NOT EDIT #############################
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion


##@ GIT/Repo Targets
clone-repo:  ## Clone upstream `plugins`
checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file
patch-repo: ## Patch upstream repo with patches in patches directory

##@ Binary Targets
binaries: ## Build all binaries: `bandwidth firewall flannel portmap sbr tuning bridge host-device ipvlan loopback macvlan ptp vlan dhcp host-local static ` for `linux/amd64 linux/arm64`
_output/bin/plugins/linux-amd64/bandwidth: ## Build `_output/bin/plugins/linux-amd64/bandwidth`
_output/bin/plugins/linux-amd64/firewall: ## Build `_output/bin/plugins/linux-amd64/firewall`
_output/bin/plugins/linux-amd64/flannel: ## Build `_output/bin/plugins/linux-amd64/flannel`
_output/bin/plugins/linux-amd64/portmap: ## Build `_output/bin/plugins/linux-amd64/portmap`
_output/bin/plugins/linux-amd64/sbr: ## Build `_output/bin/plugins/linux-amd64/sbr`
_output/bin/plugins/linux-amd64/tuning: ## Build `_output/bin/plugins/linux-amd64/tuning`
_output/bin/plugins/linux-amd64/bridge: ## Build `_output/bin/plugins/linux-amd64/bridge`
_output/bin/plugins/linux-amd64/host-device: ## Build `_output/bin/plugins/linux-amd64/host-device`
_output/bin/plugins/linux-amd64/ipvlan: ## Build `_output/bin/plugins/linux-amd64/ipvlan`
_output/bin/plugins/linux-amd64/loopback: ## Build `_output/bin/plugins/linux-amd64/loopback`
_output/bin/plugins/linux-amd64/macvlan: ## Build `_output/bin/plugins/linux-amd64/macvlan`
_output/bin/plugins/linux-amd64/ptp: ## Build `_output/bin/plugins/linux-amd64/ptp`
_output/bin/plugins/linux-amd64/vlan: ## Build `_output/bin/plugins/linux-amd64/vlan`
_output/bin/plugins/linux-amd64/dhcp: ## Build `_output/bin/plugins/linux-amd64/dhcp`
_output/bin/plugins/linux-amd64/host-local: ## Build `_output/bin/plugins/linux-amd64/host-local`
_output/bin/plugins/linux-amd64/static: ## Build `_output/bin/plugins/linux-amd64/static`
_output/bin/plugins/linux-arm64/bandwidth: ## Build `_output/bin/plugins/linux-arm64/bandwidth`
_output/bin/plugins/linux-arm64/firewall: ## Build `_output/bin/plugins/linux-arm64/firewall`
_output/bin/plugins/linux-arm64/flannel: ## Build `_output/bin/plugins/linux-arm64/flannel`
_output/bin/plugins/linux-arm64/portmap: ## Build `_output/bin/plugins/linux-arm64/portmap`
_output/bin/plugins/linux-arm64/sbr: ## Build `_output/bin/plugins/linux-arm64/sbr`
_output/bin/plugins/linux-arm64/tuning: ## Build `_output/bin/plugins/linux-arm64/tuning`
_output/bin/plugins/linux-arm64/bridge: ## Build `_output/bin/plugins/linux-arm64/bridge`
_output/bin/plugins/linux-arm64/host-device: ## Build `_output/bin/plugins/linux-arm64/host-device`
_output/bin/plugins/linux-arm64/ipvlan: ## Build `_output/bin/plugins/linux-arm64/ipvlan`
_output/bin/plugins/linux-arm64/loopback: ## Build `_output/bin/plugins/linux-arm64/loopback`
_output/bin/plugins/linux-arm64/macvlan: ## Build `_output/bin/plugins/linux-arm64/macvlan`
_output/bin/plugins/linux-arm64/ptp: ## Build `_output/bin/plugins/linux-arm64/ptp`
_output/bin/plugins/linux-arm64/vlan: ## Build `_output/bin/plugins/linux-arm64/vlan`
_output/bin/plugins/linux-arm64/dhcp: ## Build `_output/bin/plugins/linux-arm64/dhcp`
_output/bin/plugins/linux-arm64/host-local: ## Build `_output/bin/plugins/linux-arm64/host-local`
_output/bin/plugins/linux-arm64/static: ## Build `_output/bin/plugins/linux-arm64/static`

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
build: ## Called via prow presubmit, calls `validate-checksums attribution  upload-artifacts attribution-pr`
release: ## Called via prow postsubmit + release jobs, calls `validate-checksums  upload-artifacts`
########### END GENERATED ###########################
