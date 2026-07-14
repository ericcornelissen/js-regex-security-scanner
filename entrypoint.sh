#!/bin/bash

# Copyright 2026 Eric Cornelissen
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

sarif=()
user_args=()
for arg in "$@"; do
	if [[ ${arg} == '--sarif' ]]; then
		sarif=(
			--format
			'/home/node/js-re-scan/node_modules/@microsoft/eslint-formatter-sarif/sarif.js'
		)
	else
		user_args+=("${arg}")
	fi
done

args=(
	# This option avoids unexpected errors if the project being scanned
	# includes an ESLint configuration file.
	--no-config-lookup

	# This option avoids errors due to ignore directives for rules not known to
	# the ESLint setup in this project.
	--no-inline-config

	# Explicitly specify a path to the local configuration file so it can't be
	# missed.
	--config
	'/home/node/js-re-scan/eslint.config.js'

	# If enabled, use the flags for enabling SARIF output.
	"${sarif[@]}"

	# The folder that should be scanned. This is the folder that users should
	# mount their project to.
	.

	# Any user supplied arguments for ESLint. Enables use of `--ignore-pattern`
	# and provided backwards compatibility with v0.4.59 and before.
	"${user_args[@]}"
)

/home/node/js-re-scan/node_modules/.bin/eslint "${args[@]}"
