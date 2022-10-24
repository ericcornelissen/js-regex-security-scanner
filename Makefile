IMAGE_NAME=ericornelissen/js-re-scan

GRYPE_VERSION=v0.50.2
HADOLINT_VERSION=2.9.2
SYFT_VERSION=v0.57.0

BIN_DIR=.bin
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR=.tmp

SBOM_FILE=sbom.json
VULN_FILE=vulns.json

default: help

audit: audit-docker audit-npm ## Audit the project dependencies
audit-docker: | $(VULN_FILE)
audit-npm:
	npm audit $(ARGS)

build: | $(TEMP_DIR)/dockerimage ## Build the Docker image

clean: ## Clean the repository
	@git clean -fx \
		$(BIN_DIR) \
		$(TEMP_DIR) \
		node_modules/ \
		$(SBOM_FILE) \
		$(VULN_FILE)

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
	  printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: | $(BIN_DIR)/grype $(BIN_DIR)/syft node_modules/ ## Initialize the project dependencies

lint: lint-docker lint-md ## Lint the project

lint-docker: ## Lint the Dockerfile
	@docker run -i --rm \
		--mount "type=bind,source=$(ROOT_DIR)/.hadolint.yml,target=/.config/hadolint.yaml" \
		hadolint/hadolint:$(HADOLINT_VERSION) \
		< Dockerfile

lint-md: node_modules/ ## Lint MarkDown files
	npm run markdownlint -- \
		--dot \
		--ignore-path .gitignore \
		--ignore tests/snapshots \
		--ignore testdata/ \
		.

sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

test: build node_modules/ ## Run the tests
	npm run ava -- \
		--timeout 20s \
		tests/

update-test-snapshots: build node_modules/ ## Update the test snapsthos
	npm run ava -- tests/ --update-snapshots

.PHONY: default audit audit-docker audit-npm build clean help init lint lint-docker lint-md sbom test update-test-snapshots

$(SBOM_FILE): $(BIN_DIR)/syft $(TEMP_DIR)/dockerimage
	./$(BIN_DIR)/syft $(IMAGE_NAME):latest
$(VULN_FILE): $(BIN_DIR)/grype $(SBOM_FILE)
	./$(BIN_DIR)/grype $(SBOM_FILE)

$(BIN_DIR):
	@mkdir $(BIN_DIR)
$(BIN_DIR)/syft:
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(SYFT_VERSION)
$(BIN_DIR)/grype:
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(GRYPE_VERSION)

node_modules/: .npmrc package*.json
	npm install

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TEMP_DIR)/dockerimage: $(TEMP_DIR) .dockerignore .eslintrc.yml Dockerfile package*.json
	docker build --tag $(IMAGE_NAME) .
	@touch $(TEMP_DIR)/dockerimage
