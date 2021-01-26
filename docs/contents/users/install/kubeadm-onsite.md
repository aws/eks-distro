# Starting EKS-D with kubeadm (VM/bare metal)

Installing and running an an Elastic Kubernetes Service Distro (EKS-D) on
a VM or bare metal system requires setting up a few services and running
kubeadm, as described below. 

---
**NOTE**:
This procedure is provided for demonstration purposes and is not a supported product.
The EKS version is EKS 1.18.  A separate product named [EKS-Anywhere](https://aws.amazon.com/eks/eks-anywhere/) 
launches later in 2021 to let you automate your own bare metal and other EKS installations,
---

## Prerequisties

Create a Linux system for the Kubernetes control plane and one or more nodes.
This procedure was tested on an RPM-based Linux system. Start with the
following prerequisites:

1. Use a Linux system that kubeadm supports, as described in: [Before you begin](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin). Check that the system has the required amount of memory, CPU, and other resources. 

1. Make sure SELinux is disabled by setting *SELINUX=disabled* in the */etc/syconfig/selinux* file. To turn it off immediately, type:

    ```bash
    sudo setenforce 0
    ```

1. Make sure that swap is disabled and that no swap areas are reinstated on reboot. For example, type:

    ```bash
    sudo swapoff -a
    ```

    Then permanently disable swap by commenting out or deleting any swap areas in */etc/fstab*.

1. Depending on the exact Linux system you installed, you may need to install additional packages. For example, with an RPM-based (Amazon Linux, CentOS, RHEL or Fedora), ensure that the iproute-tc, socat, and conntrack-tools packages are installed.

1. To optionally enable a firewall, run the following commands, including
opening ports required by Kubernetes as described in
[Check required ports](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports):

```bash
        sudo yum install firewalld -y
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp --add-port=2379-2380/tcp --add-port=10250-10252/tcp

```

## Install runtime and supporting services

You need to install a container runtime (Docker, in this example) and the
EKS-D versions of Kubernetes software.

1. Install a runtime. Docker was tested with this procedure. You could use some other container runtime service, although extra steps might be needed:

        sudo yum install docker
        sudo systemctl start docker
        sudo systemctl enable docker

1. Pull and retag the *pause*, *coredns*, and *etcd* containers (copy and paste as one line):

        sudo docker pull public.ecr.aws/eks-distro/kubernetes/pause:v1.18.9-eks-1-18-1;\
        sudo docker pull public.ecr.aws/eks-distro/coredns/coredns:v1.7.0-eks-1-18-1; \
        sudo docker pull public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-1; \
        sudo docker tag public.ecr.aws/eks-distro/kubernetes/pause:v1.18.9-eks-1-18-1 public.ecr.aws/eks-distro/kubernetes/pause:3.2; \
        sudo docker tag public.ecr.aws/eks-distro/coredns/coredns:v1.7.0-eks-1-18-1 public.ecr.aws/eks-distro/kubernetes/coredns:1.6.7; \
        sudo docker tag public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-18-1 public.ecr.aws/eks-distro/kubernetes/etcd:3.4.3-0

1. Add the RPM repository to Google cloud RPM packages for Kubernetes by
creating the following */etc/yum.repos.d/kubernetes.repo* file:

        [kubernetes]
        name=Kubernetes
        baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        exclude=kubelet kubeadm kubectl

1. Install the required Kubernetes packages:

        sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

1. Create */etc/modules-load.d/k8.conf* so it appears as follows:

        br_netfilter

1. Create the */var/lib/kubelet directory*, then modify the */var/lib/kubelet/kubeadm-flags.env* file so it appears as shown below:

        sudo mkdir -p /var/lib/kubelet
        cat /var/lib/kubelet/kubeadm-flags.env
        KUBELET_KUBEADM_ARGS="--cgroup-driver=systemd —network-plugin=cni —pod-infra-container-image=public.ecr.aws/eks-distro/kubernetes/pause:3.2"

1. Get compatible binaries for *kubeadm*, *kubelet*, and *kubectl*.
You can skip getting *kubectl* for now if you want to work with the
cluster from your laptop:

        cd /usr/bin
        sudo rm kubelet kubeadm kubectl
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubelet; \
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubeadm; \
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubectl
        chmod +x kubeadm kubectl kubelet

1. To enable the *kubelet* service, type the following:

        sudo systemctl enable kubelet

1. Run the *kubeadm init* command, identifying the eks-distro image repository and Kubernetes version. Make any corrections requested for *kubeadm init* to complete successfully:

        sudo kubeadm init --image-repository public.ecr.aws/eks-distro/kubernetes --kubernetes-version v1.18.9-eks-1-18-1
        [init] Using Kubernetes version: v1.18.9-eks-1-18-1
        [preflight] Running pre-flight checks
        ...
        [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
        [addons] Applied essential addon: CoreDNS
        [addons] Applied essential addon: kube-proxy
        
        Your Kubernetes control-plane has initialized successfully!

    Your Kubernetes cluster should now be up and running. The kubeadm output should show the exact commands to use. If something goes wrong, correct the problem and run *kubeadm reset* to prepare you system to run *kubeadm init* again:

1. Follow the instructions for configuring the client. To configure the client locally, type:

        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

1. Deploy a pod network to the cluster. See Installing Addons (https://kubernetes.io/docs/concepts/cluster-administration/addons) for information on available Kubernetes pod networks. For example, to deploy a Weaveworks network, type:

        kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=v1.18.9-eks-1-18-1"
        serviceaccount/weave-net created
        clusterrole.rbac.authorization.k8s.io/weave-net (http://clusterrole.rbac.authorization.k8s.io/weave-net) created
        clusterrolebinding.rbac.authorization.k8s.io/weave-net (http://clusterrolebinding.rbac.authorization.k8s.io/weave-net) created
        role.rbac.authorization.k8s.io/weave-net (http://role.rbac.authorization.k8s.io/weave-net) created
        rolebinding.rbac.authorization.k8s.io/weave-net (http://rolebinding.rbac.authorization.k8s.io/weave-net) created
        daemonset.apps/weave-net created

    You can also consider [Calico](https://www.projectcalico.org/) or [Cillium](https://cilium.io/) networks. Calico is popular for on-premises use because Cisco switches talk to it easily.  

## Configure the client

1. At this point, log into your laptop and copy the *kubectl* command there. On a Linux system, you would do the following:

        cd /usr/bin/
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubectl
        sudo chmod +x kubectl

1. Copy the admin.conf file to your home directory:

        mkdir -p $HOME/.kube
        scp <user>@<host>:/etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config 

## Add nodes to the cluster

Join any number of worker nodes by configuring compatible Linux systems, as described in the Prerequisites section. Then run the following on each node as root, using the IP address, token and certificate hash output by the kubeadm:

        cd /usr/bin/
        sudo wget sudo wget https://distro.eks.amazonaws.com/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/bin/linux/amd64/kubeadm
        chmod +x kubeadm
        sudo kubeadm join <IPaddress>:6443  --token xxxx.xxxxxxxxxxxxxxxx  --discovery-token-ca-cert-hash sha256:5732c13c6fb4b992fb4d9e61bd09b33df87bd6394d924ce6ec6bf4ec1fec433c
