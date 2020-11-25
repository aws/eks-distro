ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-attacher/$TARGETOS-$TARGETARCH/csi-attacher /csi-attacher
ENTRYPOINT ["/csi-attacher"]
