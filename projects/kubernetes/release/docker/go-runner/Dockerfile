ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/go-runner-$TARGETOS-$TARGETARCH /usr/local/bin/go-runner
ENTRYPOINT ["/usr/local/bin/go-runner"]
