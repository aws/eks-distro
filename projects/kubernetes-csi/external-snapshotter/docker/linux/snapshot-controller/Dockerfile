ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-snapshotter/$TARGETOS-$TARGETARCH/snapshot-controller /snapshot-controller
ENTRYPOINT ["/snapshot-controller"]
