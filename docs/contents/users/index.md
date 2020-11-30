Choose from two methods described here for starting up an EKS-D cluster: kOps and kubeadm

# Starting EKS-D with kOps

Before you start your cluster, you need to get several container images.
Container images can be accessed either from the EKS Distro Container
repository, downloaded in as a tarball, or built from scratch.

### EKS Distro Container Repository

You may pull the images you need from the EKS Distro Container Repository.
For example:

    docker pull 137112412989.dkr.ecr.us-west-2.amazonaws.com/eks-distro/base

### Download Containers Tarball

You may download container images as a tarball from our [EKS Distro
download site](http://boguslink.example.com/download). Once you have
downloaded the containers, push them to your private container repository.

### Building Your Own Container Images
See the [Build Guide](build.md) for more information about building your own
container images.

## Run the kops.sh script

Run the `kops.sh` script, and when prompted supply a FQDN name for your cluster
for a domain you control. Refer to the [kops
documentation](https://kops.sigs.k8s.io/getting_started/aws/#configure-dns) for
full instructions.

After you run the script, be sure to run the `export KOPS_STATE_STORE=...`
command specified, and edit the yaml file with the output the script provides.

You will then need to run the following commands:
```bash
# Set to your cluster name
CLUSTER_NAME=my-super-cool-cluster.mydomain.com
kops create -f ./$CLUSTER_NAME.yaml
kops create secret --name $CLUSTER_NAME sshpublickey admin -i ~/.ssh/id_rsa.pub
kops update cluster $CLUSTER_NAME --yes
kops validate cluster --wait 10m
cat << EOF > aws-iam-authenticator.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: aws-iam-authenticator
  namespace: kube-system
  labels:
    k8s-app: aws-iam-authenticator
data:
  config.yaml: |
    clusterID: $CLUSTER_NAME
EOF
kubectl apply -f aws-iam-authenticator.yaml
```
You can verify the pods in your cluster are using the EKS Distro images by running
the following command:
```bash
kubectl get po --all-namespaces -o json | jq -r .items[].spec.containers[].image | sort -u
```
To tear down the cluster, run:
```bash
kops delete -f ./$CLUSTER_NAME.yaml --yes
```

# Starting EKS-D with kubeadm

You can start up EKS-D using the *kubeadm init* command. To help you with that,
the following procedure:

1. Uses *packer* to create an AMI that includes the EKS-D software.
2. Starts up an EC2 instance from that AMI.
2. Runs *kubeadm init* on the AMI to start up EKS-D.

The result is a single Kubernetes master running EKS-D software.
If you prefer to build EKS-D from source code, see the [Build](build.md) instructions.
See the [FAQ](community/faq) for details on EKS-D and what it includes.


## Create an AMI with EKS-D

You can use [packer](https://packer.io) to create an AMI that includes the EKS-D distribution. Here’s what you need:

1. Download the packer binary from [packer.io](https://packer.io/).
2. Pull the packer template and EKS-D software to your local system. For example:

```bash
$ git clone git@github.com:aws/eks-distro
```

3. Change to the directory containing the *eks-distro.json* file to build the
EKS-D AMI, modify it as necessary (needs credentials to pull public images
from ECR) then run the following:

```bash
$ packer build eks-distro.json
```

As a result:

* A new AMI named eks-distro-<timestamp> is created, using the latest Amazon2 AMI as its base.

* An instance type (t3.micro) is chosen and username (ec2-user) is assigned

* An Ansible playbook (eks-distro.yaml) runs to automate the configuration of the AMI for EKS-D. The results include:

    * Systemd services configured: Docker container engine and kubelet.

    * Container images ready to deploy the following: CNI plugins, etcd, kube-apiserver, kube-controller-manager, kube-scheduler, kube-proxy, metrics-server, aws-iam-authenticator, coredns, and pause container images.

    * Binary commands being installed: kubeadm and kubelet.

    * An SSH key being created and uploaded to EC2 to use for authentication to the running instance.

* A new EC2 instance starts from the AMI.

## Run kubeadm to initialize EKS-D

With the eks-distro AMI instance running on EC2, you are ready to start up EKS-D. Do the following:

1. SSH into the running eks-distro instance using the credentials created by packer.
2. Run the following command to initialize the cluster:

```bash
kubeadm init
```

Within about a minute, you have a Kubernetes master node running on the AMI,
using the components of EKS Distro.

Look for future versions to of this procedure to use Terraform to create a
VCP, subnets, and a load balancer. It will deploy EC2 from the AMI, send the
*kubeadm init* and  additional data through user data, and build additional
nodes to create a cluster automatically. For the time being, you need to log
in and build additional nodes yourself.
