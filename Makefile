.PHONY: sources build install clean

SOURCES := sources.tar
VIRTUALENV ?= /usr/bin/virtualenv
VENV_DIR := .venv
VENV_ACTIVATE := source $(VENV_DIR)/bin/activate
PIP_DEPS_DIR := pip-deps
PIP_DOWNLOAD := pip install --download $(PIP_DEPS_DIR)
PWD := $(shell pwd)
PIP_INSTALL_FROM_CACHE := pip install --no-index --find-links file://$(PWD)/$(PIP_DEPS_DIR)
WEBAPP_DIR := etc/status

# Create source archive including zuul and pip dependencies
sources:
	mkdir -p $(PIP_DEPS_DIR)
	git archive --format=tar HEAD^{tree} > $(SOURCES)
	$(VIRTUALENV) $(VENV_DIR)
	$(VENV_ACTIVATE) && $(PIP_DOWNLOAD) pip
	$(VENV_ACTIVATE) && $(PIP_INSTALL_FROM_CACHE) --upgrade pip # fails with old pip
	$(VENV_ACTIVATE) && $(PIP_DOWNLOAD) --requirement requirements.txt
	./etc/status/fetch-dependencies.sh # web assets fetch
	tar rvf $(SOURCES) $(PIP_DEPS_DIR) $(WEBAPP_DIR)

# Build zuul bundle from zuul and it's dependencies
build:
	$(VIRTUALENV) $(VENV_DIR)
	$(VENV_ACTIVATE) && $(PIP_INSTALL_FROM_CACHE) --upgrade pip # fails with old pip
	$(VENV_ACTIVATE) && $(PIP_INSTALL_FROM_CACHE) --requirement requirements.txt
	$(VENV_ACTIVATE) && python setup.py install
	rm -f $(VENV_DIR)/pip-selfcheck.json
	$(VIRTUALENV) --relocatable $(VENV_DIR)

# Install zuul bundle into DESTDIR
install:
	install -d -m 755 '$(DESTDIR)'
	cp -a $(VENV_DIR)/* '$(DESTDIR)'
	cp -a $(WEBAPP_DIR) '$(DESTDIR)'

clean:
	rm -rf $(SOURCES) $(PIP_DEPS_DIR) $(VENV_DIR)

# Docker targets

DOCKER_IMAGE_TAG = zuul-test
WORKDIR = $(shell pwd)

docker-build:
	docker build -t $(DOCKER_IMAGE_TAG) -f docker/Dockerfile .

docker-run:
	docker run --rm --tty --interactive \
		--volume $(shell pwd):/zuul \
		--env LOCAL_USER_ID=$(shell id -u) $(DOCKER_IMAGE_TAG)
