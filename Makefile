ENGINE?=docker
TAG?=latest

IMAGE_NAME:=ericornelissen/js-re-scan

NODE_MODULES=node_modules
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR:=.tmp

TOOLING:=$(TEMP_DIR)/.tooling
IMAGES_DIR:=$(TEMP_DIR)/images/$(ENGINE)

SBOM_FILE:=sbom.json
VULN_FILE:=vulns.json

.PHONY: default
default: help

.PHONY: audit audit-image audit-npm
audit: audit-image audit-npm ## Audit the project dependencies

audit-image: $(VULN_FILE) ## Audit the container image dependencies

audit-npm: ## Audit the npm dependencies
	@npm audit $(ARGS)

.PHONY: build
build: $(IMAGES_DIR)/$(TAG) ## Build the container image

.PHONY: clean
clean: ## Clean the repository
	@git clean -fx \
		$(TEMP_DIR) \
		$(NODE_MODULES) \
		$(SBOM_FILE) \
		$(VULN_FILE)
	@$(ENGINE) rmi --force \
		$(IMAGE_NAME)

.PHONY: format format-js
format: format-js ## Format the project

format-js: $(NODE_MODULES) ## Format JavaScript files
	@npx prettier \
		--write \
		--ignore-path .gitignore \
		\
		--arrow-parens always \
		--end-of-line lf \
		--trailing-comma all \
		--use-tabs \
		\
		./scripts/*.js \
		./tests/*.js

.PHONY: help
help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
		printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

.PHONY: init
init: $(NODE_MODULES) ## Initialize the project dependencies

.PHONY: license-check license-check-image license-check-npm
license-check: license-check-image license-check-npm ## Check the project dependency licenses

license-check-image: $(SBOM_FILE) ## Check container image dependency licenses
	@node scripts/check-licenses.js

license-check-npm: $(NODE_MODULES) ## Check npm dependency licenses
	@npx licensee \
		--errors-only

.PHONY: lint lint-ci lint-image lint-js lint-md lint-yml
lint: lint-ci lint-image lint-js lint-md lint-yml ## Lint the project

lint-ci: $(TOOLING) ## Lint Continuous Integration configuration files
	@actionlint

lint-image: $(TOOLING) ## Lint the Dockerfile
	@hadolint \
		Dockerfile

lint-js: $(NODE_MODULES) ## Lint JavaScript files
	@npx prettier \
		--check \
		--ignore-path .gitignore \
		\
		--arrow-parens always \
		--end-of-line lf \
		--trailing-comma all \
		--use-tabs \
		\
		./scripts/*.js \
		./tests/*.js

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

.PHONY: sbom
sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

.PHONY: test update-test-snapshots
test: build $(NODE_MODULES) ## Run the tests
	@CONTAINER_ENGINE=$(ENGINE) \
		npx ava \
		--timeout 20s \
		tests/

update-test-snapshots: build $(NODE_MODULES) ## Update the test snapsthos
	@CONTAINER_ENGINE=$(ENGINE) \
		npx ava \
		--update-snapshots \
		tests/

.PHONY: verify
verify: build license-check lint test ## Verify project is in a good state

$(SBOM_FILE): $(TOOLING) $(IMAGES_DIR)/latest
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
$(IMAGES_DIR): | $(TEMP_DIR)
	@mkdir -p $(IMAGES_DIR)
$(IMAGES_DIR)/%: .dockerignore .eslintrc.yml Dockerfile package*.json | $(IMAGES_DIR)
	@$(ENGINE) build --tag $(IMAGE_NAME):$(TAG) .
	@touch $(IMAGES_DIR)/$(TAG)
