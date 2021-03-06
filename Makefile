#######################################################
## Automate container recreation for dengue database ##
#######################################################

include .env

# Docker specific
ENV_FILE := .env
COMPOSE_FILE := docker/docker-compose.yml
NETWORK := infodengue
DOCKER := PYTHON_VERSION=$(PYTHON_VERSION) docker-compose -p $(NETWORK) -f $(COMPOSE_FILE) --env-file $(PWD)/$(ENV_FILE)
DOCKER_UP := $(DOCKER) up
DOCKER_RUN := $(DOCKER) run --rm
DOCKER_BUILD := $(DOCKER) build
DOCKER_STOP := $(DOCKER) rm --force --stop
DOCKER_EXEC := $(DOCKER) exec
DOCKER_REMOVE := $(DOCKER) down --remove-orphans
SERVICES := dengue_db


# Download database to test in CI
download_demodb:
	bash ci/_download_dbdemo.sh

# Download the database to the container
download_dev_dumps:
	bash docker/download_dumps.sh

# Configure database in the container
build:
	$(DOCKER_BUILD)

deploy:
	$(DOCKER_UP) -d

exec: deploy
	$(DOCKER_EXEC) $(SERVICES) bash

recreate_container:
	make remove_image_dengue_db
	# make download_dev_dumps
	make download_demodb
	make deploy

remove_image_dengue_db:
	$(DOCKER_STOP)
	$(DOCKER_REMOVE)


clean:
	@find ./ -name '*.pyc' -exec rm -f {} \;
	@find ./ -name '*.pyo' -exec rm -f {} \;
	@find ./ -name '*~' -exec rm -f {} \;
	rm -rf .cache
	rm -rf build
	rm -rf dist
	rm -rf *.egg-info
