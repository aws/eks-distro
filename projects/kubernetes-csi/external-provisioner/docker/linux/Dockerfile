ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-provisioner/$TARGETOS-$TARGETARCH/csi-provisioner /csi-provisioner
ENTRYPOINT ["/csi-provisioner"]
