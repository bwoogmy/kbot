APP := $(shell basename $(shell git remote get-url origin))
VERSION := $(shell git describe --tags --abbrev=0)-$(shell git rev-parse --short HEAD)
TARGETOS := linux
REGISTRY := bwoogmy
TARGETARCH := amd64

format:
	gofmt -s -w ./

lint:
	golint

test:
	go test -v

get:
	go get


build: format get
	CGO_ENABLED=0 GOOS=$(TARGETOS) GOARCH=$(TARGETARCH) go build -v -o kbot -ldflags "-X=github.com/bwoogmy/kbot/cmd.appVersion=$(VERSION) -w -s"

image:
	docker build . -t $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)

push:
	docker push $(REGISTRY)/$(APP):$(VERSION)-$(TARGETARCH)

clean:
	rm -rf kbot