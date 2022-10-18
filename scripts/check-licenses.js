import * as fs from "node:fs";
import * as path from "node:path";
import * as process from "node:process";
import * as url from "node:url";

// ------------
// License list
// ------------

const allowedLicenses = [
	"BSD",
	"0BSD",
	"Apache-2.0", "Apache 2.0",
	"Artistic-2.0",
	// TODO: uncomment, this is only commented for demonstration purposes
	//"BSD-2-Clause",
	//"BSD-3-Clause",
	"CC0-1.0",
	"CC-BY-3.0",
	"GPL-2.0-only",
	"GPL-2.0-or-later",
	"ISC",
	"MIT",
	"OpenSSL",
	"Python-2.0",
	"Zlib",
];

// ----------------
// Helper functions
// ----------------

const matches = (string) => (regexp) => regexp.test(string);

const quoted = (string) => `'${string}'`;

const toMatchWholeWordExpression = (string) => {
	const preWordExpr = /(?:^|[\s(])/.source;
	const postWordExpr = /(?:[\s)]|$)/.source;
	return new RegExp(`${preWordExpr}${string}${postWordExpr}`);
};

const isAllowedLicense = (license) =>
	allowedLicenses.includes(license) ||
	allowedLicenses
		.map(toMatchWholeWordExpression)
		.some(matches(license));

// -------------
// Load the SBOM
// -------------

const projectRoot = path.resolve(
	path.dirname(
		url.fileURLToPath(
			new URL(import.meta.url),
		),
	),
	"..",
);
const sbomFile = path.resolve(
	projectRoot,
	"sbom.json",
);

const rawSbom = fs.readFileSync(sbomFile);
const sbom = JSON.parse(rawSbom);

// -----------------
// Evaluate licenses
// -----------------

const licenseViolations = sbom.artifacts
	.filter(artifact => !artifact.licenses.some(isAllowedLicense))
	.map(artifact => {
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
	licenseViolations.forEach(licenseViolation => {
		const multipleLicenses = licenseViolation.licenses.length > 1;
		console.log(
			"The",
			licenseViolation.type,
			"dependency",
			quoted(licenseViolation.name),
			"is licensed under",
			multipleLicenses
				? licenseViolation.licenses.map(quoted).join(' and ')
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
