REGISTRY=localhost:5000
IMAGE=fastapi
TAG=latest

.PHONY: all init network registry wait build push stack_deploy  # explicitly tell Make they're not associated with files

# Running "make" will execute the "all" target.
all: init stack_deploy
# this is needed to start and initalize the registry before starting the swarm
init: network registry wait build push

# create a overlay network for the swarm
network:
	@echo "Creating a overlay network for the swarm (if not allready running)..."
	@docker network inspect swarm-net >/dev/null 2>&1 || docker network create --driver=overlay --attachable swarm-net

# Start a temporary registry service (the profile is used to avoid duplication of the registry)
registry:
	@echo "Starting local temporary docker registry service..."
	docker compose -p myswarm -f docker-compose_init.yaml up -d

# Wait for the registry to be ready by polling its API
wait:
	@echo "Waiting for registry to be ready..." 
# curl http://localhost:5000/v2/_catalog
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
stack_deploy:
	@echo "Starting the fastapi swarm with the nginx entry point and registry..."
	docker stack deploy -c docker-compose.yaml myswarm --detach=false
# detach=false: wait and stream output until the deployment is complete
