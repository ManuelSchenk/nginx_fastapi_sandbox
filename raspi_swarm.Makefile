REGISTRY=localhost:5000
IMAGE=fastapi
TAG=latest

.PHONY: all init registry wait build_arm push_arm start_swarm attach_nginx # explicitly tell Make they're not associated with files

# Running "make" will execute the "all" target.
all: init start_swarm attach_nginx
# this is needed to start and initalize the registry before starting the swarm
init: registry wait build_arm push_arm

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
build_arm:
	@echo "🔨 Building fastapi image for ARM (linux/arm/v7)..."
	docker buildx build \
		--platform linux/arm/v7 \
		-t localhost:5000/fastapi_arm:latest \
		--load .
# --load: Load the built image into the docker daemon

# Push it from your images into the registry
push_arm:
	@echo "📤 Pushing fastapi_arm:latest to local registry..."
	docker push localhost:5000/fastapi_arm:latest

# Start the app service from the registry image
start_swarm:
	@echo "Starting the fastapi swarm with the nginx entry point and registry..."
	docker stack deploy -c docker-compose_swarm.yaml myswarm --detach=false
# detach=false: means wait and stream output until the deployment is complete

attach_nginx:
	@echo "Starting NGINX reverse proxy with SSL Termination and basic AUTH..."
	docker compose -p myswarm -f docker-compose_nginx.yaml up -d