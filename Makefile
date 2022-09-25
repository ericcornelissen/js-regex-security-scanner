default: help

audit: audit-docker audit-npm ## Audit the project dependencies
audit-docker: | vulns.json
audit-npm:
	npm audit

build: | .tmp/dockerimage ## Build the Docker image

clean: ## Clean the repository
	@git clean -fx \
		.tmp/ \
		bin/grype \
		bin/syft \
		node_modules/ \
		sbom.json \
		vulns.json

help: ## Show this help message
	@printf "Usage: make <command>\n\n"
	@printf "Commands:\n"
	@awk -F ':(.*)## ' '/^[a-zA-Z0-9%\\\/_.-]+:(.*)##/ { \
	  printf "  \033[36m%-30s\033[0m %s\n", $$1, $$NF \
	}' $(MAKEFILE_LIST)

init: | bin/grype bin/syft node_modules/ ## Initialize the project dependencies

sbom: build | sbom.json ## Generate a Software Bill Of Materials (SBOM)

test: build node_modules/ ## Run the tests
	npm run ava -- tests/

update-test-snapshots: build node_modules/ ## Update the test snapsthos
	npm run ava -- tests/ --update-snapshots

.PHONY: default audit audit-docker audit-npm build clean help init sbom test update-test-snapshots

sbom.json: bin/syft
	./bin/syft ericornelissen/js-re-scan:latest
vulns.json: bin/grype sbom.json
	./bin/grype sbom.json

bin/syft:
	curl -sSfL https://raw.githubusercontent.com/anchore/syft/main/install.sh | \
		sh -s -- -b ./bin v0.57.0
bin/grype:
	curl -sSfL https://raw.githubusercontent.com/anchore/grype/main/install.sh | \
		sh -s -- -b ./bin v0.50.2
node_modules/: .npmrc package*.json
	npm install

.tmp/:
	@mkdir .tmp
.tmp/dockerimage: .tmp/ .dockerignore .eslintrc.yml Dockerfile package*.json
	docker build --tag ericornelissen/js-re-scan .
	@touch .tmp/dockerimage
