APP ?= kbot
REGISTRY ?= ghcr.io/bwoogmy
REPO := $(REGISTRY)/$(APP)
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null || echo "latest")-$(shell git rev-parse --short HEAD)
TARGETARCH ?= amd64
TARGETOS ?= linux

IMAGE_TAG := $(REPO):$(VERSION)-$(TARGETOS)-$(TARGETARCH)

.PHONY: format lint test get build arm linux macos windows image push clean

format:
	gofmt -s -w ./

lint:
	golint ./...

test:
	go test -v ./...

get:
	go get ./...

arm:
	$(MAKE) build TARGETARCH=arm64 TARGETOS=linux

macos:
	$(MAKE) build TARGETARCH=arm64 TARGETOS=darwin

windows:
	$(MAKE) build TARGETARCH=amd64 TARGETOS=windows


linux:
	$(MAKE) build TARGETARCH=amd64 TARGETOS=linux


build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-w -s -X=github.com/bwoogmy/kbot/cmd.appVersion=$(VERSION)"

image:
	docker build --build-arg TARGETARCH=$(TARGETARCH) --build-arg TARGETOS=$(TARGETOS) --build-arg VERSION=$(VERSION) -t $(IMAGE_TAG) .

push:
	docker push $(IMAGE_TAG)

clean:
	rm -rf kbot
	-docker rmi $(IMAGE_TAG) || true
