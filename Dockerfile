FROM golang:1.17.1-bullseye AS build

ARG SKOPEO_VERSION=v1.4.1
RUN \
    apt-get update -y && apt-get install -y libglib2.0-dev libgpgme-dev libassuan-dev libbtrfs-dev libdevmapper-dev pkg-config


ENV EXTRA_LDFLAGS="-extldflags \"-static\""
RUN \
    git clone --branch ${SKOPEO_VERSION} --depth 1 https://github.com/containers/skopeo $GOPATH/src/github.com/containers/skopeo && \
    cd $GOPATH/src/github.com/containers/skopeo && \
    make bin/skopeo DISABLE_CGO=1 && \
    mkdir -p /etc/containers && \
    cp default-policy.json /etc/containers/policy.json && \
    cp bin/skopeo /bin/skopeo && \
    /bin/skopeo --help

FROM debian:bullseye

COPY --from=build /bin/skopeo /bin/skopeo
COPY --from=build /etc/containers /etc/containers

RUN \
    apt update -yqq && apt install ca-certificates curl jq -y