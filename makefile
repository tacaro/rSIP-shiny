# constants
registry?=tacaro
repo?=rsip-shiny
version?=latest

# build docker
build:
	@echo "[INFO] building app docker image"
	docker build -f Dockerfile -t $(registry)/$(repo):$(version) . --build-arg app=.

# rebuild just the github packages for app (useful for pgk development)
# note that if github packages introduce new dependencies, have to run full-rebuild-%
rebuild:
	@echo "[INFO] rebuilding app docker image with forced rebuild of github packages (but NOT their dependencies)"
	docker build -f Dockerfile -t $(registry)/$(repo):$(version) . --build-arg app=. --build-arg refresh=$(shell date +%Y%m%d-%H%M%S)

# rebuild fully from sratch
full-rebuild:
	@echo "[INFO] rebuilding app docker image including all dependencies (without cache - this might take a while)"
	docker build -f Dockerfile -t $(registry)/$(repo):$(version) . --build-arg app=. --no-cache=true

# starts browser and runs the app from the docker image locally
# always test an app this way before deploying!
run:
	@echo "[INFO] starting browser at http://localhost:4000"
	@open http://localhost:4000
	@echo "[INFO] starting app from docker image"
	@docker run -p 4000:3838 $(registry)/$(repo):$(version)

# push image for app % to the repository
push:
	@echo "[INFO] pushing app docker image to registry"
	@docker push $(registry)/$(repo):$(version)