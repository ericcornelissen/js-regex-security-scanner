// SPDX-License-Identifier: Apache-2.0

import * as fs from "node:fs";
import * as path from "node:path";
import * as url from "node:url";

// ---------
// Constants
// ---------

const STR_UNRELEASED = "## [Unreleased]";
const STR_NO_CHANGES = "- _No changes yet_";

const projectRoot = path.resolve(
	path.dirname(url.fileURLToPath(new URL(import.meta.url))),
	"..",
);

// -------------
// Paths & Files
// -------------

const changelogFilePath = path.resolve(projectRoot, "CHANGELOG.md");
const containerfilePath = path.resolve(projectRoot, "Containerfile");

const containerfileRaw = fs.readFileSync(containerfilePath).toString();
const changelogRaw = fs.readFileSync(changelogFilePath).toString();

// ---------------
// Current version
// ---------------

const versionLabel = containerfileRaw
	.split(/\n/)
	.map((line) => line.trim())
	.find((line) => line.startsWith("version="));
const version = versionLabel.split('"')[1];

// ----------
// Validation
// ----------

if (changelogRaw.includes(`## [${version}]`)) {
	throw new Error(`${version} already in CHANGELOG`);
}

const unreleasedTitleIndex = changelogRaw.indexOf(STR_UNRELEASED);
if (unreleasedTitleIndex === -1) {
	throw new Error("The CHANGELOG is invalid");
}

if (changelogRaw.includes(STR_NO_CHANGES)) {
	throw new Error("No changes to release in the CHANGELOG");
}

// -----------------
// Changelog updates
// -----------------

const date = new Date();
const year = date.getFullYear();
const _month = date.getMonth() + 1;
const month = _month < 10 ? `0${_month}` : _month;
const _day = date.getDate();
const day = _day < 10 ? `0${_day}` : _day;

const newChangelog =
	changelogRaw.slice(0, unreleasedTitleIndex + STR_UNRELEASED.length) +
	`\n\n${STR_NO_CHANGES}` +
	`\n\n## [${version}] - ${year}-${month}-${day}` +
	changelogRaw.slice(unreleasedTitleIndex + STR_UNRELEASED.length);

fs.writeFileSync(changelogFilePath, newChangelog);
