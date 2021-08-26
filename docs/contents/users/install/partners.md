# Overview of Partners

A number of partners are providing install methods as well as integrations
with EKS Distro.

## Alcide

Alcide provides centralized and unified security coverage across hybrid 
deployments that span across EKS, Outposts, and Amazon EKS Distro. 
Customers can use the same tools and best practices regardless of the
deployment infrastructure. The Alcide platform addresses all Kubernetes 
security needs holistically, from design through deployment to production. 
The platform is designed from a DevOps perspective, while also ensuring robust
and comprehensive Kubernetes security and compliance best practices.

[Learn more](https://blog.alcide.io/alcide-and-amazon-eks-distro)

## Aqua Security

Aqua Security provides KSPM (Kubernetes Security Posture Management) to improve
visibility and remediate misconfigurations, as well as advanced, agentless K8s
runtime protection. Customers can also leverage Kubernetes-native capabilities
to attain policy-driven, full lifecycle protection and compliance for K8s
applications.

[Learn more](https://blog.aquasec.com/aws-security-eks-distro)

## Canonical

Canonical allows you to take Amazon EKS Distro and combine it with the MicroK8s
experience to get an opinionated, self-healing, highly available EKS-compatible
Kubernetes for use anywhere you can get Ubuntu. Just snap install EKS, and you 
are up and running.

[Learn more](https://snapcraft.io/eks)

## Datadog

Datadog provides visibility into the health of VMs, containers, and serverless 
environments across on-premise, hybrid, and cloud compute infrastructure.

[Learn more](https://www.datadoghq.com/blog/amazon-eks-distro-monitoring/)

## Epsagon

Epsagon enables you to monitor Amazon EKS Distro workloads, including control
plane metrics. Customers can leverage Epsagon to instantly monitor, troubleshoot,
and trace issues in their EKS-D or EKS workloads seamlessly.

[Learn more](https://epsagon.com/announcements/amazon-eks-distro/)

## Instana

Instana works seamlessly on Kubernetes clusters using Amazon EKS Distro. 
With Instana customers can automatically monitor and visualize EKS-D and EKS workloads.

[Learn more](https://instana.com/blog/instana-brings-best-in-class-observability-with-the-new-amazon-kubernetes-distribution/)

## Kubermatic

Amazon EKS Distro can be installed using KubeOne by Kubermatic. KubeOne is an
infrastructure-agonistic and open source Kubernetes cluster lifecycle management
tool that automates the deployment and Day 2 operations of single Kubernetes
clusters. Thanks to KubeOne’s Terraform integration and ease of use, 
infrastructure responsibles can install EKS Distro on AWS and Amazon Linux 2 
with minimal operational effort. For a detailed description of how to install
KubeOne, please see the KubeOne [documentation](https://docs.kubermatic.com/kubeone/master/). 

[Learn more](https://www.kubermatic.com/blog/run-amazon-eks-distro-with-kubeone)

### Set up EKS-D with KubeOne

First, create the `terraform.tfvars` file to instruct Terraform to create 
Amazon Linux 2 instances and to use the static workers instead of MachineDeployments. 

Example terraform.tfvars file:

```
cluster_name = "<your-cluster name>"
ssh_public_key_file = "~/.ssh/terraform_rsa.pub"
initial_machinedeployment_replicas = 0
# This variable doesn't have any effect, as initial_machinedeployment_replicas
# is set to 0. Instead, static worker nodes running Amazon Linux 2 will be used
# (defined by static_workers_count and os variables).
# This will be fixed in the upcoming versions.
worker_os                          = "ubuntu"
static_workers_count               = 3
os                                 = "amazon_linux2"
ssh_username                       = "ec2-user"
bastion_user                       = "ec2-user"
```

Next, create the infrastructure using Terraform using `terraform apply`.

Now create the KubeOne Config manifest. Make sure to populate the `assetConfiguration`
part with the real images. Here's an example:

```yaml
apiVersion: kubeone.io/v1beta1
kind: KubeOneCluster
versions:
  kubernetes: "v1.18.9-eks-1-18-1"
cloudProvider:
  aws: {}
assetConfiguration:
  kubernetes:
    imageRepository: "public.ecr.aws/f5s3s0y8/kubernetes"
  pause:
    imageRepository: "public.ecr.aws/f5s3s0y8/kubernetes"
    imageTag: "v1.18.9-eks-1-18-1"
  etcd:
    imageRepository: "public.ecr.aws/f5s3s0y8/etcd-io"
    imageTag: "v3.4.14-eks-1-18-1"
  coreDNS:
    imageRepository: "public.ecr.aws/f5s3s0y8/coredns"
    imageTag: "v1.7.0-eks-1-18-1"
  metricsServer:
    imageRepository: "public.ecr.aws/f5s3s0y8/kubernetes-sigs"
    imageTag: "v0.4.0-eks-1-18-1"
  cni:
    url: "https://beta.cdn.model-rocket.aws.dev/kubernetes-1-18/releases/1/artifacts/plugins/v0.8.7/cni-plugins-linux-amd64-v0.8.7.tar.gz"
  nodeBinaries:
    url: "https://beta.cdn.model-rocket.aws.dev/kubernetes-1-18/releases/1/artifacts/kubernetes/v1.18.9/kubernetes-node-linux-amd64.tar.gz"
  kubectl:
    url: "https://dl.k8s.io/v1.18.9/bin/linux/amd64/kubectl"
```

To complete, run `kubeone apply -t .`.

## Kubestack

Kubestack is a Terraform framework that provides a GitOps workflow to manage 
EKS clusters and cluster services.

### Simulate EKS clusters locally

Kubestack's auto-updating local development environment uses EKS-D to mirror 
your EKS clusters on `localhost`.

```bash
# Use the Kubestack CLI to scaffold a new repository using the EKS starter:
kbst repo init eks

# Bring up the local development environment using EKS-D:
kbst local apply
```

### Learn more about Kubestack

For more detailed instructions, including how to install the CLI, follow the
[Kubestack tutorial](https://www.kubestack.com/framework/documentation/tutorial-get-started)
or check out the [demo video](https://www.youtube.com/watch?v=TcVwtfFww4w) that
shows the Kubestack workflow from local development powered by EKS-D to production
on EKS using GitLab CI/CD.

[Learn
more](https://dev.to/kubestack/localhost-eks-development-environments-with-eks-d-and-kubestack-4p6)

## Nirmata

Nirmata’s Day 2 Kubernetes platform has integrated support for cluster provisioning 
and life-cycle management of on-prem enterprise Kubernetes clusters using Amazon EKS Distro.

[Learn more](https://nirmata.com/2020/11/20/nirmata-delivers-consistent-hybrid-cloud-kubernetes-with-aws/)

## Pulumi

Pulumi's modern infrastructure as code platform empowers cloud engineering 
teams to work better together to ship faster with confidence, using open source
and the world’s most popular programming languages. Pulumi’s SaaS product enables
a consistent workflow for delivering and securing applications and infrastructure
on any cloud—public, private, or hybrid—including AWS and more than 50 other 
cloud infrastructure providers. Organizations of all sizes, from startups to 
the Global 2000, have chosen Pulumi for their cloud transformation and modernization needs.


[Learn more](https://pulumi.com/blog/amazon-eks-distro)

## Rafay

The Rafay Managed Kubernetes Platform (MKP) is an open platform with a 
foundational philosophy that customers should be able to use their preferred
Kubernetes distribution in their operating environments. Using the Rafay MKP,
customers can now easily provision and manage the lifecycle of Amazon EKS Distro
for their on-premises (bare metal or VM) and cloud deployments.

[Learn more](https://rafay.co/the-kubernetes-current/how-to-provision-and-manage-amazons-eks-distribution-using-rafay)


## Rancher

Rancher Labs delivers open source software that enables organizations to deploy
and manage Kubernetes at scale, on any infrastructure across the data center, 
cloud, branch offices, and the network edge.

[Learn more](https://rancher.com/blog/2020/RKE2-supports-amazon-EKS-distro)


## Sumo Logic

Sumo Logic’s [Kubernetes Observability Solution](https://www.sumologic.com/brief/continuous-intelligence-kubernetes/)
is an integrated solution to monitor, diagnose, troubleshoot, and secure Kubernetes applications.

[Learn more](https://www.sumologic.com/blog/monitor-aws-kubernetes-service/)


## Sysdig

Sysdig provides security and visibility to detect and respond to runtime threats,
validate compliance, and monitor and troubleshoot containers on EKS-D.

[Learn more](https://sysdig.com/blog/security-compliance-visibility-amazon-eks-d)


## Tetrate

Tetrate Service Bridge from Tetrate provides enterprise-grade Istio and Envoy 
Proxy, supports multi-cluster application connectivity and multi-tenancy.

[Learn more](https://www.tetrate.io/blog/tetrate-expands-aws-partnership-to-bring-enterprise-grade-istio-for-eks-and-eks-distro/)

## Tigera

Tigera is the home of the leading solutions for Kubernetes networking, security,
and observability in hybrid and multi-cloud environments: [Calico](https://docs.projectcalico.org/about/about-calico)
and [Calico Enterprise](https://dev-tigera-2019.pantheonsite.io/tigera-products/calico-enterprise/).
Many of the world’s largest enterprises rely on Tigera to secure both their 
EKS and self-managed Kubernetes clusters running on AWS.

[Learn more](https://www.tigera.io/blog/tigera-to-support-amazon-eks-distro/)


## Upbound

Use Upbound’s [Crossplane](https://crossplane.io/) open source solution to 
manage EKS-D via the Cluster API (CAPI).

[Learn more](https://blog.upbound.io/aws-project-paris-and-upbound/)

## Weaveworks

Weave Kubernetes Platform brings GitOps support to [Amazon EKS Distro](https://weave.works/blog/on-prem-kubernetes-gitops-eks-distro),
providing support for installing, creating, and managing EKS-D clusters on-premise. 

[Learn more](https://weave.works/blog/multicluster-gitops-eks-d-wkp)
