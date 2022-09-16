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
	const dir = `${t.context.testdataDir}/sample`;
	const { stdout } = cp.spawnSync(
		"docker",
		[
			"run",
			"--rm",
			"-v",
			`${dir}:/project`,
			"ericornelissen/js-re-scan:latest",
		],
		{ encoding: "utf-8" },
	);
	t.snapshot(stdout);
});

test("shescape (v1.5.9)", t => {
	const dir = `${t.context.testdataDir}/shescape`;
	const { stdout } = cp.spawnSync(
		"docker",
		[
			"run",
			"--rm",
			"-v",
			`${dir}:/project`,
			"ericornelissen/js-re-scan:latest",
		],
		{ encoding: "utf-8" },
	);
	t.snapshot(stdout);
});
