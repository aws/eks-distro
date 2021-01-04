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

```shell
make ecr
```

The container is built with:

```shell
make docker
```

If you want to push to a private repository:

```shell
make docker-push
```

## Build Remaining Containers

The second step of the build is to build the rest of the containers out
of the [EKS Distro Container Repository](https://github.com/aws/eks-distro).
In the project root directory is a `Makefile` which assumes
you are using ECR and have created ECR repositories. Run the script with:


```shell
make release
```
