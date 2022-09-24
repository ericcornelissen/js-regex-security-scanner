default: help

audit: sbom ## Audit the project dependencies
	npm audit
	./bin/grype sbom.json

build: ## Build the Docker image
	docker build --tag ericornelissen/js-re-scan .

clean: ## Clean the repository
	@git clean -fx \
		bin/grype \
		bin/syft \
		node_modules \
		sbom.json \
		vulns.json

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
	  printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: ## Initialize the project dependencies
	npm install
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | sh -s -- -b ./bin v0.57.0
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh  | sh -s -- -b ./bin v0.50.2

sbom: build ## Generate a Software Bill Of Materials (SBOM)
	./bin/syft ericornelissen/js-re-scan:latest

test: build ## Run the tests
	npm run ava -- tests/

update-test-snapshots: build ## Update the test snapsthos
	npm run ava -- tests/ --update-snapshots

.PHONY: default audit build clean help init sbom test update-test-snapshots
