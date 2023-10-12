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

set -exo pipefail
BASEDIR=$(dirname "$0")
cd ${BASEDIR}

function cleanup() {
	echo 'Deleting...'
	./gather_logs.sh || true
	./delete_cluster.sh
	./delete_store.sh
}

function cleanup_and_error() {
	cleanup
	exit 255
}

echo "This script will create a cluster, run tests and tear it down"
source ./set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1
./install_requirements.sh

# If presubmit job, ignore state store and stop before creating cluster
if [ "${JOB_TYPE:-}" == "presubmit" ]; then
	#trap cleanup_and_error SIGINT SIGTERM ERR
	./create_values_yaml.sh
	./create_configuration.sh
	exit 0
fi

if [[ "${KOPS_STATE_STORE}" != "" ]]; then
	for cluster_name in $(aws s3 ls ${KOPS_STATE_STORE}); do
		if [[ "${cluster_name}" == "${RELEASE_BRANCH}-${NODE_ARCHITECTURE}-"* ]]; then
			# Only delete if older than a day, get timestamp from config file in s3
			cluster_fqdn="$(echo ${cluster_name} | tr -d "/")"
			config=$(aws s3 ls ${KOPS_STATE_STORE}/${cluster_fqdn}/config)
			createDate=$(echo $config | awk {'print $1" "$2'})
			createDate=$(date -d"$createDate" +%s)
			olderThan=$(date --date "1 day ago" +%s)
			if [[ $createDate -lt $olderThan ]]; then
				echo "Deleting cluster ${cluster_fqdn}"
				${KOPS} delete cluster --state "${KOPS_STATE_STORE}" --name ${cluster_fqdn} --yes
				aws s3 rm --recursive "${KOPS_STATE_STORE}/${cluster_name}"
			fi
		fi
	done
fi
trap cleanup_and_error SIGINT SIGTERM ERR
./create_values_yaml.sh
./create_configuration.sh
./create_cluster.sh
./set_nodeport_access.sh
./cluster_wait.sh
./validate_dns.sh
./run_tests.sh
./validate_eks.sh
./run_sonobuoy.sh

# avoid trying to clean up twice
trap '' SIGINT SIGTERM ERR

cleanup
