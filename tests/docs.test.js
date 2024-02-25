// SPDX-License-Identifier: Apache-2.0

import cp from "node:child_process";
import fs from "node:fs";
import path from "node:path";
import process from "node:process";
import url from "node:url";

import test from "ava";

const rootDir = path.resolve(
	path.dirname(url.fileURLToPath(new URL(import.meta.url))),
	"..",
);

for (const file of fs.readdirSync(rootDir)) {
	if (path.extname(file) !== ".md") {
		continue;
	}

	const content = fs.readFileSync(path.join(rootDir, file), {
		encoding: "utf-8",
	});

	if (/<!--\s*doctest:ignore-file\s*-->/.test(content)) {
		continue;
	}

	const expr =
		/(?:<!--\s*doctest:([a-z-]+)\s*-->)?[\s\n\r]*```([a-z]+)\r?\n([^]+?)\r?\n\s*```/g;

	let match;
	let i = 0;
	while ((match = expr.exec(content)) !== null) {
		i++;

		const directive = match[1];
		if (directive !== undefined) {
			switch (directive) {
				case "ignore":
					continue;
				default:
					throw new Error(`Unknown doctest directive: '${directive}'`);
			}
		}

		const language = match[2];
		const script = match[3]
			.split(/\n/)
			.map((line) => line.trim())
			.join("\n")
			.replace("docker", process.env.CONTAINER_ENGINE);
		if (language !== "shell") {
			continue;
		}

		test(`${file} snippet #${i}`, (t) => {
			const { status } = cp.spawnSync(script, [], {
				cwd: rootDir,
				encoding: "utf-8",
				shell: true,
			});
			t.snapshot(status);
		});
	}
}
