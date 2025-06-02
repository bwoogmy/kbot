FROM quay.io/projectquay/golang:1.22 as builder

WORKDIR /go/src/app
COPY . .
ARG TARGETARCH
RUN make build TARGETARCH=$TARGETARCH

FROM alpine:latest

WORKDIR /
COPY --from=builder /go/src/app/kbot .
ENTRYPOINT ["./kbot", "start"]
