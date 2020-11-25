ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/external-snapshotter/$TARGETOS-$TARGETARCH/snapshot-validation-webhook /snapshot-validation-webhook
ENTRYPOINT ["/snapshot-validation-webhook"]
