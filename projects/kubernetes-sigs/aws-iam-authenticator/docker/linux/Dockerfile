ARG BASE_IMAGE
FROM $BASE_IMAGE

ARG TARGETARCH
ARG TARGETOS

RUN yum install -y shadow-utils && \
    adduser \
    --system \
    --no-create-home \
    --uid 10000 \
    aws-iam-authenticator && \
    yum update -y
COPY _output/bin/aws-iam-authenticator/$TARGETOS-$TARGETARCH/aws-iam-authenticator /
RUN chown aws-iam-authenticator /aws-iam-authenticator
USER aws-iam-authenticator
ENTRYPOINT ["/aws-iam-authenticator"]
