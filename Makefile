BUILDX=docker buildx build --platform linux/amd64,linux/arm64

.PHONY: walnut all push walnut-multi create-builder delete-builder

all: create-builder walnut-multi delete-builder

push:
	docker push nopid/walnut

walnut:
	docker build -t nopid/walnut .

walnut-multi: create-builder
	$(BUILDX) -t nopid/walnut -t nopid/walnut:latest --push .

create-builder:
	docker buildx create --name kat-builder --use
	docker buildx inspect --bootstrap

delete-builder:
	docker buildx rm kat-builder
