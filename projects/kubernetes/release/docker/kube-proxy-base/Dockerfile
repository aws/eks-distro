ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

RUN yum update -y
# Installing dependencies listed in upstream here: https://github.com/kubernetes/release/blob/master/images/build/debian-iptables/buster/Dockerfile
# Since we rely on AL2, necessary files from netbase are already included, and we aren't making the same optimizations as of now.
RUN yum install -y \
    ebtables \
    iptables \
    conntrack \
    ipset \
    kmod

COPY _output/go-runner-$TARGETOS-$TARGETARCH /usr/local/bin/go-runner
COPY _output/iptables-wrapper /usr/sbin/iptables-wrapper

RUN update-alternatives \
	--install /usr/sbin/iptables iptables /usr/sbin/iptables-wrapper 100 \
	--slave /usr/sbin/iptables-restore iptables-restore /usr/sbin/iptables-wrapper \
	--slave /usr/sbin/iptables-save iptables-save /usr/sbin/iptables-wrapper
RUN update-alternatives \
	--install /usr/sbin/ip6tables ip6tables /usr/sbin/iptables-wrapper 100 \
	--slave /usr/sbin/ip6tables-restore ip6tables-restore /usr/sbin/iptables-wrapper \
	--slave /usr/sbin/ip6tables-save ip6tables-save /usr/sbin/iptables-wrapper
ENTRYPOINT ["/usr/local/bin/go-runner"]
