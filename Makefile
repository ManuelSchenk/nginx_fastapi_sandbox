REGISTRY=localhost:5000
IMAGE=fastapi
TAG=latest

.PHONY: all network registry wait build push start_myswarm  # explicitly tell Make they're not associated with files

# Running "make" will execute the "all" target.
all: network registry wait build push start_myswarm

# create a overlay network for the swarm
network:
	@echo "Creating a overlay network for the swarm..."
	docker network create --driver=overlay --attachable swarm-net

# Start a temporary registry service (the profile is used to avoid duplication of the registry)
registry:
	@echo "Starting local temporary docker registry service..."
	docker compose -f docker-compose_init.yaml up -d

# Wait for the registry to be ready by polling its API
wait:
	@echo "Waiting for registry to be ready..."
	@until curl -s "http://$(REGISTRY)/v2/_catalog" > /dev/null; do \
		sleep 1; \
	done
	@echo "Registry is up!"

# Build your app image
build:
	@echo "Building the fastapi service image..."
	docker build -t $(IMAGE):$(TAG) .

# Tag and push the built image to the local registry
push:
	@echo "Tagging and pushing the image..."
	docker tag $(IMAGE):$(TAG) $(REGISTRY)/$(IMAGE):$(TAG)
# docker tag fastapi:latest registry/fastapi:latest
	docker push $(REGISTRY)/$(IMAGE):$(TAG)
# docker push localhost:5000/fastapi:latest

# Stop the temporary registry container after pushing the image
# stop_registry:
# 	@echo "Stopping the temporary local registry service..."
# 	docker compose stop registry

# Start the app service from the registry image
start_myswarm:
	@echo "Starting the fastapi swarm with the nginx entry point and registry..."
	docker stack deploy -c docker-compose.yaml myswarm --detach=false
# it will not start the registry again because no profile is used 
