# Copyright 2022-2025 Eric Cornelissen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM docker.io/node:24.4.1-alpine3.22

LABEL org.opencontainers.image.title="js-regex-security-scanner" \
	org.opencontainers.image.description="A static analyzer to scan JavaScript code for problematic regular expressions." \
	org.opencontainers.image.version="0.4.40" \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/ericcornelissen/js-regex-security-scanner"

ENV NODE_ENV=production

USER node:node
RUN mkdir /home/node/js-re-scan
WORKDIR /home/node/js-re-scan

COPY --chown=node:node package.json package-lock.json ./
RUN npm clean-install \
	--omit=dev \
	--no-audit \
	--no-fund \
	--no-update-notifier \
	&& \
	rm -rf /home/node/.npm /tmp/node-compile-cache

COPY --chown=node:node ./eslint.config.js ./SECURITY.md ./LICENSE ./

WORKDIR /project

ENTRYPOINT [ \
	"/home/node/js-re-scan/node_modules/.bin/eslint", \
	\
	# This option avoids unexpected errors if the project being scanned includes
	# an ESLint configuration file.
	"--no-config-lookup", \
	\
	# This option avoids errors due to ignore directives for rules not known to
	# the ESLint setup in this project.
	"--no-inline-config", \
	\
	# Explicitly specify a path to the local configuration file so it can't be
	# missed.
	"--config", \
	"/home/node/js-re-scan/eslint.config.js", \
	\
	# The folder that should be scanned. This is the folder that users should
	# mount their project to.
	"." \
]
