#!/usr/bin/env bash
# Copyright 2020 Amazon.com Inc. or its affiliates. All Rights Reserved.
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

set -eo pipefail

BASEDIR=$(dirname "$0")
source ${BASEDIR}/set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1

UPSTREAM_PATH=$BASE_DIRECTORY/../k8s.io/test-infra/logexporter/cluster/log-dump.sh
if [ ! -f "$UPSTREAM_PATH" ]; then
    echo "k8s.io/test-infra is missing, skipping log gathering"
    exit
fi

BASE_DIRECTORY=$(git rev-parse --show-toplevel)

export LOG_DUMP_SAVE_SERVICES="kops-configuration"
export KUBERNETES_PROVIDER="none" # the script from upstream doesnt seem to handle aws exactly right
export LOG_DUMP_SSH_KEY="~/.ssh/id_rsa"
export LOG_DUMP_SSH_USER="ubuntu"
export LOG_DUMP_EXTRA_FILES="cloud-init-output.log cloud-init.log containers/*"
export LOG_DUMP_SYSTEMD_JOURNAL=true
ARTIFACTS=${ARTIFACTS:-"./_artifacts"}

function log_dump_custom_get_instances() {
    local -r type=$1
    local filter=''
    if [ $type == "master" ]; then
        filter="Name=tag:k8s.io/role/master,Values=1"
    else
        filter="Name=tag:k8s.io/role/node,Values=1"
    fi
    nodes=$(aws ec2 describe-instances \
        --filters "Name=tag:KubernetesCluster,Values=${KOPS_CLUSTER_NAME}" "$filter" \
        --query "Reservations[*].Instances[*].PublicDnsName" --output text)

    # contaner logs are symlinks and need a slightly differnet chmod
    # log-dump-ssh comes the upstream log-dump.sh script
    for node in $nodes ; do log-dump-ssh $node "sudo chmod a+r /var/log/containers/*" || true ; done

    echo "$nodes"
}
export -f log_dump_custom_get_instances

# fix protocol error: filename does not match request
# this seems to happen for the symlink'd files
function scp() {
    command scp -T "$@"
}
export -f scp

source $UPSTREAM_PATH $ARTIFACTS
