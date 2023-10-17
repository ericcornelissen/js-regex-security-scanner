# Copyright 2023 Eric Cornelissen
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

FROM node:20.8.1-alpine3.18

LABEL name="js-regex-security-scanner" \
	description="A static analyzer to scan JavaScript code for problematic regular expressions." \
	version="0.4.14" \
	license="Apache-2.0"

ENV NODE_ENV=production

USER node:node
RUN mkdir /home/node/js-re-scan
WORKDIR /home/node/js-re-scan

COPY --chown=node:node package.json package-lock.json ./
RUN npm install \
	--omit=dev \
	--no-audit \
	--no-fund \
	--no-update-notifier

COPY --chown=node:node ./ ./

ENTRYPOINT [ \
	"./node_modules/.bin/eslint", \
	\
	# This option avoids unexpected errors if the project being scanned includes
	# an ESLint configuration file.
	"--no-eslintrc", \
	\
	# This option avoids errors due to ignore directives for rules not known to
	# the ESLint setup in this project.
	"--no-inline-config", \
	\
	# Explicitly specify a path to the local configuration file so it can't be
	# missed.
	"--config", \
	"./.eslintrc.yml", \
	\
	# Specify the extensions of files that should be scanned.
	"--ext", \
	".js,.jsx,.cjs,.mjs,.ts,.cts,.mts,.md", \
	\
	# The folder that should be scanned. This is the folder that users should
	# mount their project to.
	"/project" \
]
