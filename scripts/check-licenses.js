import * as fs from "node:fs";
import * as path from "node:path";
import * as process from "node:process";
import * as url from "node:url";

// ----------
// Ecosystems
// ----------

const skipEcosystems = ["npm"];

// ---------
// Utilities
// ---------

const projectRoot = path.resolve(
	path.dirname(url.fileURLToPath(new URL(import.meta.url))),
	"..",
);

const matches = (string) => (regexp) => regexp.test(string);

const quoted = (string) => `'${string}'`;

const toMatchWholeWordExpression = (string) => {
	const preWordExpr = /(?:^|[\s(])/.source;
	const postWordExpr = /(?:[\s)]|$)/.source;
	return new RegExp(`${preWordExpr}${string}${postWordExpr}`, "i");
};

const isAllowedLicense = (license) => {
	return allowedLicenses.map(toMatchWholeWordExpression).some(matches(license));
};

const applyCorrection = (artifact) => {
	const correction = corrections.find((entry) => entry.name === artifact.name);
	return {
		...artifact,
		licenses: correction?.licenses ?? artifact.licenses,
	};
};

const applyException = (artifact) => {
	const exception = exceptions.find((entry) => entry.name === artifact.name);
	return {
		...artifact,
		exception: exception?.licenses.every((l, i) => l === artifact.licenses[i]),
	};
};

// -----------
// Load policy
// -----------

const corrections = [
	{
		name: "busybox",
		licenses: ["GPL-2.0-only"],
		licenseUrl: "https://busybox.net/license.html",
		reason: "license not detected by Syft",
	},
	{
		name: "node",
		licenses: ["MIT"],
		licenseUrl: "https://github.com/nodejs/node#license",
		reason: "license not detected by Syft",
	},
];

const exceptions = [
	{
		name: "alpine-baselayout",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "alpine-baselayout-data",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "apk-tools",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "busybox",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "busybox-binsh",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "libgcc",
		licenses: ["GPL-2.0-or-later", "LGPL-2.1-or-later"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "libstdc++",
		licenses: ["GPL-2.0-or-later", "LGPL-2.1-or-later"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "scanelf",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
	{
		name: "ssl_client",
		licenses: ["GPL-2.0-only"],
		reason: "OK under the 'mere aggregation' clause",
	},
]

const licenseConfigFile = path.resolve(projectRoot, ".licensee.json");

const licenseConfigRaw = fs.readFileSync(licenseConfigFile, {
	encoding: "utf8",
});
const licenseConfig = JSON.parse(licenseConfigRaw);

const allowedLicenses = licenseConfig.licenses.spdx;

// -------------
// Load the SBOM
// -------------

const sbomFile = path.resolve(projectRoot, "sbom.json");

const rawSbom = fs.readFileSync(sbomFile);
const sbom = JSON.parse(rawSbom);

// -----------------
// Evaluate licenses
// -----------------

const licenseViolations = sbom.artifacts
	.filter((artifact) => !skipEcosystems.includes(artifact.type))
	.map(applyCorrection)
	.map(applyException)
	.filter((artifact) => !artifact.exception)
	.filter((artifact) => !artifact.licenses.some(isAllowedLicense))
	.map((artifact) => {
		return {
			licenses: artifact.licenses,
			name: artifact.name,
			type: artifact.type,
		};
	});

// --------------
// Output results
// --------------

if (licenseViolations.length > 0) {
	licenseViolations.forEach((licenseViolation) => {
		const multipleLicenses = licenseViolation.licenses.length > 1;
		console.log(
			"The",
			licenseViolation.type,
			"dependency",
			quoted(licenseViolation.name),
			"is licensed under",
			multipleLicenses
				? licenseViolation.licenses.map(quoted).join(" and ")
				: quoted(licenseViolation.licenses[0]),
			"which",
			multipleLicenses ? "are" : "is",
			"not currently allowed",
		);
	});

	console.log(/* newline */);
	console.log(
		licenseViolations.length,
		"license violation(s) detected. Please review",
	);

	process.exit(1);
} else {
	console.log("No license violations detected");
}
