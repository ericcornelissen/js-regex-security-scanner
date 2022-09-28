IMAGE_NAME=ericornelissen/js-re-scan

GRYPE_VERSION=v0.50.2
SYFT_VERSION=v0.57.0

BIN_DIR=.bin
TEMP_DIR=.tmp
LICENSED_CACHE=$(TEMP_DIR)/licensed

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
		$(VULN_FILE) \
		NOTICE-npm

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
	  printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: | $(BIN_DIR)/grype $(BIN_DIR)/licensed $(BIN_DIR)/syft node_modules/ ## Initialize the project dependencies

license-check-npm: $(LICENSED_CACHE) ## Check npm dependency licenses
	./$(BIN_DIR)/licensed status

notice-npm: $(LICENSED_CACHE) ## Create NOTICE for npm dependencies
	./$(BIN_DIR)/licensed notice
	mv $(TEMP_DIR)/licensed/NOTICE NOTICE-npm

sbom: $(SBOM_FILE) ## Generate a Software Bill Of Materials (SBOM)

test: build node_modules/ ## Run the tests
	npm run ava -- tests/

update-test-snapshots: build node_modules/ ## Update the test snapsthos
	npm run ava -- tests/ --update-snapshots

.PHONY: default audit audit-docker audit-npm build clean help init license-check-npm notice-npm sbom test update-test-snapshots

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
$(BIN_DIR)/licensed:
	curl -sSL https://github.com/github/licensed/releases/download/3.7.3/licensed-3.7.3-linux-x64.tar.gz > $(TEMP_DIR)/licensed.tar.gz
	tar -xzf $(TEMP_DIR)/licensed.tar.gz --directory $(TEMP_DIR)
	rm -rf $(TEMP_DIR)/meta/ $(TEMP_DIR)/licensed.tar.gz
	mv $(TEMP_DIR)/licensed $(BIN_DIR)/licensed

node_modules/: .npmrc package*.json
	npm install

$(TEMP_DIR):
	@mkdir $(TEMP_DIR)
$(TEMP_DIR)/dockerimage: $(TEMP_DIR) .dockerignore .eslintrc.yml Dockerfile package*.json
	docker build --tag $(IMAGE_NAME) .
	@touch $(TEMP_DIR)/dockerimage
$(LICENSED_CACHE): $(TEMP_DIR) $(BIN_DIR)/licensed node_modules/
	./$(BIN_DIR)/licensed cache
