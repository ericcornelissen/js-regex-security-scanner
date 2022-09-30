import cp from "node:child_process";
import path from "node:path";
import url from "node:url";

import test from "ava";

test.before(t => {
	t.context.testdataDir = path.resolve(
		path.dirname(url.fileURLToPath(new URL(import.meta.url))),
		"..",
		"testdata",
	);
});

test("sample", t => {
	const output = scanDir(`${t.context.testdataDir}/sample`);
	t.snapshot(output);
});

test("sample-ignore-patterns", t => {
	const output = scanDir(`${t.context.testdataDir}/sample-ignore-patterns`);
	t.snapshot(output);
});

test("sample-ts", t => {
	const output = scanDir(`${t.context.testdataDir}/sample-ts`);
	t.snapshot(output);
});

test("sample-unknown-rule", t => {
	const output = scanDir(`${t.context.testdataDir}/sample-unknown-rule`);
	t.snapshot(output);
});

test("shescape (v1.5.9)", t => {
	const output = scanDir(`${t.context.testdataDir}/shescape`);
	t.snapshot(output);
});

function scanDir(dirPath) {
	const { stdout } = cp.spawnSync(
		"docker",
		[
			"run",
			"--rm",
			"-v",
			`${dirPath}:/project`,
			"ericornelissen/js-re-scan:latest",
		],
		{ encoding: "utf-8" },
	);

	return stdout;
}
