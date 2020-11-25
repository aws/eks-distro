ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/livenessprobe/$TARGETOS-$TARGETARCH/livenessprobe /livenessprobe
ENTRYPOINT ["/livenessprobe"]
