## EKS Distro Development Tools

This directory contains various tools to help EKS-D developers.

### BuildKit

To run BuildKit in docker:

```bash
docker-compose -f buildkit-compose.yaml up -d
docker-compose -f buildkit-compose.yaml logs buildkitd
export BUILDKIT_HOST="tcp://127.0.0.1:1234"
buildctl debug workers
```

To stop BuildKit:
```bash
docker-compose -f buildkit-compose.yaml down
```
