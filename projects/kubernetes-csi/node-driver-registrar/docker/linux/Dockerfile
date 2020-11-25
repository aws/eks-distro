ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/node-driver-registrar/$TARGETOS-$TARGETARCH/csi-node-driver-registrar /csi-node-driver-registrar
ENTRYPOINT ["/csi-node-driver-registrar"]
