#!/usr/bin/env bash
# Copyright Amazon.com Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -o errexit
set -o nounset
set -o pipefail

PROJECT_ROOT="$1"
BINARY_TARGET_FILES="$2"
BINARY_PLATFORMS="$3"
BINARY_TARGETS="$4"
REPO="$5"
HAS_PATCHES="$6"
LOCAL_IMAGE_TARGETS="$7"
IMAGE_TARGETS="$8"
BUILD_TARGETS="$9"
RELEASE_TARGETS="${10}"
HAS_S3_ARTIFACTS="${11}"
HAS_LICENSES="${12}"
REPO_NO_CLONE="${13}"
FETCH_BINARIES_TARGETS="${14}"
HAS_HELM_CHART="${15}"
IN_DOCKER_TARGETS="${16}"

NL=$'\n'
HEADER="########### DO NOT EDIT #############################"
FOOTER="########### END GENERATED ###########################"

MAKEFILE=$PROJECT_ROOT/Makefile
HELPFILE=$PROJECT_ROOT/Help.mk

SED=sed
if [ "$(uname -s)" = "Darwin" ]; then
    SED=gsed
fi

$SED -i "/$HEADER/,/$FOOTER/d" $MAKEFILE
# remove trailing newlines
printf %s "$(< $MAKEFILE)" > $MAKEFILE

touch $HELPFILE

$SED -i "/$HEADER/,/$FOOTER/d" $HELPFILE
# remove trailing newlines
printf %s "$(< $HELPFILE)" > $HELPFILE

# Generate help items from Common.mk
EXTRA_HELP="$(make help-list --no-print-directory)"
BINARY_TARGETS_HELP=""
CHECKSUMS_TARGETS_HELP=""
if [ ! -z "$(echo "$BINARY_TARGETS" | xargs)" ]; then
    BINARY_TARGETS_HELP+="${NL}${NL}##@ Binary Targets"
    BINARY_TARGETS_HELP+="${NL}binaries: ## Build all binaries: \`${BINARY_TARGET_FILES}\` for \`${BINARY_PLATFORMS}\`"
    TARGETS=(${BINARY_TARGETS// / })
    for target in "${TARGETS[@]}"; do
        BINARY_TARGETS_HELP+="${NL}${target}: ## Build \`${target}\`"
    done

    CHECKSUMS_TARGETS_HELP+="${NL}${NL}##@ Checksum Targets"
    CHECKSUMS_TARGETS_HELP+="${NL}checksums: ## Update checksums file based on currently built binaries."
    CHECKSUMS_TARGETS_HELP+="${NL}validate-checksums: # Validate checksums of currently built binaries against checksums file."
    CHECKSUMS_TARGETS_HELP+="${NL}all-checksums: ## Update checksums files for all RELEASE_BRANCHes."
fi

GIT_TARGETS_HELP=""
if [[ "$REPO_NO_CLONE" != "true" ]]; then
    GIT_TARGETS_HELP+="${NL}${NL}##@ GIT/Repo Targets"
    GIT_TARGETS_HELP+="${NL}clone-repo:  ## Clone upstream \`${REPO}\`"
    GIT_TARGETS_HELP+="${NL}checkout-repo: ## Checkout upstream tag based on value in GIT_TAG file"
fi

PATCHES_TARGET=""
if [[ "$HAS_PATCHES" == "true" ]]; then
    PATCHES_TARGET+="${NL}patch-repo: ## Patch upstream repo with patches in patches directory"
fi

IMAGE_TARGETS_HELP=""
if [ ! -z "$(echo "$LOCAL_IMAGE_TARGETS" | xargs)" ]; then
    IMAGE_TARGETS_HELP+="${NL}${NL}##@ Image Targets"
    IMAGE_TARGETS_HELP+="${NL}local-images: ## Builds \`$(echo ${LOCAL_IMAGE_TARGETS} | xargs)\` as oci tars for presumbit validation"
    IMAGE_TARGETS_HELP+="${NL}images: ## Pushes \`$(echo ${IMAGE_TARGETS} | xargs)\` to IMAGE_REPO"
    
    ALL_IMAGES=()
    TARGETS=(${LOCAL_IMAGE_TARGETS// / })
    for target in "${TARGETS[@]}"; do
        ALL_IMAGES+=("$target")
    done
    TARGETS=(${IMAGE_TARGETS// / })
    for target in "${TARGETS[@]}"; do
        if [[ ! " ${ALL_IMAGES[*]} " =~ " ${target} " ]]; then
            ALL_IMAGES+=("$target")
        fi
    done
    for image in "${ALL_IMAGES[@]}"; do
        IMAGE_TARGETS_HELP+="${NL}$image: ## Builds/pushes \`${image}\`"
    done

fi

ARTIFACTS_TARGETS=""
if [[ "$HAS_S3_ARTIFACTS" == "true" ]]; then
    ARTIFACTS_TARGETS+="${NL}${NL}##@ Artifact Targets" 
    ARTIFACTS_TARGETS+="${NL}tarballs: ## Create tarballs by calling build/lib/simple_create_tarballs.sh unless SIMPLE_CREATE_TARBALLS=false, then tarballs must be defined in project Makefile"
    ARTIFACTS_TARGETS+="${NL}s3-artifacts: # Prepare ARTIFACTS_PATH folder structure with tarballs/manifests/other items to be uploaded to s3"
    ARTIFACTS_TARGETS+="${NL}upload-artifacts: # Upload tarballs and other artifacts from ARTIFACTS_PATH to S3"
fi

LICENSES_TARGETS=""
if [[ "$HAS_LICENSES" == "true" ]]; then
    LICENSES_TARGETS+="${NL}${NL}##@ License Targets" 
    LICENSES_TARGETS+="${NL}gather-licenses: ## Helper to call \$(GATHER_LICENSES_TARGETS) which gathers all licenses"
    LICENSES_TARGETS+="${NL}attribution: ## Generates attribution from licenses gathered during \`gather-licenses\`."
    LICENSES_TARGETS+="${NL}attribution-pr: ## Generates PR to update attribution files for projects"
    LICENSES_TARGETS+="${NL}attribution-checksums: ## Update attribution and checksums files."
    LICENSES_TARGETS+="${NL}all-attributions: ## Update attribution files for all RELEASE_BRANCHes."
    LICENSES_TARGETS+="${NL}all-attributions-checksums: ## Update attribution and checksums files for all RELEASE_BRANCHes."
fi

CLEAN_TARGETS="${NL}${NL}##@ Clean Targets"
CLEAN_TARGETS+="${NL}clean: ## Removes source and _output directory"
if [[ "$REPO_NO_CLONE" != "true" ]]; then
    CLEAN_TARGETS+="${NL}clean-repo: ## Removes source directory"
fi

FETCH_BINARY_TARGETS_HELP=""
if [ ! -z "$(echo "$FETCH_BINARIES_TARGETS" | xargs)" ]; then
    FETCH_BINARY_TARGETS_HELP+="${NL}${NL}##@ Fetch Binary Targets"
    TARGETS=(${FETCH_BINARIES_TARGETS// / })
    for target in "${TARGETS[@]}"; do
        FETCH_BINARY_TARGETS_HELP+="${NL}${target}: ## Fetch \`${target}\`"
    done
fi

HELM_TARGETS=""
if [[ "$HAS_HELM_CHART" == "true" ]]; then
    HELM_TARGETS+="${NL}${NL}##@ Helm Targets"
    HELM_TARGETS+="${NL}helm/build: ## Build helm chart"
    HELM_TARGETS+="${NL}helm/push: ## Build helm chart and push to registry defined in IMAGE_REPO."
fi

TARGETS=(${IN_DOCKER_TARGETS// / })
DOCKER_TARGETS="${NL}${NL}##@ Run in Docker Targets"
for target in "${TARGETS[@]}"; do
    DOCKER_TARGETS+="${NL}run-${target}-in-docker: ## Run \`${target}\` in docker builder container"
done

cat >> $HELPFILE << EOF
${NL}${NL}${NL}${HEADER}
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
${GIT_TARGETS_HELP}${PATCHES_TARGET}${BINARY_TARGETS_HELP}${IMAGE_TARGETS_HELP}${HELM_TARGETS}${FETCH_BINARY_TARGETS_HELP}${CHECKSUMS_TARGETS_HELP}${DOCKER_TARGETS}${ARTIFACTS_TARGETS}${LICENSES_TARGETS}${CLEAN_TARGETS}
${EXTRA_HELP}

##@ Build Targets
build: ## Called via prow presubmit, calls \`${BUILD_TARGETS//$PROJECT_ROOT\//""}\`
release: ## Called via prow postsubmit + release jobs, calls \`${RELEASE_TARGETS}\`
${FOOTER}
EOF

cat >> $MAKEFILE << EOF
${NL}${NL}${NL}${HEADER}
# To update call: make add-generated-help-block
# This is added to help document dynamic targets and support shell autocompletion
# Run make help for a formatted help block with all targets
include Help.mk
${FOOTER}
EOF

