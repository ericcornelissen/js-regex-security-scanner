import cp from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import url from "node:url";

import test from "ava";

const testdataDir = path.resolve(
	path.dirname(url.fileURLToPath(new URL(import.meta.url))),
	"..",
	"testdata",
);

for (const project of fs.readdirSync(testdataDir)) {
	test(project, (t) => {
		const dirPath = path.resolve(testdataDir, project);

		const argsPath = path.resolve(dirPath, ".args");
		let args = null;
		if (fs.existsSync(argsPath)) {
			args = fs.readFileSync(argsPath, { encoding: "utf-8" }).trim();
		}

		const { stdout } = cp.spawnSync(
			process.env.CONTAINER_ENGINE,
			[
				"run",
				"--rm",
				"-v",
				`${dirPath}:/project`,
				"ericornelissen/js-re-scan:latest",
				...(args?.split(/\s+/) || []),
			],
			{ encoding: "utf-8" },
		);
		t.snapshot(stdout);
	});
}
