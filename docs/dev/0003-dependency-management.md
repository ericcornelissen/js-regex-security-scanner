# 0003 - Dependency Management

## Introduction

This decision record describes how the project's dependencies are managed and
why it is managed in this way.

## Goals

The goal of dependency management for this project is to track and keep
up-to-date external dependencies. Additional goals include reproducibility and
security.

External dependencies come from (in alphabetical order):

- [Docker]
- [npm]
- [Git submodules]
- [GitHub Actions]
- Stray dependencies

## Description

### Docker

Dependencies introduced through [Docker] are specified in the `Dockerfile`
through the base image. The base image specifies a Node.js runtime version and
operating system version explicitly for reproducibility. The base image is kept
up-to-date by [Dependabot].

The base image introduces many indirect runtime dependencies. These are not
explicitly tracked or kept up-to-date. They can be enumerated using the command:

```shell
make sbom
```

### Git Submodules

All [git submodules] are explicitly specified in the `.gitmodules` file and
version tracked at the folder location where the submodule is cloned. Git
submodules are intentionally not kept up-to-date because the project's tests
depend on specific versions of these dependencies.

### GitHub Actions

The [GitHub Actions] dependencies are explicitly specified in the [YAML] files
found in `.github/workflows` and version tracked by commit SHA - over version
tag or branch - for reproducibility (branches and tags can be changed easily)
and security. They are kept up to date by [Dependabot].

### npm

All direct [npm] dependencies are explicitly recorded in `package.json`. All
dependencies should be pinned to a specific version. Dependencies should be
split between runtime (in `"dependencies"`) and development dependencies (in
`"devDependencies"`). These are are kept up to date by [Dependabot].

Furthermore, the `package-lock.json` file is included in version control to have
integrity checks (for security) and a record of transitive dependencies.

### Stray Dependencies

Stray dependencies are those dependencies that are not tracked in a controlled
manner but are instead "just downloaded from the internet". The stray
dependencies for this project are (in alphabetical order):

- [Grype]
- [Licensed]
- [hadolint]
- [Syft]

The intended version to be used of these dependencies is defined in the
`Makefile` for reproducibility. They are kept up-to-date manually.

Stray dependencies should be avoided as much as possible.

## Dependabot

The [Dependabot] configuration can be found at `.github/dependabot.yml`. The aim
is to have Dependabot provide updates on the same schedule for all ecosystems.
It is configured to limit the number of updates in an effort to keep dependency
management manageable.

<!-- External links -->

[dependabot]: https://github.com/dependabot
[docker]: https://www.npmjs.com/
[git submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[github actions]: https://github.com/features/actions
[grype]: https://github.com/anchore/grype
[hadolint]: https://github.com/hadolint/hadolint
[licensed]: https://github.com/github/licensed
[npm]: https://www.npmjs.com/ "node package manager"
[syft]: https://github.com/anchore/syft
[yaml]: https://yaml.org/
