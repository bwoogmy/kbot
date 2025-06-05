FROM quay.io/projectquay/golang:1.22 AS builder

WORKDIR /go/src/app
COPY . .
ARG TARGETARCH
ENV CGO_ENABLED=0
ENV GOOS=linux
RUN make build TARGETARCH=$TARGETARCH TARGETOS=linux CGO_ENABLED=0

FROM alpine:latest

WORKDIR /
COPY --from=builder /go/src/app/kbot .
ENTRYPOINT ["./kbot", "start"]