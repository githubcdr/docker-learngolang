# builder
FROM    golang:alpine AS build
LABEL   maintainer="me@codar.nl"
ARG	SOURCE="./src"
ENV     GOOS=linux \
        CGO_ENABLED=0 \
	GO111MODULE=on

WORKDIR /build
COPY    ${SOURCE} /build
RUN     set -x && \
        go build -v -ldflags="-w -s" -o main .

# compressor
FROM    cloudtogo4edge/upx:3.96 AS compressor
COPY    --from=build /build/main /main
RUN     set -x && \
        upx -9 /main

# container
FROM    gcr.io/distroless/static AS run
USER    nonroot:nonroot
COPY    --from=compressor --chown=nonroot:nonroot /main /

EXPOSE	8080
# run binary; use vector form
ENTRYPOINT ["/main"]

