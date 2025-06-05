# syntax=docker/dockerfile:1.6
FROM --platform=$BUILDPLATFORM quay.io/projectquay/golang:1.24 AS builder

ARG TARGETOS=linux
ARG TARGETARCH=amd64
ARG VERSION=dev

WORKDIR /src/go/app
COPY . .
RUN make build TARGETARCH=$TARGETARCH TARGETOS=$TARGETOS VERSION=$VERSION


FROM scratch

WORKDIR /
COPY --from=builder /src/go/app/kbot /
COPY --from=alpine:latest /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/kbot"]
