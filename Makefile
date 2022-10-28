IMAGE_NAME:=ericornelissen/js-re-scan

GRYPE_VERSION:=v0.51.0
HADOLINT_VERSION:=2.9.2
SYFT_VERSION:=v0.59.0

BIN_DIR:=.bin
LICENSED_CACHE:=$(TEMP_DIR)/licensed
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR:=.tmp

GRYPE=$(BIN_DIR)/grype
LICENSED=$(BIN_DIR)/licensed
NODE_MODULES=node_modules/
SYFT=$(BIN_DIR)/syft

SBOM_FILE:=sbom.json
VULN_FILE:=vulns.json

default: help

audit: audit-docker audit-npm ## Audit the project dependencies
audit-docker: $(VULN_FILE) ## Audit the Docker image dependencies
audit-npm: ## Audit the npm dependencies
	@npm audit $(ARGS)

build: $(TEMP_DIR)/dockerimage ## Build the Docker image

clean: ## Clean the repository
	@git clean -fx \
		$(BIN_DIR) \
		$(TEMP_DIR) \
		$(NODE_MODULES) \
		$(SBOM_FILE) \
		$(VULN_FILE) \
		NOTICE-npm

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
	  printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: $(LICENSED) $(GRYPE) $(SYFT) $(NODE_MODULES) ## Initialize the project dependencies

license-check-npm: $(LICENSED_CACHE) ## Check npm dependency licenses
	@./$(LICENSED) status

lint: lint-docker lint-md ## Lint the project

lint-docker: ## Lint the Dockerfile
	@docker run -i --rm \
		--mount "type=bind,source=$(ROOT_DIR)/.hadolint.yml,target=/.config/hadolint.yaml" \
		hadolint/hadolint:$(HADOLINT_VERSION) \
		< Dockerfile

lint-md: $(NODE_MODULES) ## Lint MarkDown files
	@npm run markdownlint -- \
		--dot \
		--ignore-path .gitignore \
		--ignore tests/snapshots \
		--ignore testdata/ \
		.

notice-npm: $(LICENSED_CACHE) ## Create NOTICE for npm dependencies
	@./$(LICENSED) notice
	@mv $(TEMP_DIR)/licensed/NOTICE NOTICE-npm

sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

test: build $(NODE_MODULES) ## Run the tests
	@npm run ava -- \
		--timeout 20s \
		tests/

update-test-snapshots: build $(NODE_MODULES) ## Update the test snapsthos
	@npm run ava -- \
		--update-snapshots \
		tests/

.PHONY: default audit audit-docker audit-npm build clean help init license-check-npm lint lint-docker lint-md notice-npm sbom test update-test-snapshots

$(SBOM_FILE): $(SYFT) $(TEMP_DIR)/dockerimage
	@./$(SYFT) $(IMAGE_NAME):latest
$(VULN_FILE): $(GRYPE) $(SBOM_FILE)
	@./$(GRYPE) $(SBOM_FILE)

$(BIN_DIR):
	@mkdir $(BIN_DIR)
$(SYFT):
	@curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(SYFT_VERSION)
$(GRYPE):
	@curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(GRYPE_VERSION)
$(LICENSED):
	@curl -sSL https://github.com/github/licensed/releases/download/3.7.3/licensed-3.7.3-linux-x64.tar.gz > \
		$(TEMP_DIR)/licensed.tar.gz
	@tar -xzf $(TEMP_DIR)/licensed.tar.gz --directory $(TEMP_DIR)
	@rm -rf $(TEMP_DIR)/meta/ $(TEMP_DIR)/licensed.tar.gz
	@mv $(TEMP_DIR)/licensed $(LICENSED)

$(NODE_MODULES): .npmrc package*.json
	@npm install

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TEMP_DIR)/dockerimage: $(TEMP_DIR) .dockerignore .eslintrc.yml Dockerfile package*.json
	@docker build --tag $(IMAGE_NAME) .
	@touch $(TEMP_DIR)/dockerimage
$(LICENSED_CACHE): $(LICENSED) $(NODE_MODULES) $(TEMP_DIR)
	@./$(LICENSED) cache
