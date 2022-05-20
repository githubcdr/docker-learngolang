FROM    golang:alpine AS build
LABEL   maintainer="me@codar.nl"
ARG     PKGS="git binutils"
ENV     GOOS=linux \
        CGO_ENABLED=0

WORKDIR /build
COPY    ./src/ /build
RUN     set -x && \
        apk add --no-cache --upgrade ${PKGS} && \
        cd /build/ && \
        go build -ldflags="-w -s" -o webserver main.go

FROM    cloudtogo4edge/upx:3.96 AS compressor
COPY    --from=build /build/webserver /webserver
RUN     set -x && \
        upx /webserver

# STAGE 2: build the container to run
FROM    gcr.io/distroless/static AS run
USER    nonroot:nonroot

# copy compiled app
COPY    --from=compressor --chown=nonroot:nonroot /webserver /webserver

# run binary; use vector form
ENTRYPOINT ["/webserver"]
