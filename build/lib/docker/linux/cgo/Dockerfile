# syntax=docker/dockerfile:experimental

# To around the lack of a overlayfs in presubmit jobs since they run on fargate
# we have to keep the layers to a minimum.
# All the source files and librarys are gatered into once folder on the base and then
# copied in the builder
ARG BUILDER_IMAGE
FROM ${BUILDER_IMAGE} as builder

ARG TARGETARCH
ARG TARGETOS
ARG COMPONENT
ARG CGO_TARGET

ARG GOPROXY
ENV GOPROXY=$GOPROXY

COPY ./eks-anywhere-build-tooling /eks-anywhere-build-tooling
COPY ./$TARGETOS-$TARGETARCH /eks-anywhere-build-tooling/projects/$COMPONENT/_output/source/$TARGETOS-$TARGETARCH

WORKDIR /eks-anywhere-build-tooling
RUN make -C projects/$COMPONENT $CGO_TARGET BINARY_PLATFORMS=$TARGETOS/$TARGETARCH

FROM scratch

ARG TARGETARCH
ARG TARGETOS
ARG COMPONENT
ARG CGO_TARGET

COPY --from=builder /eks-anywhere-build-tooling/projects/$COMPONENT/$CGO_TARGET .
