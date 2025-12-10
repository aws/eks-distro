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
source ${BASEDIR}/set_environment.sh
$PREFLIGHT_CHECK_PASSED || exit 1

mkdir -p "./${KOPS_CLUSTER_NAME}"
if [ -f "./${KOPS_CLUSTER_NAME}/values.yaml" ]; then
    echo -e "Error the ./${KOPS_CLUSTER_NAME}/values.yaml file already exists."
    echo -e "Delete the cluster and cluster store before creating a new cluster"
    exit 1
fi

function get_container_yaml() {
    REPOSITORY_NAME="${1}"
    RELEASE="${2}"
    VERSION="$(get_project_version $REPOSITORY_NAME)"


    if  [[ $REPOSITORY_NAME == "kubernetes/cloud-provider-aws" ]] 
    then
        REPOSITORY_NAME="kubernetes/cloud-provider-aws/cloud-controller-manager"
    fi

    if  [[ $REPOSITORY_NAME == "kubernetes-sigs/metrics-server" ]]; then
       
        if [[ $RELEASE_BRANCH == "1-33" ]] || [[ $RELEASE_BRANCH == "1-34" ]]; then
            # For releases 1-33 and 1-34, force metrics-server to use the 1-32 image
            echo "    repository: ${IMAGE_REPO}/${REPOSITORY_NAME}
    tag: ${VERSION}-eks-1-32-latest"
        else
            echo "    repository: ${IMAGE_REPO}/${REPOSITORY_NAME}
    tag: ${VERSION}-eks-${RELEASE_BRANCH}-latest"
        fi
        return
    fi

    # CSI sidecar components have moved to public.ecr.aws/csi-components
    if  [[ $REPOSITORY_NAME == "kubernetes-csi/node-driver-registrar" ]] || \
        [[ $REPOSITORY_NAME == "kubernetes-csi/external-resizer" ]] || \
        [[ $REPOSITORY_NAME == "kubernetes-csi/external-attacher" ]] || \
        [[ $REPOSITORY_NAME == "kubernetes-csi/external-snapshotter" ]] || \
        [[ $REPOSITORY_NAME == "kubernetes-csi/external-provisioner" ]] || \
        [[ $REPOSITORY_NAME == "kubernetes-csi/livenessprobe" ]]; then \
    
        #https://gallery.ecr.aws/csi-components?page=1
        case $REPOSITORY_NAME in
            "kubernetes-csi/external-provisioner")
                COMPONENT_NAME="csi-provisioner"
                TAG="v5.3.0-eksbuild.3"
                ;;
            "kubernetes-csi/node-driver-registrar")
                COMPONENT_NAME="csi-node-driver-registrar"
                TAG="v2.14.0-eksbuild.4"
                ;;
            "kubernetes-csi/external-resizer")
                COMPONENT_NAME="csi-resizer"
                TAG="v1.14.0-eksbuild.3"
                ;;
            "kubernetes-csi/external-attacher")
                COMPONENT_NAME="csi-attacher"
                TAG="v4.9.0-eksbuild.3"
                ;;
            "kubernetes-csi/external-snapshotter")
                COMPONENT_NAME="csi-snapshotter"
                TAG="v8.3.0-eksbuild.1"
                ;;
            "kubernetes-csi/livenessprobe")
                COMPONENT_NAME="livenessprobe"
                TAG="v2.16.0-eksbuild.4"
                ;;
        esac
        
        echo "    repository: public.ecr.aws/csi-components/${COMPONENT_NAME}
    tag: ${TAG}"
        return
    fi
    
    echo "    repository: ${IMAGE_REPO}/${REPOSITORY_NAME}
    tag: ${VERSION}-eks-${RELEASE_BRANCH}-${RELEASE}"
}

function get_project_version(){
    REPOSITORY_NAME="${1}"
    if [[ $REPOSITORY_NAME == "kubernetes/kube-proxy" ]]; then
        REPOSITORY_NAME="kubernetes/kubernetes"
        PRIMARY_PATH="${BASEDIR}/../../projects/${REPOSITORY_NAME}/${RELEASE_BRANCH}/kube-proxy/GIT_TAG"
        FALLBACK_PATH="${BASEDIR}/../../projects/${REPOSITORY_NAME}/${RELEASE_BRANCH}/GIT_TAG"
        
        if [[ -f "$PRIMARY_PATH" ]]; then
            VERSION=$(cat "$PRIMARY_PATH")
        else
            VERSION=$(cat "$FALLBACK_PATH")
        fi
        
        echo "$VERSION"
        return 0
    fi

    if  [[ $REPOSITORY_NAME == kubernetes/* ]] && [[ $REPOSITORY_NAME != "kubernetes/cloud-provider-aws" ]] 
    then
        REPOSITORY_NAME="kubernetes/kubernetes"
    fi

    if  [[ $REPOSITORY_NAME == "kubernetes-sigs/metrics-server" ]]; then
        echo "v0.7.2"
        return
    fi

    # Skip version lookup for CSI components since we use hardcoded versions
    case $REPOSITORY_NAME in
        "kubernetes-csi/node-driver-registrar"|\
        "kubernetes-csi/external-resizer"|\
        "kubernetes-csi/external-attacher"|\
        "kubernetes-csi/external-snapshotter"|\
        "kubernetes-csi/external-provisioner"|\
        "kubernetes-csi/livenessprobe")
            echo "skip-csi" 
            return
            ;;
    esac
    
    TAG_FILE=${BASEDIR}/../../projects/${REPOSITORY_NAME}/GIT_TAG
    if [ -f "$TAG_FILE" ]; then
        VERSION=$(cat ${BASEDIR}/../../projects/${REPOSITORY_NAME}/GIT_TAG)
    else
        VERSION=$(cat ${BASEDIR}/../../projects/${REPOSITORY_NAME}/${RELEASE_BRANCH}/GIT_TAG)
    fi
    
    echo $VERSION
}

# Get latest ubuntu ami based on desired release and arch
UBUNTU_AMI=$(aws ec2 describe-images --owners 099720109477 --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-$UBUNTU_RELEASE-$NODE_ARCHITECTURE-server-*" --query 'sort_by(Images, &CreationDate)[-1].[Name]' --output text)

echo "Creating ./${KOPS_CLUSTER_NAME}/values.yaml"

# podInfraContainer should be used <= 1.34
KUBERNETES_MINOR_VERSION=$(echo $KUBERNETES_VERSION | cut -d. -f2)
if [ "$KUBERNETES_MINOR_VERSION" -le 34 ]; then
    USE_POD_INFRA_CONTAINER="true"
else
    USE_POD_INFRA_CONTAINER="false"
fi

cat << EOF > ./${KOPS_CLUSTER_NAME}/values.yaml
kubernetesVersion: ${ARTIFACT_URL}/kubernetes/${KUBERNETES_VERSION}
clusterName: $KOPS_CLUSTER_NAME
configBase: $KOPS_STATE_STORE/$KOPS_CLUSTER_NAME
awsRegion: $AWS_DEFAULT_REGION
controlPlaneInstanceProfileArn: $CONTROL_PLANE_INSTANCE_PROFILE
nodeInstanceProfileArn: $NODE_INSTANCE_PROFILE
instanceType: $NODE_INSTANCE_TYPE
architecture: $NODE_ARCHITECTURE
ubuntuAmi: $UBUNTU_AMI
ipv6: $IPV6
usePodInfraContainer: $USE_POD_INFRA_CONTAINER
pause:
$(get_container_yaml kubernetes/pause $RELEASE)
kube_apiserver:
$(get_container_yaml kubernetes/kube-apiserver $RELEASE)
kube_controller_manager:
$(get_container_yaml kubernetes/kube-controller-manager $RELEASE)
kube_scheduler:
$(get_container_yaml kubernetes/kube-scheduler $RELEASE)
kube_proxy:
$(get_container_yaml kubernetes/kube-proxy $RELEASE)
metrics_server:
$(get_container_yaml kubernetes-sigs/metrics-server $RELEASE)
awsiamauth:
$(get_container_yaml kubernetes-sigs/aws-iam-authenticator $RELEASE)
coredns:
$(get_container_yaml coredns/coredns $RELEASE)
node_driver_registrar:
$(get_container_yaml kubernetes-csi/node-driver-registrar $RELEASE)
csi_resizer:
$(get_container_yaml kubernetes-csi/external-resizer $RELEASE)
csi_attacher:
$(get_container_yaml kubernetes-csi/external-attacher $RELEASE)
csi_snapshotter:
$(get_container_yaml kubernetes-csi/external-snapshotter $RELEASE)
csi_provisioner:
$(get_container_yaml kubernetes-csi/external-provisioner $RELEASE)
csi_livenessprobe:
$(get_container_yaml kubernetes-csi/livenessprobe $RELEASE)
etcd:
$(get_container_yaml etcd-io/etcd $RELEASE)
cloud_controller_manager:
$(get_container_yaml kubernetes/cloud-provider-aws $RELEASE)
EOF
