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

set -eo pipefail
BASEDIR=$(dirname "$0")
cd ${BASEDIR}

function install_ecr_public {
    if [ ! -f ~/.aws/models/ecr-public/2020-10-30/service-2.json ]
    then
        echo "Installing ECR Public plugin"
        aws configure add-model \
          --service-model file://ecr-public-2020-10-30.api.json \
          --service-name ecr-public
    fi
}

function create_ecr_public_policy {
    POLICY_NAME=ECRPublicAccess
    if aws iam list-policies \
         --query "Policies[?PolicyName=='${POLICY_NAME}'].[PolicyName]" \
         --output text | grep "${POLICY_NAME}" >/dev/null
    then
        return
    fi
    echo "Creating ECR Public policy"
    aws iam create-policy \
      --policy-name ${POLICY_NAME} \
      --policy-document \
      file://ecr-public-policy.json
}

function login_ecr_public {
    # Token expires after 12 hours
    TOKEN=$(aws --region us-east-1 ecr-public get-authorization-token \
        --output=text \
        --query 'authorizationData.authorizationToken')

    DOCKER_CONFIG=${DOCKER_CONFIG:-"~/.docker"}
    if command -v docker &> /dev/null && docker info > /dev/null 2>&1; then
        echo $TOKEN | \
            base64 --decode | \
            cut -d: -f2 | \
            docker login -u AWS --password-stdin https://public.ecr.aws
    else
        mkdir -p $DOCKER_CONFIG
        if [ ! -f $DOCKER_CONFIG/config.json ]; then
            echo '{}' > $DOCKER_CONFIG/config.json
        fi
        # Gross, abominable hack until ecr-credential-helper supports public ECR
        # See https://github.com/awslabs/amazon-ecr-credential-helper/issues/248
        cat $DOCKER_CONFIG/config.json | \
            jq --arg TOKEN $TOKEN '.auths."public.ecr.aws".auth = $TOKEN' > $DOCKER_CONFIG/config.json.new
        cp $DOCKER_CONFIG/config.json.new $DOCKER_CONFIG/config.json
    fi
}

function create_private_repository {
    local -r repository_name="${1?First argument is repository name}"
    aws ecr describe-repositories \
      --query "repositories[*].repositoryName" \
      --output text \
      --repository-name $repository_name 2>/dev/null ||
    aws ecr create-repository \
      --repository-name $repository_name \
      --image-scanning-configuration scanOnPush=true
}

function create_public_repository {
    local -r repository_name="${1?First argument should be repository name}"
    local -r file_prefix="$(echo $repository_name | awk -F/ '{print $(NF)}')"
    local -r input="create-public-repo-input.json"
    # Yes, they put a _space_ in "ARM 64"
    cat << EOF > $input
{
    "repositoryName": "$repository_name",
    "catalogData": {
        "description": "Development $(cat image-docs/${file_prefix}-description)",
        "architectures": [
            "x86-64",
            "ARM 64"
        ],
        "operatingSystems": [
            "linux"
        ],
	"aboutText": "Development $(awk '{printf "%s\\n", $0}' image-docs/${file_prefix}-about.md)",
	"usageText": "$(awk '{printf "%s\\n", $0}' image-docs/${file_prefix}-usage.md)"
    }
}
EOF
    aws ecr-public describe-repositories \
      --query "repositories[*].repositoryName" \
      --output text \
      --repository-name $repository_name 2>/dev/null ||
    aws ecr-public create-repository \
      --repository-name $repository_name \
      --cli-input-json file://$input
    rm -f $input
}

function create_all_private_repositories {
    create_private_repository "coredns/coredns"
    create_private_repository "etcd-io/etcd"
    create_private_repository "kubernetes-sigs/aws-iam-authenticator"
    create_private_repository "kubernetes/go-runner"
    create_private_repository "kubernetes/kube-apiserver"
    create_private_repository "kubernetes/kube-controller-manager"
    create_private_repository "kubernetes/kube-proxy"
    create_private_repository "kubernetes/kube-proxy-base"
    create_private_repository "kubernetes/kube-scheduler"
    create_private_repository "kubernetes/pause"
}

function create_all_public_repositories {
    create_public_repository "coredns/coredns"
    create_public_repository "etcd-io/etcd"
    create_public_repository "kubernetes-sigs/aws-iam-authenticator"
    create_public_repository "kubernetes/go-runner"
    create_public_repository "kubernetes/kube-apiserver"
    create_public_repository "kubernetes/kube-controller-manager"
    create_public_repository "kubernetes/kube-proxy"
    create_public_repository "kubernetes/kube-proxy-base"
    create_public_repository "kubernetes/kube-scheduler"
    create_public_repository "kubernetes/pause"
}

function update_public_repository {
    local -r repository_name="${1?First argument is repository_name}"
    local -r file_prefix="$(echo $repository_name | awk -F/ '{print $(NF)}')"
    # requires CLI v2
    aws ecr-public put-repository-catalog-data \
        --repository-name $repository_name \
        --catalog-data operatingSystems=Linux,logoImageBlob=$(cat eks-distro-img-large.png |base64)
    local -r input="update-public-repo-input.json"
    cat << EOF > base-$input
{
    "repositoryName": "$repository_name",
    "catalogData": {
        "architectures": [
            "x86-64",
            "ARM 64"
        ],
        "operatingSystems": [
            "Linux"
        ]
    }
}
EOF
    jq --arg about "$(<image-docs/${file_prefix}-about.md)" '.catalogData.aboutText=$about' base-${input} > about-$input
    jq --arg usage "$(<image-docs/${file_prefix}-usage.md)" '.catalogData.usageText=$usage' about-${input} > $input
    aws ecr-public put-repository-catalog-data \
      --cli-input-json file://$input
    rm base-$input about-${input} ${input}
}

function delete_public_repository {
    local -r repository_name="${1?First argument is repository name}"
    if ! aws ecr-public describe-repositories \
           --query "repositories[*].repositoryName" \
           --repository-name $repository_name 2>/dev/null
    then
        return
    fi
    REGISTRY_ID=$(aws ecr-public describe-registries --query registries[0].registryId --output text)
    for digest in $(aws ecr-public describe-images --registry-id  $REGISTRY_ID --repository-name $repository_name --query imageDetails[*].imageDigest --output text); do
        aws ecr-public batch-delete-image --registry-id  $REGISTRY_ID --repository-name $repository_name --image-ids imageDigest=$digest
    done
    aws ecr-public delete-repository --registry-id  $REGISTRY_ID --repository-name $repository_name
}

function retag_private_image {
    local -r repository_name="${1?First argument is repository name}"
    local -r image_tag="${2?Second argument is image tag}"
    local -r new_tag="${3?Third argument is new tag}"
    MANIFEST=$(aws ecr batch-get-image --repository-name ${repository_name} --image-ids imageTag=${image_tag} --query 'images[].imageManifest' --output text)
    aws ecr put-image --repository-name ${repository_name} --image-tag ${new_tag} --image-manifest "$MANIFEST"
}

COMMAND="${1}"
shift
case "${COMMAND}" in
install-ecr-public)
  install_ecr_public
  ;;
create-ecr-public-policy)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  create_ecr_public_policy
  ;;
login-ecr-public)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  login_ecr_public
  ;;
create-public-repository)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  create_public_repository ${1}
  ;;
create-all-private-repositories)
  create_all_private_repositories
  ;;
create-all-public-repositories)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  create_all_public_repositories
  ;;
create-private-repository)
  create_private_repository ${*}
  ;;
update-public-metadata)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  update_public_repository ${*}
  ;;
delete-public-repository)
  export AWS_DEFAULT_REGION=us-east-1
  export AWS_REGION=us-east-1
  delete_public_repository ${*}
  ;;
retag-private-image)
  retag_private_image ${*}
  ;;
*)
  echo "Please specify a supported command"
  exit 1
  ;;
esac
