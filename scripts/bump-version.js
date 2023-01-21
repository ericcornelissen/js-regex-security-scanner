import * as fs from "node:fs";
import * as path from "node:path";
import * as process from "node:process";
import * as url from "node:url";

const projectRoot = path.resolve(
	path.dirname(
		url.fileURLToPath(
			new URL(import.meta.url),
		),
	),
	"..",
);
const dockerFilePath = path.resolve(
	projectRoot,
	"Dockerfile",
);

const dockerFileRaw = fs.readFileSync(dockerFilePath).toString();

const versionLabel = dockerFileRaw.split(/\n/)
	.map(line => line.trim())
	.find(line => line.startsWith("version="));
const version = versionLabel.split("\"")[1];

const versionTuple = version.split(".");
switch (process.argv[2]) {
	case "patch":
		versionTuple[2] = parseInt(versionTuple[2], 10) + 1;
		break;
	case "minor":
		versionTuple[1] = parseInt(versionTuple[1], 10) + 1;
		versionTuple[2] = 0;
		break;
	case "major":
		versionTuple[0] = parseInt(versionTuple[0], 10) + 1;
		versionTuple[1] = 0;
		versionTuple[2] = 0;
		break;
	default:
		console.log(`unknown argument '${process.argv[2]}'`);
		console.log("must be one of 'patch', 'minor', 'major'");
		break;
}

const newVersion = versionTuple.join(".");
fs.writeFileSync(
	dockerFilePath,
	dockerFileRaw.replace(versionLabel, `version="${newVersion}" \\`),
);
