# Build Prerequisites

In order to build EKS Distro, you will need to make sure several things
are installed and configured.

## Region Environment Variables

The build uses the new convention setting region with the `AWS_REGION` environment
variable. Some older utilities such as v1 of the AWS CLI use the environment
variable `AWS_DEFAULT_REGION`. To be safe, set and export both to the same value:

    export AWS_REGION=us-west-2
    export AWS_DEFAULT_REGION="${AWS_REGION}"

## Go Proxy Settings

If you are using an HTTP proxy like you might if you are on a corporate VPN,
you may need to set and export `GOPROXY`:

    export GOPROXY=direct

## Amazon ECR

If you are building container images and uploading or downloading from ECR, you
will need to configure buildctl to get registry credentials. While you could
periodically use the AWS CLI and run [`aws ecr
get-login`](https://docs.aws.amazon.com/cli/latest/reference/ecr/get-login.html)
to populate credentials into your `~/.docker/config.json`, it is much easier to
use the [ECR Credential
Helper](https://github.com/awslabs/amazon-ecr-credential-helper). To get up and
running easily, you can use the custom Docker config file provided in this repo.
After installing the ECR credential helper, make sure you have AWS credentials
configured in one the usual ways, and set the Docker config to the supplied
example:
```bash
cat ./development/config.json
{
  "credsStore": "ecr-login"
}
# enables ecr push/pull
export DOCKER_CONFIG=$(pwd)/development
```

To create all the required ECR repositories for EKS Distro, run the
`/development/ecr/ecr-command.sh create-all-private-repositories` script.

## Qemu

In order to build and run multi-architecture containers, you will need to
install [Qemu](https://www.qemu.org/download/). On AmazonLinux2, this can be
installed with the `qemu-user-static` package, and then updating your host's
`binfmt_misc` configuration.

## GNU Tar

If you are on a Mac, you will need to `brew install coreutils` to get GNU
tar.

## Build Options

The default target for make files uses `buildkit` to build containers. The
alternative to this is building and pushing containers with Docker.

### buildkitd

The default target for make files builds with
[buildkit](https://github.com/moby/buildkit).
You can install the latest buildkit client from the [GitHub releases
page](https://github.com/moby/buildkit/releases). To run a buildkit server
locally, you can use [docker-compose](https://docs.docker.com/compose/).

```bash
docker-compose -f development/buildkit-compose.yaml up -d
docker-compose -f development/buildkit-compose.yaml logs buildkitd
export BUILDKIT_HOST="tcp://127.0.0.1:1234"
buildctl debug workers
```

*Note*: If you notice that `RUN` commands in image builds that require network
access are failing, your network may be blocking DNS lookups to Google DNS IPs
(`8.8.8.8` and `8.8.4.4`). If you see the log message from the buildkit server:
```
"No non-localhost DNS nameservers are left in resolv.conf. Using default external servers: [nameserver 8.8.8.8 nameserver 8.8.4.4]
```
Try adding your local nameservers and search domains to the
`development/buildkitd.toml` file and the `dns` and `dns_search`, and `volume`
sections of the `development/buildkit-compose.yaml`, and run `docker-compose up
-d`. If you are on macOS, you can run the following command to find your
nameservers and search domains.
```bash
scutil --dns
```

### Build with Docker

If you don't want to use `buildkit`, you will need
to install [Docker](https://docs.docker.com/get-docker/) to build containers.
Use the `docker` target for make files.
