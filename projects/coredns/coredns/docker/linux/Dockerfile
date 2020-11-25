ARG BASE_IMAGE
FROM $BASE_IMAGE

RUN yum update -y
RUN yum install -y ca-certificates && update-ca-trust

FROM scratch

ARG TARGETARCH
ARG TARGETOS

COPY --from=0 /etc/ssl/certs /etc/ssl/certs
COPY _output/bin/coredns/$TARGETOS-$TARGETARCH/coredns /coredns

EXPOSE 53 53/udp
ENTRYPOINT ["/coredns"]
