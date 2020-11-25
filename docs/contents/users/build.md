# Build

In order to build an EKS Distro yourself, you will need to make sure several things
are installed and configured. Before you begin, make sure you have
satisfied the [build prerequisites](build-prerequisites.md).

## Build EKS Distro Base

The first step of the build is to build the base container class. The
base container can be found in the
[EKS Distro Build Tooling](https://github.com/aws/eks-distro-build-tooling) repository.
The `eks-distro-base` directory in the repository contains a make file. If you are
going to use Elastic Container Repository (ECR), create it:

    make ecr

The container is built with:

    make docker IMAGE_TAG=186a72f9954148ae3abe9f236ac397e5a6264ec2

If you want to push to a private repository:

    make docker-push IMAGE_TAG=186a72f9954148ae3abe9f236ac397e5a6264ec2

## Build Remaining Containers

The second step of the build is to build the rest of the containers out
of the [EKS Distro Build Steps Repository](https://github.com/aws/eks-distro).
In the project root directory is a `Makefile` which assumes
you are using ECR and have created ECR repositories. Run the script with:

    make release
