FROM    golang:alpine AS build
LABEL   maintainer="me@codar.nl"
ARG     PKGS="git upx binutils"
ENV     GOOS=linux \
        GOARCH=amd64 \
        CGO_ENABLED=0

WORKDIR /build
COPY    ./src/ /build
RUN     set -x && \
        apk add --no-cache --upgrade ${PKGS} && \
        git clone ${REPO} && \
        cd /build/ && \
        go build -ldflags="-w -s" -o webserver main.go && \
        strip --strip-unneeded webserver && \
        upx -q --best webserver && \
        upx -t webserver && \
        rm -rf /tmp/* /var/cache/apk/*

# STAGE 2: build the container to run
FROM gcr.io/distroless/static AS run
USER nonroot:nonroot

# copy compiled app
COPY --from=build --chown=nonroot:nonroot /build/webserver /webserver

# run binary; use vector form
ENTRYPOINT ["/webserver"]
