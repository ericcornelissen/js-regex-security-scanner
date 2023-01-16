IMAGE_NAME:=ericornelissen/js-re-scan

HADOLINT_VERSION:=v2.12.0

BIN_DIR:=.bin
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR:=.tmp

NODE_MODULES=node_modules/

SBOM_FILE:=sbom.json
VULN_FILE:=vulns.json

TAG?=latest

default: help

audit: audit-docker audit-npm ## Audit the project dependencies

audit-docker: $(VULN_FILE) ## Audit the Docker image dependencies

audit-npm: ## Audit the npm dependencies
	@npm audit $(ARGS)

build: $(TEMP_DIR)/dockerimages/$(TAG) ## Build the Docker image

clean: ## Clean the repository
	@git clean -fx \
		$(BIN_DIR) \
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

lint-ci: $(TEMP_DIR)/.asdf ## Lint Continuous Integration configuration files
	@actionlint

lint-docker: ## Lint the Dockerfile
	@docker run -i --rm \
		--mount "type=bind,source=$(ROOT_DIR)/.hadolint.yml,target=/.config/hadolint.yaml" \
		hadolint/hadolint:$(HADOLINT_VERSION) \
		< Dockerfile

lint-md: $(NODE_MODULES) ## Lint MarkDown files
	@npx markdownlint \
		--dot \
		--ignore-path .gitignore \
		--ignore tests/snapshots \
		--ignore testdata/ \
		.

lint-yml: $(TEMP_DIR)/.asdf ## Lint .yml files
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

$(SBOM_FILE): $(TEMP_DIR)/.asdf $(TEMP_DIR)/dockerimages/latest
	@syft $(IMAGE_NAME):latest
$(VULN_FILE): $(TEMP_DIR)/.asdf $(SBOM_FILE)
	@grype $(SBOM_FILE)

$(BIN_DIR):
	@mkdir $(BIN_DIR)

$(NODE_MODULES): .npmrc package*.json
	@npm clean-install \
		--no-audit

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TEMP_DIR)/.asdf: .tool-versions | $(TEMP_DIR)
ifneq (, $(shell which asdf))
	@asdf install
	@touch $(TEMP_DIR)/.asdf
endif
$(TEMP_DIR)/dockerimages: | $(TEMP_DIR)
	@mkdir $(TEMP_DIR)/dockerimages
$(TEMP_DIR)/dockerimages/%: .dockerignore .eslintrc.yml Dockerfile package*.json | $(TEMP_DIR)/dockerimages
	@docker build --tag $(IMAGE_NAME):$(TAG) .
	@touch $(TEMP_DIR)/dockerimages/$(TAG)
