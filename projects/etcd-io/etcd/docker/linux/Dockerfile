ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

COPY _output/bin/etcd/$TARGETOS-$TARGETARCH/etcd /usr/local/bin/
COPY _output/bin/etcd/$TARGETOS-$TARGETARCH/etcdctl /usr/local/bin/
VOLUME /var/etcd/
VOLUME /var/lib/etcd/

EXPOSE 2379 2380

# Define default command.
CMD ["/usr/local/bin/etcd"]
