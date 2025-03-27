REGISTRY=localhost:5000
IMAGE=fastapi
TAG=latest

.PHONY: all init registry wait build_n_push start_swarm attach_nginx # explicitly tell Make they're not associated with files

# Running "make" will execute the "all" target.
all: init start_swarm attach_nginx
# this is needed to start and initalize the registry before starting the swarm
init: registry wait build_n_push

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

init_buildx:
	@echo "Initializing buildx to be able to build for ARM (Raspi)..."
	docker buildx use default
	docker run --rm --privileged tonistiigi/binfmt --install all

# Build your app image for ARM (Raspi) and x64
build_n_push:
	@echo "Building the fastapi service image for ARM and x64 and Push it to the regisry..."
	docker buildx create --use
# docker buildx build --platform linux/amd64,linux/arm/v7 -t localhost:5000/fastapi:latest --push .
	docker buildx build --platform linux/arm/v7 -t localhost:5000/fastapi_arm:latest --push .
# switch back to default builder from docker (can check with `docker buildx ls`)
	docker buildx use default

# Start the app service from the registry image
start_swarm:
	@echo "Starting the fastapi swarm with the nginx entry point and registry..."
	docker stack deploy -c docker-compose_swarm.yaml myswarm --detach=false
# detach=false: means wait and stream output until the deployment is complete

attach_nginx:
	@echo "Starting NGINX reverse proxy with SSL Termination and basic AUTH..."
	docker compose -p myswarm -f docker-compose_nginx.yaml up -d