# Starting EKS-D with kubeadm (VM/bare metal)

Installing and running Elastic Kubernetes Service Distro (EKS-D) on
a VM or bare metal system requires setting up a few services and running
kubeadm, as described below. 

---
**WARNING**:
This procedure is provided for demonstration purposes and is not a supported product.
These directions use the EKS version v1.19.8-eks-1-19-4, but you should adjust them
accordingly for the version you wish to use. A separate product named 
[EKS-Anywhere](https://aws.amazon.com/eks/eks-anywhere/) 
lets you automate different types of EKS installations.
---

## Prerequisites

Create separate Linux systems for the Kubernetes control plane and one or more nodes.
This procedure was tested on Amazon Linux 2 on AWS, but should work similarly for any
RPM-based Linux system. Start with the
following prerequisites on each control plane and worker node:

1. Use a Linux system that kubeadm supports, as described in: [Before you begin](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#before-you-begin). Check that the system has the required amount of memory, CPU, and other resources. 

1. Make sure SELinux is disabled by setting *SELINUX=disabled* in the */etc/sysconfig/selinux* file. To turn it off immediately, type:

        :::bash
        sudo setenforce 0

1. Make sure that swap is disabled and that no swap areas are reinstated on reboot. For example, type:

        :::bash
        sudo swapoff -a

    Then permanently disable swap by commenting out or deleting any swap areas in */etc/fstab*. On a Fedora system, remove the zram-generator package.

1. Depending on the exact Linux system you installed, you may need to install additional packages. For example, with an RPM-based (Amazon Linux, CentOS, RHEL or Fedora), ensure that the iproute-tc, socat, and conntrack-tools packages are installed.

1. Install a runtime. Docker was tested with this procedure.
   You could use some other container runtime service, although extra steps might be needed:

        :::bash
        sudo yum install docker -y
        sudo systemctl start docker
        sudo systemctl enable docker

1. Add the RPM repository to Google cloud RPM packages for Kubernetes by
creating the following */etc/yum.repos.d/kubernetes.repo* file:

        :::bash
        [kubernetes]
        name=Kubernetes
        baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
        enabled=1
        gpgcheck=1
        repo_gpgcheck=1
        gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
        exclude=kubelet kubeadm kubectl

1. Install the following Kubernetes packages:

        :::bash
        sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

1. Get compatible binaries for *kubeadm*, *kubelet*, and *kubectl*.
You can skip getting *kubectl* for now if you want to work with the
cluster from your laptop:

        :::bash
        cd /usr/bin
        sudo rm kubelet kubeadm kubectl
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubelet; \
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubeadm; \
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubectl
        chmod +x kubeadm kubectl kubelet

1. To enable the *kubelet* service, type the following:

        :::bash
        sudo systemctl enable kubelet

1. Create the */var/lib/kubelet/kubeadm-flags.env* file so it appears as shown below:

        :::bash
        KUBELET_KUBEADM_ARGS="--cgroup-driver=systemd —network-plugin=cni —pod-infra-container-image=public.ecr.aws/eks-distro/kubernetes/pause:3.2"

## Set up a control plane node

This procedure sets up a single control plane node by installing a few services and binaries, then uses *kubeadm* to install the EKS-D version of Kubernetes.

1. As noted in [Initializing your control-plane node](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#initializing-your-control-plane-node),
kubeadm uses the network interface associated with the default gateway to set the advertise address for the API server.
If that default gateway is to an IPv6 network, the address shown with the *kubeadm join* command described later may point to the wrong address.
To get around this, you can either disable IPv6 networking as described in
[How to disable IPv6](https://www.thegeekdiary.com/centos-rhel-7-how-to-disable-ipv6/)
or use a command such as *netstat -tlpn* to see which addresses *kube-apiserver* is listening on.

1. To optionally enable a firewall on the control plane node, run the following commands, including
opening ports required by Kubernetes as described in
[Check required ports](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#check-required-ports):

        :::bash
        sudo yum install firewalld -y
        sudo systemctl start firewalld
        sudo systemctl enable firewalld
        sudo firewall-cmd --zone=public --permanent --add-port=6443/tcp --add-port=2379-2380/tcp --add-port=10250-10252/tcp

    Note that for an AWS EC2 instance, you must also set up Inbound Rules in your instance's Security Group that allows access to the same ports.
See [Working with security groups](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_SecurityGroups.html#WorkingWithSecurityGroups) for details.

1. Pull and retag the *pause*, *coredns*, and *etcd* containers (copy and paste as one line):

        :::bash
        sudo docker pull public.ecr.aws/eks-distro/kubernetes/pause:v1.19.8-eks-1-19-4;\
        sudo docker pull public.ecr.aws/eks-distro/coredns/coredns:v1.8.0-eks-1-19-4;\
        sudo docker pull public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-19-4;\
        sudo docker tag public.ecr.aws/eks-distro/kubernetes/pause:v1.19.8-eks-1-19-4 public.ecr.aws/eks-distro/kubernetes/pause:3.2;\
        sudo docker tag public.ecr.aws/eks-distro/coredns/coredns:v1.8.0-eks-1-19-4 public.ecr.aws/eks-distro/kubernetes/coredns:1.7.0;\
        sudo docker tag public.ecr.aws/eks-distro/etcd-io/etcd:v3.4.14-eks-1-19-4 public.ecr.aws/eks-distro/kubernetes/etcd:3.4.13-0

1. Create */etc/modules-load.d/k8s.conf* so it appears as follows:

        :::bash
        br_netfilter

1. Create */etc/sysctl.d/99-k8s.conf* file that contains the following:

        :::bash
        net.bridge.bridge-nf-call-iptables = 1

    Then run *systemctl -p /etc/sysctl.d/99-k8s.conf* to load that value.


1. Run the *kubeadm init* command, identifying the eks-distro image repository and Kubernetes version. Make any corrections requested for *kubeadm init* to complete successfully:

        :::bash
        sudo kubeadm init --image-repository public.ecr.aws/eks-distro/kubernetes --kubernetes-version v1.19.8-eks-1-19-4

    The output should include something like the following:

        :::bash
        [init] Using Kubernetes version: v1.19.8-eks-1-19-4
        [preflight] Running pre-flight checks
        ...
        [kubelet-finalize] Updating "/etc/kubernetes/kubelet.conf" to point to a rotatable kubelet client certificate and key
        [addons] Applied essential addon: CoreDNS
        [addons] Applied essential addon: kube-proxy
        
    Your Kubernetes control-plane has initialized successfully!

    Your Kubernetes cluster should now be up and running. The kubeadm output shows the exact commands to use to add nodes to the cluster. If something goes wrong, correct the problem and run *kubeadm reset* to prepare your system to run *kubeadm init* again:

1. Follow the instructions for configuring the client. To configure the client locally, type:

        :::bash
        mkdir -p $HOME/.kube
        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config

1. Deploy a pod network to the cluster. See [Installing Addons](https://kubernetes.io/docs/concepts/cluster-administration/addons) for information on available Kubernetes pod networks. For example, to deploy a Weaveworks network, type:
        :::bash
        kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=v1.19.8-eks-1-19-4"

    The output should appear similar to the following:

        :::bash
        serviceaccount/weave-net created
        clusterrole.rbac.authorization.k8s.io/weave-net (http://clusterrole.rbac.authorization.k8s.io/weave-net) created
        clusterrolebinding.rbac.authorization.k8s.io/weave-net (http://clusterrolebinding.rbac.authorization.k8s.io/weave-net) created
        role.rbac.authorization.k8s.io/weave-net (http://role.rbac.authorization.k8s.io/weave-net) created
        rolebinding.rbac.authorization.k8s.io/weave-net (http://rolebinding.rbac.authorization.k8s.io/weave-net) created
        daemonset.apps/weave-net created

    You can also consider [Calico](https://www.projectcalico.org/) or [Cilium](https://cilium.io/) networks. Calico is popular because it can be used to propagate routes with BGP, which is often used on-prem.

1. Optional: By default, you cannot deploy applications to a control plane node. So, you have to either add a node (as described later) or untaint the master node to allow pods to be scheduled, as follows:

        :::bash
        kubectl taint nodes --all node-role.kubernetes.io/master-

## Configure the client

If you want to use the *kubectl* client from a system other than your control plane node, such as your personal laptop, follow these instructions:

1. Log into your laptop and copy your credentials and the *kubectl* command and there. On a Linux system, you would do the following:

        :::bash
        cd /usr/bin/
        sudo wget https://distro.eks.amazonaws.com/kubernetes-1-19/releases/4/artifacts/kubernetes/v1.19.8/bin/linux/amd64/kubectl
        sudo chmod +x kubectl


1. Copy the *admin.conf* file to your home directory:

        :::bash
        mkdir -p $HOME/.kube
        scp <user>@<host>:/etc/kubernetes/admin.conf $HOME/.kube/config
        sudo chown $(id -u):$(id -g) $HOME/.kube/config 

## Set up worker nodes to the cluster

Join any number of worker nodes to the control plane, using the IP address, token, and certificate hash output by the *kubeadm init* run on the control plane:

1. For each worker node, configure a compatible Linux system, as described in the Prerequisites section above.

1. Pull and re-tag the *pause* container (copy and paste as one line):

        :::bash
        sudo docker pull public.ecr.aws/eks-distro/kubernetes/pause:v1.19.8-eks-1-19-4;\
        sudo docker tag public.ecr.aws/eks-distro/kubernetes/pause:v1.19.8-eks-1-19-4 public.ecr.aws/eks-distro/kubernetes/pause:3.2;\

1. Run the kubeadm command to join the worker node to the cluster, using the *kubeadm init* output when you installed the control plane node:

        :::bash
        sudo kubeadm join <IPaddress>:6443  --token <xxxx.xxxxxxxxxxxxxxxx>  \
            --discovery-token-ca-cert-hash sha256:<xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx>

You should now have a working cluster that is able to schedule workloads on the nodes you configured.
