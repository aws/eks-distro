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

SCRIPT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
source "${SCRIPT_ROOT}/common.sh"

rungovulncheck() {
    local -r goversion=$1
    local -r repo=$2

    build::common::use_go_version $goversion
    echo "Installing govulncheck...."
    go install golang.org/x/vuln/cmd/govulncheck@latest

    echo "Running govulncheck..."
    # Use direct GOPROXY and don't check GOSUMDB hashes for sigstore/cosign, as the 1.9 tag used in several projects was force-pushed and fails the athens proxy pull
    govluncheckoutput=$(GONOPROXY="github.com/sigstore/cosign" GONOSUMDB="github.com/sigstore/cosign" $(go env GOPATH)/bin/govulncheck -C $repo -json ./...)
    echo $govluncheckoutput

    echo "Analyzing CVEs..."
    detectedcves=$(echo $govluncheckoutput | jq '.osv | select( . != null ) | .aliases[0]')
    if [ "$detectedcves" == "" ];then
        echo "No CVEs detected "
        exit 0
    fi
    echo $detectedcves

    builderbasegoversion=$(getbuilderbasegoversion $goversion)
    cleanedbuilderbasegoversion="v${builderbasegoversion/-/-eks-}"
    cleanedbuilderbasegoversion="eks-distro-golang:${cleanedbuilderbasegoversion//./-}"
    echo "builder base golang version: $cleanedbuilderbasegoversion"

    fixedcves=$(getgolangvex | jq --arg v "$cleanedbuilderbasegoversion" '[.vulnerabilities[] | select( .product_status.fixed[] | contains($v)) | .cve'])
    if [ "$fixedcves" == "" ];then
        echo "No CVE fixes present"
    fi
    echo "CVEs addressed by EKS Go Patches: $fixedcves"

    declare -a unmitigatedcves
    declare -a mitigatedcves
    for cve in $detectedcves
    do
        echo "Checking if detected CVE $cve is addressed by golang patches..."
        cvefixed=$(echo $fixedcves | jq "index($cve) | select( . != null)")
        if [ "$cvefixed" == "" ]; 
        then
            echo "Unmitigated CVE Detected: $cve is not addressed by a known patch to $goversion"
            unmitigatedcves+=($cve)
        else
            echo "Mitigated CVE Detected: $cve is addressed by a known patch to $goversion" 
            mitigatedcves+=($cve)
        fi
    done

    if [ -n "${unmitigatedcves-}" ]; then
        echo "unmitigated_cves=${unmitigatedcves[@]}"
        echo $govluncheckoutput | jq --arg v $unmitigatedcves '.osv | select( . != null ) | select( .aliases[0] == $v)'
    fi


    if [ -n "${mitigatedcves-}" ]; then
        echo "mitigated_cves=${mitigatedcves[@]}"
    fi
}

getbuilderbasegoversion() {
    local -r goversion=$1
    local -r cleanedversion=${goversion//.}
    curl -s https://raw.githubusercontent.com/aws/eks-distro-build-tooling/main/builder-base/versions.yaml | yq ".GOLANG_VERSION_$cleanedversion"
}

getgolangvex() {
    curl -s https://raw.githubusercontent.com/aws/eks-distro-build-tooling/main/projects/golang/go/VulnerabilityManagement/eks-distro-golang-vex.json
}