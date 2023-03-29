IMAGE_NAME:=ericornelissen/js-re-scan

NODE_MODULES=node_modules
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR:=.tmp

TOOLING:=$(TEMP_DIR)/.tooling
DOCKERIMAGES:=$(TEMP_DIR)/dockerimages

SBOM_FILE:=sbom.json
VULN_FILE:=vulns.json

TAG?=latest

default: help

audit: audit-docker audit-npm ## Audit the project dependencies

audit-docker: $(VULN_FILE) ## Audit the Docker image dependencies

audit-npm: ## Audit the npm dependencies
	@npm audit $(ARGS)

build: $(DOCKERIMAGES)/$(TAG) ## Build the Docker image

clean: ## Clean the repository
	@git clean -fx \
		$(TEMP_DIR) \
		$(NODE_MODULES) \
		$(SBOM_FILE) \
		$(VULN_FILE)
	@docker rmi --force \
		$(IMAGE_NAME)

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
		printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: $(NODE_MODULES) ## Initialize the project dependencies

license-check: license-check-docker license-check-npm ## Check the project dependency licenses

license-check-docker: $(SBOM_FILE) ## Check Docker image dependency licenses
	@node scripts/check-licenses.js

license-check-npm: $(NODE_MODULES) ## Check npm dependency licenses
	@npx licensee \
		--errors-only

lint: lint-ci lint-docker lint-md lint-yml ## Lint the project

lint-ci: $(TOOLING) ## Lint Continuous Integration configuration files
	@actionlint

lint-docker: $(TOOLING) ## Lint the Dockerfile
	@hadolint \
		Dockerfile

lint-md: $(NODE_MODULES) ## Lint MarkDown files
	@npx markdownlint \
		--dot \
		--ignore-path .gitignore \
		--ignore tests/snapshots \
		--ignore testdata/ \
		.

lint-yml: $(TOOLING) ## Lint .yml files
	@yamllint \
		-c .yamllint.yml \
		.

sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

test: build $(NODE_MODULES) ## Run the tests
	@npx ava \
		--timeout 20s \
		tests/

update-test-snapshots: build $(NODE_MODULES) ## Update the test snapsthos
	@npx ava \
		--update-snapshots \
		tests/

verify: build license-check lint test ## Verify project is in a good state

.PHONY: default help \
	build clean init sbom verify \
	audit audit-docker audit-npm \
	license-check license-check-docker license-check-npm \
	lint lint-ci lint-docker lint-md lint-yml \
	test update-test-snapshots

$(SBOM_FILE): $(TOOLING) $(DOCKERIMAGES)/latest
	@syft $(IMAGE_NAME):latest
$(VULN_FILE): $(TOOLING) $(SBOM_FILE)
	@grype $(SBOM_FILE)

$(NODE_MODULES): .npmrc package*.json
	@npm clean-install \
		--no-audit

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TOOLING): .tool-versions | $(TEMP_DIR)
ifneq (, $(shell which asdf))
	@asdf install
else ifneq (, $(shell which rtx))
	@rtx install
endif
	@touch $(TOOLING)
$(DOCKERIMAGES): | $(TEMP_DIR)
	@mkdir $(DOCKERIMAGES)
$(DOCKERIMAGES)/%: .dockerignore .eslintrc.yml Dockerfile package*.json | $(DOCKERIMAGES)
	@docker build --tag $(IMAGE_NAME):$(TAG) .
	@touch $(DOCKERIMAGES)/$(TAG)
