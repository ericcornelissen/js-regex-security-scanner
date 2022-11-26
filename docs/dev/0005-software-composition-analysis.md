# 0005 - Software Composition Analysis

## Introduction

This decision record describes the project's Software Composition Analysis (SCA)
approach as well as why it is this way.

Software Composition Analysis is about determining what building blocks are used
by the project, both during development and at runtime, as well as determining
if any of the building blocks have known vulnerabilities.

## Description

At a high level, this project is built using [Docker] and [Node.js] with [npm].
The Software Composition Analysis setup follows this high level set up, one part
concerned with [Docker] and one with [Node.js].

### Docker SCA

For the Software Composition Analysis of the Docker image [Syft] and [Grype] are
used. [Syft] is used to generate a Software Bill Of Materials (SBOM) for the
Docker image. [Grype] in turn is used to scan the SBOM for known vulnerabilities
in any of the software in the Docker image.

As Node.js SCA is handled separately, all Node.js related vulnerabilities are
ignored by [Grype]. [Syft] still puts them in the SBOM as there's no known
drawback to this. This was done because Node.js ecosystem provides sufficient
tooling for SCA and vulnerability scanning and, being native, is much better at
it than [Grype].

### Node.js SCA

For the Software Composition Analysis of Node.js building blocks the project
manifest (`package.json`) and lockfile (`package-lock.json`) are used. These two
files define exactly what building blocks will be used from the [npm] registry.
The `npm audit` command is used to scan all Node.js dependencies for known
vulnerabilities.

### Miscellaneous

Some of the software used during development falls outside of these two
categories, namely (in alphabetical order):

- [Grype]
- [hadolint]
- [Licensed]
- [Make]
- [Syft]

[docker]: https://www.docker.com/ "Docker"
[grype]: https://github.com/anchore/grype "Grype"
[hadolint]: https://github.com/hadolint/hadolint
[licensed]: https://github.com/github/licensed
[make]: https://www.gnu.org/software/make/
[node.js]: https://nodejs.org/en/ "Node JS"
[npm]: https://www.npmjs.com/ "Node Package Manager"
[syft]: https://github.com/anchore/syft "Syft"
