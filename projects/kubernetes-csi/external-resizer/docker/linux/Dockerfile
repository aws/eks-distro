ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-resizer/$TARGETOS-$TARGETARCH/csi-resizer /csi-resizer
ENTRYPOINT ["/csi-resizer"]
