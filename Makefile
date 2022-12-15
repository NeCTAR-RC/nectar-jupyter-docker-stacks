# Use bash for inline if-statements in arch_patch target
SHELL:=bash
OWNER?=registry.rc.nectar.org.au/nectar
TAG?=hub-3.0.0

# Need to list the images in build dependency order
# All of the images
ALL_IMAGES:= \
	minimal-notebook \
	scipy-notebook \
	datascience-notebook \
	r-notebook

# Enable BuildKit for Docker build
export DOCKER_BUILDKIT:=1


# https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
help:
	@echo "nectar-jupyter-docker-stacks"
	@echo "============================"
	@echo "Replace % with a stack directory name (e.g., make build/minimal-notebook)"
	@echo
	@grep -E '^[a-zA-Z0-9_%/-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


build/%: DOCKER_BUILD_ARGS?=
build/%: ## build the latest image for a stack using the system's architecture
	docker build $(DOCKER_BUILD_ARGS) --rm --force-rm -t $(OWNER)/jupyter-$(notdir $@):$(TAG) . --build-arg IMAGE="jupyter/$(notdir $@):$(TAG)"
	@docker tag $(OWNER)/jupyter-$(notdir $@):$(TAG) $(OWNER)/jupyter-$(notdir $@):$$(docker images --filter=reference=$(OWNER)/jupyter-$(notdir $@):$(TAG) --format='{{index .ID}}')
	@echo -n "Built image size: "
	@docker images $(OWNER)/jupyter-$(notdir $@):$(TAG) --format "{{.Size}}"
build-all: $(foreach I, $(ALL_IMAGES), build/$(I)) ## build all stacks


cont-clean-all: cont-stop-all cont-rm-all ## clean all containers (stop + rm)
cont-stop-all: ## stop all containers
	@echo "Stopping all containers ..."
	-docker stop -t0 $(shell docker ps -a -q) 2> /dev/null
cont-rm-all: ## remove all containers
	@echo "Removing all containers ..."
	-docker rm --force $(shell docker ps -a -q) 2> /dev/null


img-clean: img-rm-dang img-rm ## clean dangling and jupyter images
img-list: ## list jupyter images
	@echo "Listing $(OWNER) images ..."
	@docker images "$(OWNER)/*" | awk '/$(TAG)/ {print $$1 ":" $$3}'
img-rm: ## remove jupyter images
	@echo "Removing $(OWNER) images ..."
	-docker rmi --force $(shell docker images --quiet "$(OWNER)/*") 2> /dev/null
img-rm-dang: ## remove dangling images (tagged None)
	@echo "Removing dangling images ..."
	-docker rmi --force $(shell docker images -f "dangling=true" -q) 2> /dev/null


pull/%: ## pull a jupyter image
	docker pull $(OWNER)/jupyter-$(notdir $@)
pull-all: $(foreach I, $(ALL_IMAGES), pull/$(I)) ## pull all images


push/%: ## push all tags for a jupyter image
	docker push --all-tags $(OWNER)/jupyter-$(notdir $@)
push-all: $(foreach I, $(ALL_IMAGES), push/$(I)) ## push all tagged images


run-shell/%: ## run a bash in interactive mode in a stack
	docker run -it --rm $(OWNER)/jupyter-$(notdir $@) $(SHELL)

run-sudo-shell/%: ## run a bash in interactive mode as root in a stack
	docker run -it --rm --user root $(OWNER)/jupyter-$(notdir $@) $(SHELL)
