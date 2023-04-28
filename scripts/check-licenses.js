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

const setEqual = (collection1, collection2) => {
	const set1 = new Set(collection1);
	const set2 = new Set(collection2);
	return (
		set1.size === set2.size && set1.size === new Set([...set1, ...set2]).size
	);
};

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
	if (correction === undefined) {
		return artifact;
	}

	if (setEqual(artifact.licenses, correction.licenses)) {
		return {
			...artifact,
			unnecessaryCorrection: true,
		};
	}

	return {
		...artifact,
		licenses: correction.licenses,
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

const licenseDataToEvaluate = sbom.artifacts
	.filter((artifact) => !skipEcosystems.includes(artifact.type))
	.map(applyCorrection);

const licenseViolations = licenseDataToEvaluate
	.filter((artifact) => !artifact.licenses.some(isAllowedLicense))
	.map((artifact) => {
		return {
			licenses: artifact.licenses,
			name: artifact.name,
			type: artifact.type,
		};
	});

const unnecessaryCorrections = licenseDataToEvaluate
	.filter((artifact) => artifact.unnecessaryCorrection)
	.map((artifact) => {
		return {
			name: artifact.name,
		};
	});

// --------------
// Output results
// --------------

if (unnecessaryCorrections.length > 0) {
	unnecessaryCorrections.forEach((artifact) => {
		console.log("Unnecessary license correction for", quoted(artifact.name));
	});

	console.log(/* newline */);
	console.log(
		unnecessaryCorrections.length,
		"unnecessary correction(s) detected. Please review",
	);
}

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
}

if (licenseViolations.length > 0 || unnecessaryCorrections.length > 0) {
	process.exit(1);
} else {
	console.log("No license violations detected");
}
