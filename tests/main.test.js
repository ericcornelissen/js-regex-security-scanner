import cp from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import url from "node:url";

import test from "ava";

const testdataDir = path.resolve(
	path.dirname(url.fileURLToPath(new URL(import.meta.url))),
	"..",
	"testdata",
);

for (const project of fs.readdirSync(testdataDir)) {
	test(project, t => {
		const dirPath = path.resolve(testdataDir, project);
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
		t.snapshot(stdout);
	});
}
