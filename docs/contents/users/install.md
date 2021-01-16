# Installation

## Libvirt

Libvirt deployments are based in multiple guests VMs
deployed on a common hypervisor host.
There are multiple use cases that can fit this scenario
for instance continuous integration deployments or
development environments.

### KubeInit

[KubeInit](https://github.com/kubeinit/kubeinit)
is an Ansible collection to ease the deployment
of multiple upstream Kubernetes distributions.
The following sections will describe a 3 controllers,
1 compute deployment on a Libvirt host using Kubeinit as
the Ansible automation to configure the requirements
to have a functional cluster.

#### Components

Here is a list of the components that are currently deployed:

* Guests OS: CentOS 8 (8.2.2004)
* Kubernetes distribution: EKS-D
* Infrastructure provider: Libvirt
* A service machine with the following services:
    - HAProxy: 1.8.23 2019/11/25
    - Apache: 2.4.37
    - NFS (nfs-utils): 2.3.3
    - DNS (bind9): 9.11.13
    - Disconnected docker registry: v2
    - Skopeo: 0.1.40
* Control plane services:
    - Kubelet 1.18.4
    - CRI-O: 1.18.4
    - Podman: 1.6.4
* Controller nodes: 3
* Worker nodes: 1

#### Deploying

The deployment procedure is the same as it is for the other
Kubernetes distributions that can be deployed with KubeInit.

Please follow the [usage documentation](http://docs.kubeinit.com/usage.html)
to understand the system's requirements and the required host supported
Linux distributions.

```bash
# Make sure you can connect to your hypervisor (called nyctea)
# with passwordless access. (defaulted in the Ansible inventory)

# Choose the distro
distro=eks

# Run the deployment command
git clone https://github.com/kubeinit/kubeinit.git
cd kubeinit
ansible-playbook \
    --user root \
    -v -i ./hosts/$distro/inventory \
    --become \
    --become-user root \
    ./playbooks/$distro.yml
```

This will deploy by default a 3 controllers 1 compute cluster.

The deployment time was fairly quick (around 15 minutes):

```bash
.
.
.
  "      description: snapshot-validation-webhook container image",
  "      image:",
  "        uri: public.ecr.aws/eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook:v3.0.2-eks-1-18-1",
  "      name: snapshot-validation-webhook-image",
  "      os: linux",
  "      type: Image",
  "    gitTag: v3.0.2",
  "    name: external-snapshotter",
  "  date: \"2020-12-01T00:05:35Z\""
]
}
META: ran handlers
META: ran handlers

PLAY RECAP *****************************************************************************************************************
hypervisor-01              : ok=188  changed=93   unreachable=0    failed=0    skipped=43   rescued=0    ignored=4   

real	17m12.889s
user	1m24.846s
sys	0m24.366s
```

Let's run some commands in the cluster.

```bash
[root@eks-service-01 ~]: curl --user registryusername:registrypassword \
                         https://eks-service-01.clustername0.kubeinit.local:5000/v2/_catalog
{
   "repositories":[
      "aws-iam-authenticator",
      "coredns",
      "csi-snapshotter",
      "eks-distro/coredns/coredns",
      "eks-distro/etcd-io/etcd",
      "eks-distro/kubernetes/go-runner",
      "eks-distro/kubernetes/kube-apiserver",
      "eks-distro/kubernetes/kube-controller-manager",
      "eks-distro/kubernetes/kube-proxy",
      "eks-distro/kubernetes/kube-proxy-base",
      "eks-distro/kubernetes/kube-scheduler",
      "eks-distro/kubernetes/pause",
      "eks-distro/kubernetes-csi/external-attacher",
      "eks-distro/kubernetes-csi/external-provisioner",
      "eks-distro/kubernetes-csi/external-resizer",
      "eks-distro/kubernetes-csi/external-snapshotter/csi-snapshotter",
      "eks-distro/kubernetes-csi/external-snapshotter/snapshot-controller",
      "eks-distro/kubernetes-csi/external-snapshotter/snapshot-validation-webhook",
      "eks-distro/kubernetes-csi/livenessprobe",
      "eks-distro/kubernetes-csi/node-driver-registrar",
      "eks-distro/kubernetes-sigs/aws-iam-authenticator",
      "eks-distro/kubernetes-sigs/metrics-server",
      "etcd",
      "external-attacher",
      "external-provisioner",
      "external-resizer",
      "go-runner",
      "kube-apiserver",
      "kube-controller-manager",
      "kube-proxy",
      "kube-proxy-base",
      "kube-scheduler",
      "livenessprobe",
      "metrics-server",
      "node-driver-registrar",
      "pause",
      "snapshot-controller",
      "snapshot-validation-webhook"
   ]
}
```

It's possible now to check some of the deployed resources.

```bash
[root@eks-service-01 ~]: kubectl describe pods etcd-eks-master-01.kubeinit.local -n kube-system
Name:                 etcd-eks-master-01.kubeinit.local
Namespace:            kube-system
Priority:             2000000000
Priority Class Name:  system-cluster-critical
Node:                 eks-master-01.kubeinit.local/10.0.0.1
Start Time:           Sun, 06 Dec 2020 19:51:25 +0000
Labels:               component=etcd
                      tier=control-plane
Annotations:          kubeadm.kubernetes.io/etcd.advertise-client-urls: https://10.0.0.1:2379
                      kubernetes.io/config.hash: 3be258678a84985dbdb9ae7cb90c6a97
                      kubernetes.io/config.mirror: 3be258678a84985dbdb9ae7cb90c6a97
                      kubernetes.io/config.seen: 2020-12-06T19:51:18.652592779Z
                      kubernetes.io/config.source: file
Status:               Running
IP:                   10.0.0.1
IPs:
  IP:           10.0.0.1
Controlled By:  Node/eks-master-01.kubeinit.local
Containers:
  etcd:
    Container ID:  cri-o://7a52bd0b80feb8c861c502add4c252e83c7e4a1f904a376108e3f6f787fd342c
    Image:         eks-service-01.clustername0.kubeinit.local:5000/etcd:v3.4.14-eks-1-18-1
```

As long as other container images are published for EKS-D they will be added to the
deployment automation from KubeInit.
