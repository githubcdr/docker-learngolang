# builder
FROM    cgr.dev/chainguard/go:latest-dev AS builder
WORKDIR /build
COPY    ./src ./
RUN     CGO_ENABLED=0 go build -v -ldflags="-w -s" -o main .

# compressor
FROM    alpine:3.24 AS compressor
RUN     apk add --no-cache upx
COPY    --from=builder /build/main /main
RUN     set -x && \
  upx -9 /main

# container
FROM    cgr.dev/chainguard/static:latest
USER    nonroot:nonroot
COPY    --from=compressor --chown=nonroot:nonroot /main /

EXPOSE  8080
# run binary; use vector form
ENTRYPOINT ["/main"]

