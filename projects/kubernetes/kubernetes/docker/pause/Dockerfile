ARG BASE_IMAGE
FROM ${BASE_IMAGE}

ARG VERSION

RUN yum update -y
RUN yum install -y gcc glibc-static
# Use as small a context as possible so Docker doesn't read all of _output
COPY pause.c /pause.c
RUN gcc -Os -Wall -Werror -static -DVERSION=${VERSION} -o /pause /pause.c

FROM scratch

COPY --from=0 /pause /pause
ENTRYPOINT ["/pause"]
