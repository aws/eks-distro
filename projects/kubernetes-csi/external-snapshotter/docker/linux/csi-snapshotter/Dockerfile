ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-snapshotter/$TARGETOS-$TARGETARCH/csi-snapshotter /csi-snapshotter
ENTRYPOINT ["/csi-snapshotter"]
