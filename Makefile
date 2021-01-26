TAG ?= latest
LOCATION := $(shell nomad exec $$(nomad status nginx | grep running | grep -v Status | awk '{print $$1}') curl -s ifconfig.co)
REPO ?= leonowski/sample-service

.PHONY: build
build:
	docker build -t $(REPO):$(TAG) .

.PHONY: push
push: build
	docker push $(REPO):$(TAG)

.PHONY: nomad.job
nomad.job:
	export TAG=$(TAG) REPO=$(REPO) && \
	envsubst < "sample-service-nomad-job.hcl.template" > "nomad.job"

.PHONY: clean
clean:
	@rm nomad.job

.PHONY: build-and-deploy
build-and-deploy: push nomad.job
	nomad run -verbose nomad.job
	make clean
	sleep 30
	curl -s "http://${LOCATION}"
	echo "Service is now available at http://${LOCATION}"

.PHONY: deploy-tag-only
deploy-tag-only: nomad.job
	nomad run -verbose nomad.job
	make clean
	sleep 30
	@curl -s "http://${LOCATION}"
	@echo "Service is now available at http://${LOCATION}"
