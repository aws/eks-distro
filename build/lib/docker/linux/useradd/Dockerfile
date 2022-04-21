ARG BASE_IMAGE 
ARG BUILDER_IMAGE

FROM $BASE_IMAGE as base

FROM $BUILDER_IMAGE as builder

RUN yum install -y shadow-utils

ARG IMAGE_USERADD_USER_NAME
ARG IMAGE_USERADD_USER_ID

COPY --from=base /etc/group /etc/group
COPY --from=base /etc/passwd /etc/passwd
RUN groupadd -r ${IMAGE_USERADD_USER_NAME} && \
    useradd -r -g ${IMAGE_USERADD_USER_NAME} -u ${IMAGE_USERADD_USER_ID} ${IMAGE_USERADD_USER_NAME}

FROM scratch
COPY --from=builder /etc/group /etc/passwd ./etc/
