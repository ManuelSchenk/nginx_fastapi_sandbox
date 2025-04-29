REGISTRY=localhost:5000
IMAGE=fastapi
TAG=latest

.PHONY: all init registry wait build push attach_nginx # explicitly tell Make they're not associated with files


# Running "make" will execute the "all" target.
all: registry wait build push attach_nginx
# inital task to start the registry and build + push the image
init: registry wait build push


# Start a temporary registry service (the profile is used to avoid duplication of the registry)
registry:
	@echo "Starting local temporary docker registry service..."
	docker compose -p myswarm -f docker-compose_registry.yaml up -d

# Wait for the registry to be ready by polling its API
wait:
	@echo "Waiting for registry to be ready..." 
# curl http://localhost:5000/v2/_catalog (but you have to wait till registry is up)
	@until curl -s "http://$(REGISTRY)/v2/_catalog" > /dev/null; do \
		sleep 1; \
	done
	@echo "Registry is up!"

# build an image from the Dockerfile
build:
	@echo "Building FastAPI image…"
	docker build -t $(IMAGE):$(TAG) .

# Push it from your images into the registry
push: 
	@echo "Tagging & pushing image into local registry…"
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
	docker push $(REGISTRY)/$(IMAGE):$(TAG)


attach_nginx:
	@echo "Starting NGINX reverse proxy with SSL Termination and basic AUTH..."
	docker compose -p myswarm -f docker-compose_nginx.yaml up -d