FROM quay.io/projectquay/golang:1.22 AS builder

WORKDIR /go/src/app
COPY . .

RUN make build

FROM scratch
WORKDIR /
COPY --from=builder /go/src/app/kbot .
COPY --from=certs /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["./kbot"]