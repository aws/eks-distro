ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/metrics-server/$TARGETOS-$TARGETARCH/metrics-server /metrics-server
ENTRYPOINT ["/metrics-server"]
