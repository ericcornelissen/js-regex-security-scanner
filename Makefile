IMAGE_NAME:=ericornelissen/js-re-scan

GRYPE_VERSION:=v0.54.0
HADOLINT_VERSION:=sha256:9259e253a4e299b50c92006149dd3a171c7ea3c5bd36f060022b5d2c1ff0fbbe # tag=2.12.0
SYFT_VERSION:=v0.63.0

BIN_DIR:=.bin
ROOT_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
TEMP_DIR:=.tmp

GRYPE=$(BIN_DIR)/grype
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
		$(VULN_FILE)

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
		printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: $(GRYPE) $(SYFT) $(NODE_MODULES) ## Initialize the project dependencies

license-check: license-check-docker license-check-npm ## Check the project dependency licenses

license-check-docker: $(SBOM_FILE) ## Check Docker image dependency licenses
	@node scripts/check-licenses.js

license-check-npm: $(NODE_MODULES) ## Check npm dependency licenses
	@npm run licensee -- \
		--errors-only

lint: lint-ci lint-docker lint-md lint-yml ## Lint the project

lint-ci: ## Lint Continuous Integration configuration files
	@actionlint

lint-docker: ## Lint the Dockerfile
	@docker run -i --rm \
		--mount "type=bind,source=$(ROOT_DIR)/.hadolint.yml,target=/.config/hadolint.yaml" \
		hadolint/hadolint@$(HADOLINT_VERSION) \
		< Dockerfile

lint-md: $(NODE_MODULES) ## Lint MarkDown files
	@npm run markdownlint -- \
		--dot \
		--ignore-path .gitignore \
		--ignore tests/snapshots \
		--ignore testdata/ \
		.

lint-yml: ## Lint .yml files
	@yamllint \
		-c .yamllint.yml \
		.

sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

test: build $(NODE_MODULES) ## Run the tests
	@npm run ava -- \
		--timeout 20s \
		tests/

update-test-snapshots: build $(NODE_MODULES) ## Update the test snapsthos
	@npm run ava -- \
		--update-snapshots \
		tests/

.PHONY: default audit audit-docker audit-npm build clean help init license-check license-check-docker license-check-npm lint lint-ci lint-docker lint-md lint-yml sbom test update-test-snapshots

$(SBOM_FILE): $(SYFT) $(TEMP_DIR)/dockerimage
	@./$(SYFT) $(IMAGE_NAME):latest
$(VULN_FILE): $(GRYPE) $(SBOM_FILE)
	@./$(GRYPE) $(SBOM_FILE)

$(BIN_DIR):
	@mkdir $(BIN_DIR)
$(SYFT): | $(BIN_DIR)
	@curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(SYFT_VERSION)
$(GRYPE): | $(BIN_DIR)
	@curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
		sh -s -- -b ./$(BIN_DIR) $(GRYPE_VERSION)

$(NODE_MODULES): .npmrc package*.json
	@npm clean-install \
		--no-audit

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TEMP_DIR)/dockerimage: .dockerignore .eslintrc.yml Dockerfile package*.json | $(TEMP_DIR)
	@docker build --tag $(IMAGE_NAME) .
	@touch $(TEMP_DIR)/dockerimage
