# 0001 - License Validation

## Introduction

This decision record describes how the project arrived at the dependency
license validation tooling used currently.

## Considered Options

> **Note**: _In alphabetical order_

- [dependency-review-action]
- [Fossa]
- [Licensed]
- [licensee]
- SBOM-based (custom) validation script

## Comparison

This section provides a comparison of the considered options against various
considered topics. The [descriptions](#descriptions) subsection describes each
of the considered option according to the opinions of the maintainers of this
project as of the date this document was authored.

### Ecosystem Coverage

| Ecosystem      | review-action | Licensed | licensee | Fossa | SBOM-based |
| -------------- | ------------- | -------- | -------- | ----- | ---------- |
| Docker image   | No            | No       | No       | No(*) | Yes        |
| GitHub Actions | Yes           | No       | No       | No    | No         |
| npm            | Yes           | Yes      | No       | Yes   | Yes        |

(*): _More details can be found in the [descriptions](#descriptions) section._

### Features

| Feature            | review-action | Fossa | Licensed | licensee | SBOM-based |
| ------------------ | ------------- | ----- | -------- | -------- | ---------- |
| Detection          | Okay          | Good  | Okay     | Good     | Okay       |
| Extra features     | Yes(*)        | No    | No       | No       | No         |
| NOTICE file        | No            | Yes   | Yes      | No       | n/a        |
| Offline support    | No            | Local | Yes      | Yes      | Yes        |
| Open source        | Partially     | No    | Yes      | Yes      | n/a        |
| Proper dependency  | Yes           | No    | No       | Yes      | n/a        |
| Transitive deps    | Unknown       | No(*) | Yes      | Yes      | Yes        |
| Version controlled | Yes           | No    | Yes      | Yes      | Yes        |
| User experience    | Okay          | Good  | Good     | Bad      | n/a        |

(*): _More details can be found in the [descriptions](#descriptions) section._

The features listed in the above mean the following:

- _Detection_: How good is the license detection? Either "good", "okay", or
  "bad".
- _Extra features_: Does the tool have extra features that can't be disabled?
- _NOTICE file_: Can the tool generate a NOTICE file?
- _Offline support_: Can the tool be run locally? Either "no", "local", or
  "yes".
- _Open source_: Is the tool open source and available under an [OSI] approved
  license.
- _Proper dependency_: Is the tool available as a proper dependency or only
  through an install script?
- _Transitive deps_: Does the tool cover transitive dependencies?
- _Version controlled_ Is the license policy version controlled?
- _User experience_: How good is the user experience? Either "good", "okay, or
  "bad".

### Descriptions

#### [dependency-review-action]

A GitHub Actions Action that uses GitHub's dependency graph to detect licenses
and apply either an allowlist or denylist to the detected licenses. It will
generate a report that can be viewed on GitHub. As a GitHub Actions Action it
can only be run on GitHub.

The [dependency-review-action] also offers vulnerability scanning, this cannot
be disabled. Also, while it supports reviewing GitHub Actions, it fails to
detect the licenses of GitHub Actions.

#### [Fossa]

A compliance-as-a-service service that is free for open source (limited to 5
integrations and 3 layers of transitive dependencies). As a service it provides
a web-based dashboard, information on what is needed to comply with licenses. It
can enforce one of three predefined rule sets against the project. [Fossa] only
considers runtime dependencies.

There is a GitHub integration available which works well but can be slow at
times. There is also a CLI, [Fossa CLI], available that can be used to scan and
test the licenses of this project locally. However, this requires an internet
connection as it needs to communicate with the [Fossa] servers.

[Fossa] also offers extra features, but these are opt-in. One of these extra
features is vulnerability scanning for containers, while [Fossa] does not
support license scanning for containers.

#### [Licensed]

A Ruby-based CLI application from GitHub that supports various language
ecosystems, has robust configuration options, and is pretty good at detecting
licenses.

It is possible to scan runtime and development dependencies, or only runtime
dependencies using the [npm configuration][licensed-npm-config] options.

The tested version of [Licensed] requires generating a "cache" of license
information for all dependencies. This can be worked around, but as it's not
intended to be used that way it's not ideal.

#### [licensee]

An npm-specific CLI that is simple and robust. It simply checks the license
field of the package's manifest file and verifies it's approved. If no license
is specified, the dependency can be marked as manually reviewed.

It is possible to scan runtime and development dependencies, or only runtime
dependencies by using the `--production` CLI option.

The user experience of [licensee] is not every good as it prints out info for
all dependencies and exits with a `0` or `1` exit code depending on if all
licenses are allowed or not (resp.).

#### SBOM-based (custom) validation script

Create a custom script in the project that uses the Software Bill of Materials
(SBOM), already generated with [Syft], to check the licenses of dependencies.
This script will be written as a Node.js script since this is already a Node.js
based project.

## Decision

Use _[Licensed]_ for npm dependencies in combination with an _SBOM-based
(custom) validation script_ for non-npm dependencies.

This decision was arrived at after [dependency-review-action] and [Fossa] were
considered non-ideal due to their shortcomings. [licensee] was chosen over
[Licensed] primarily because the maintainers wanted to try it out while already
having used [licensee] in other projects.

<!-- Links -->

[dependency-review-action]: https://github.com/actions/dependency-review-action
[fossa]: https://fossa.com/
[fossa cli]: https://github.com/fossas/fossa-cli
[licensed]: https://github.com/github/licensed
[licensed-npm-config]: https://github.com/github/licensed/blob/76727f75d486a24758890a030e540ebf87bba78b/docs/sources/npm.md#including-development-dependencies
[licensee]: https://github.com/jslicense/licensee.js
[osi]: https://opensource.org/
[syft]: https://github.com/anchore/syft
