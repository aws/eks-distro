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
