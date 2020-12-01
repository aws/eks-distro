# Kubernetes

## Development

## Patches

## Reproducible builds

The builds of Kubernetes are reproducible, meaning you can build Kubernetes
using the same code, same toolchain and same build settings, and get bit-for-bit
identical binaries as output. In an effort to assure that we remain
reproducible, a sha256sum check is performed as part of CI. If your changes
alter the build environment or the source code, your new hashsums must also be
committed.

### GOROOT

While Go cross-compiles can result in reproducible builds, the value of
[`GOROOT`](https://golang.org/doc/install/source#environment) in your build
environment (`go env GOROOT`) needs to match what our CI and build systems use.
If you are building from macOS, and have installed go 1.15.3 with
[homebrew](https://brew.sh), your `GOROOT` will probably look like this:
``` bash
$ go env GOROOT
/usr/local/Cellar/go/1.15.3/libexec
```
In our [build container](https://github.com/aws/eks-distro-build-tooling/blob/main/builder-base/README.md), you can see we
get Go from https://golang.org/dl and install it in `/usr/local`
resulting in the following `GOROOT`:
```bash
# cd builder-base
$ make docker
$ docker run \
    YOUR_ACCOUNT_ID.dkr.ecr.us-west-2.amazonaws.com/eks-distro/builder:latest \
    go env GOROOT
/usr/local/go
```

For further reading, see this excellent post by [Filippo
Valsorda](https://blog.filippo.io/reproducing-go-binaries-byte-by-byte/).

### KUBE_GIT_VERSION_FILE

In each release directory, there are several metadata files, including a
`KUBE_GIT_VERSION_FILE`. This file contains build-time environment variables
that get included in the final binary. You can read more about these in the
[Kubernetes build
source](https://github.com/kubernetes/kubernetes/blob/v1.18.9/hack/lib/version.sh#L17-L32)
and the [Kubernetes build
documentation](https://github.com/kubernetes/kubernetes/blob/v1.18.9/build/README.md#reproducibility).
