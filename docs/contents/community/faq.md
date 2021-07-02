# Frequently Asked Questions (FAQ)

## A Kubernetes distribution?

!!! question "Question"
    What is a Kubernetes distribution and why do you call EKS Distro one?

!!! quote "Answer"
    EKS Distro is a distro of the same open source Kubernetes and dependencies
    deployed by Amazon EKS. We include binaries and containers of open source 
    Kubernetes, `etcd`, networking, and storage plugins, all of which are tested
    for compatibility. We provide extended support for Kubernetes versions after
    community support expires by updating builds of previous versions with the 
    latest critical security patches. You can securely access EKS Distro releases
    from GitHub or within AWS via Amazon S3 and ECR for a common source of 
    releases and updates.

## Is this a fork of Kubernetes?

!!! question "Question"
    Is EKS Distro forking Kubernetes?

!!! quote "Answer"
    No. EKS Distro takes upstream (unmodified) Kubernetes and packages and configures
    it in a certain, opinionated manner. We've gathered these opinions by
    running tens of thousands of EKS clusters at different scales, world-wide.


## Why use EKS Distro?

!!! question "Question"
    Why should I use EKS Distro?

!!! quote "Answer"
    EKS Distro enables you to create Kubernetes clusters using a distro of compatible
    versions of the latest Kubernetes release and its dependencies, tested by 
    Amazon EKS to be reliable and secure. With EKS Distro, you have a single vendor 
    for secure access to installable, reproducible builds of Kubernetes for
    cluster creation and extended security patching support of Kubernetes 
    versions after community support expires. We will provide extended Kubernetes
    maintenance support for up to 14 months in accordance with Amazon EKS 
    Version Lifecycle Policy, providing you the timeframe necessary to update 
    your infrastructure in alignment with your software lifecycle. For further
    information on supported Kubernetes versions in EKS, see
    [Amazon EKS version support and FAQ](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions.html#version-deprecation).

## What is included in EKS Distro?

!!! question "Question"
    What is included in EKS Distro?

!!! quote "Answer"
    EKS Distro includes open source (upstream) Kubernetes components and third-party
    tools, including configuration database, network, and storage components 
    necessary for cluster creation. They include Kubernetes control plane 
    components (e.g. `kube-controller-manager`, `etcd`, and CoreDNS), 
    Kubernetes worker node components (e.g. `kubelet`, CSI, and CNI), and
    command line clients (e.g. `kubectl` and `kubeadm`).


## What operating systems are supported?

!!! question "Question"
    What operating system can I install EKS Distro on?

!!! quote "Answer"
    We provide the same upstream versions of Kubernetes and dependencies that 
    operating system vendors have tested and confirmed to work with Kubernetes
    and will work the same way. As a result, EKS Distro works with common operating
    systems already used to create Kubernetes clusters, such as CentOS, 
    Canonical Ubuntu, Red Hat Enterprise Linux, Suse, and more. EKS Distro is 
    tested by select vendors on various operating systems including Bottlerocket, 
    Amazon Linux 2 and Ubuntu.
