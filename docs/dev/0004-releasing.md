# 0004 - Releasing

## Introduction

This decision record describes the project's versioning strategy and release
process as well as why it is this way.

## Description

### Versioning Strategy

This project is versioned using [Semantic Versioning] as a simple, standardized
way to number stable releases. At this point in time this project does not have
unstable releases.

#### Changelog

A log of changes per stable version is kept in the `CHANGELOG.md` file. Entries
in the log should follow the format:

```text
- (<7-CHAR-COMMIT-SHA>) <CHANGE DESCRIPTION>.
```

This provides readers with information on what changed as well as a reference to
the related code change. This does require all noteworthy changes are made in a
single commit. This has been chosen over references to "tickets" (or similar) as
commits are more self-contained and permanent.

#### Version Marks

Releases of this project shall be marked with a git tag on the commit at which
the release was built and a published Docker image with the version tag. Both of
these tags shall have the format `vX.Y.Z` (e.g. `v3.1.4`).

Additionally, a git branch that points to the latest stable release of a given
major release shall be kept up-to-date. This branches shall be named `vX` (e.g.
`v3`). This provides users with a convenient reference point.

### Release Process

The `RELEASE.md` document should always contain an up-to-date description of the
full manual release process. On top of this there should be release automation
that can perform most of the release process steps in a consistent manner, most
importantly the steps where artifacts are build and distributed.

#### Release Automation

The release automation for this project is triggered by pushing a git tag to the
GitHub repository. This starts a workflow that first validates the release
(build & test) and then:

- Publishes an [Docker] image for the version tag to [Docker hub].
- Updates the version branch to point to the same commit as the version tag.

This workflow is encoded in `.github/workflows/release.yml`.

[docker]: https://www.docker.com/
[docker hub]: https://hub.docker.com/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
