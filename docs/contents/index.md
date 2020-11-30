# Amazon EKS Distro

Amazon **EKS Distro** (EKS-D) is a Kubernetes distribution based on and used by 
Amazon Elastic Kubernetes Service (EKS) to create reliable and secure Kubernetes clusters. With EKS-D,
you can rely on the same versions of Kubernetes and its dependencies deployed
by Amazon EKS. This includes the latest upstream updates as well as extended 
security patching support. EKS-D follows the same Kubernetes version release 
cycle as Amazon EKS and we provide the bits here. 
EKS-D provides the same software that has enabled tens of thousands of Kubernetes
clusters on Amazon EKS.

What is the difference between EKS (the AWS Kubernetes cloud service) and EKS-D?
The main difference is in how they are managed. EKS is a fully managed
Kubernetes platform, while EKS-D is available to install and manage yourself.
You can run EKS-D on-premises, in a cloud, or on your own systems. Using EKS-D outside
of AWS can provide a path to having the same Kubernetes distribution
wherever you need to run it as the Kubernetes you use in the cloud with EKS.


Once EKS-D is running, you are responsible for managing and
upgrading it yourself. For end users, however, running applications is the
same as with EKS since the two support the same API versions and
same set of components.

In the near future, a supported, packaged product and installation method
for EKS-D will be available under the name EKS Anywhere (EKS-A). To try out
EKS-D for now, instructions in this repository describe how to:

* Build EKS-D from source code

* Add EKS-D into an AMI that is ready to initialize EKS-D

* Install EKS-D using kOps or other installation methods

Check out EKS Distro's [Starting a cluster](users/index.md) page or
refer to the [Build](users/build) instructions to build a cluster from scratch.
See the [Partners](community/partners) page for links to third-party methods for
installing EKS-D.