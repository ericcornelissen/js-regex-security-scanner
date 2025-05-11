<!-- SPDX-License-Identifier: CC0-1.0 -->
<!-- doctest:ignore-file -->

# Contributing Guidelines

The _JavaScript Regex Security Scanner_ project welcomes contributions and
corrections of all forms. This includes improvements to the documentation or
code base, new tests, bug fixes, and implementations of new features. We
recommend you open an issue before making any substantial changes so you can be
sure your work won't be rejected. But for changes such as fixing a typo you can
open a Pull Request directly.

If you plan to make a contribution, please do make sure to read through the
relevant sections of this document.

---

## Reporting Issues

### Security

For security related issues, please refer to the [security policy].

### Bug Reports

If you have problems with the project or think you've found a bug, please report
it to the developers; we ask you to always open an issue describing the bug as
soon as possible so that we, and others, are aware of the bug.

Before reporting a bug, make sure you've actually found a real bug. Carefully
read the documentation and see if it really says you can do what you're trying
to do. If it's not clear whether you should be able to do something or not,
report that too; it's a bug in the documentation! Also, make sure the bug has
not already been reported.

When preparing to report a bug, try to isolate it to a small working example
that reproduces the problem. Once you have a precise problem you can report it
as a [bug report].

### Feature Requests

New features are welcomed as long as they're related to the JavaScript ecosystem
or JavaScript regular expression security. We recommend you to always open a
[feature request] before trying to implement the feature. You might receive
useful feedback and can be sure you won't spend time implementing something that
won't be merged.

When submitting a [feature request], be sure to check if the feature hasn't been
requested before.

### Corrections

Corrections, such as fixing typos or refactoring code, are important. For small
changes of this nature you can open a Pull Request directly, or open an issue
first if you prefer.

---

## Making Changes

You are always free to contribute by working on one of the confirmed or accepted
(and unassigned) [open issues] and opening a Pull Request for it.

It is advised to indicate that you will be working on a issue by commenting on
that issue. This is so others don't start working on the same issue as you are.
Also, don't start working on an issue which someone else is working on - give
everyone a chance to make contributions.

When you open a Pull Request that implements an issue make sure to link to that
issue in the Pull Request description and explain how you implemented the issue
as clearly as possible.

> **NOTE:** If you, for whatever reason, can not continue with your contribution
> please share this in the issue or your Pull Request. This gives others the
> opportunity to work on it. If we don't hear from you for an extended period of
> time we may decide to allow others to work on the issue you were assigned to.

### Prerequisites

To be able to contribute you need at least the following:

- [Git];
- [Docker] (or [Podman]);
- [Make];
- [Node.js] v24.0.0 or higher and [npm] v8.1.2 or higher;
- (Recommended) a code editor with [EditorConfig] support;
- (Optional) [actionlint] (see `.tool-versions` for preferred version);
- (Optional) [diffoci] (see `.tool-versions` for preferred version);
- (Optional) [Grype] (see `.tool-versions` for preferred version);
- (Optional) [hadolint] (see `.tool-versions` for preferred version);
- (Optional) [ShellCheck] (see `.tool-versions` for preferred version);
- (Optional) [Syft] (see `.tool-versions` for preferred version);
- (Optional) [yamllint] (see `.tool-versions` for preferred version);

### Workflow

If you decide to make a contribution, please do use the following workflow:

- Fork the repository.
  - **Tip**: use `--recurse-submodules` when cloning the repository.
- Create a new branch from the latest `main`.
- Make your changes on the new branch.
- Commit to the new branch and push the commit(s).
- Make a Pull Request.

### Development Details

This scanner is in essence running [ESLint] with a specific configuration in a
container image. As a first principle, all changes should be made by adjusting
this setup. This means the two most important files are:

- `eslint.config.js`: The [ESLint] configuration file.
- `Containerfile`: The file telling [Docker] (or [Podman]) how to make the
  scanner image.

#### Building

To build the container image for this scanner, run:

```shell
make build
```

Or to build using Podman, run:

```shell
make build ENGINE=podman
```

##### Build Reproducibility

To test the reproducibility of the container image, run:

```shell
make reproducible-build
```

#### Formatting

This project uses formatters to automatically format source code. Run the
command `make format` to format the source code, or `make check-formatting` to
check if your changes follow the expected format.

#### Analyzing

On top of that, the project uses static analysis tools to catch mistakes. Use
`make check` to run all checks, or use one of the following commands to check
your changes if applicable:

| What            | Command                 |
| :-------------- | :---------------------- |
| CI workflows    | `make check-ci`         |
| `Containerfile` | `make check-image`      |
| Licenses        | `make check-licenses`   |
| MarkDown        | `make check-md`         |
| YAML            | `make check-yml`        |

#### Testing

This project is tested using "snapshot testing". In short, this means the
scanner is run against known projects and the scanner's output is compared
against a previous output of the scanner (the snapshot) for that same project.

##### Running Tests

To be able to run the tests, make sure you:

- Initialized the [git] submodules.
  - If you're cloning the project, use the `--recurse-submodules` flag.
  - If you already cloned the repo, use `git submodule update --init`.

To run the tests, run:

```shell
make test
```

Or to run the tests using Podman, run:

```shell
make test ENGINE=podman
```

##### Updating Snapshots

If you made changes to the scanner, it is likely necessary to update the test
snapshots. To do this, run:

```shell
make update-test-snapshots
```

Or using Podman:

```shell
make update-test-snapshots ENGINE=podman
```

##### Writing Tests

To write a test you need to do two things:

1. Create a new project to scan in the `testdata/` directory.
   - If it's a toy example, simply create a directory and put the relevant files
     in the directory.
   - If it's a real-world example, add the repository as a [submodule] to this
     repository.
1. Run the tests, this will automatically initialize the snapshot for the new
   test.

###### Testing with CLI Arguments

If you need to test the behavior of the scanner when given certain arguments,
include a file called `.args` in the test project directory. For example:

```diff
+ testdata/my-test-project/.args
  testdata/my-test-project/my-ignored-file.js
  testdata/my-test-project/my-test-file.js
```

In the `.args` file, put a single line with all the arguments that should be
passed to the scanner. For example:

```text
--ignore-pattern my-ignored-file.js
```

The test for this test project will read this file and call the scanner with the
arguments found in this file.

---

## Auditing

### SBOM

To generate a Software Bill Of Materials (SBOM) at `./sbom*.json`, run:

```shell
make sbom
```

This uses [Syft] to generate an SBOM for the container image.

### Vulnerability Scanning

#### Container Image

To get a vulnerability report for the container image at `./vulns.json`, run:

```shell
make audit-vulnerabilities-image
```

This uses [Grype] to determine vulnerabilities based on the SBOM (excluding
npm).

#### Node.js

To scan for vulnerabilities in Node.js dependencies, run:

```shell
make audit-vulnerabilities-npm
```

### Deprecation Warnings

To check for deprecation warnings in all npm dependencies, run:

```shell
make audit-deprecations
```

This uses [depreman] to audit deprecation warnings, which allows for having
exceptions defined in the `.ndmrc` file.

[actionlint]: https://github.com/rhysd/actionlint
[bug report]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=bug
[depreman]: https://github.com/ericcornelissen/depreman
[diffoci]: https://github.com/reproducible-containers/diffoci
[docker]: https://www.docker.com/
[editorconfig]: https://editorconfig.org/
[eslint]: https://eslint.org/
[feature request]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=enhancement
[git]: https://git-scm.com/
[grype]: https://github.com/anchore/grype
[hadolint]: https://github.com/hadolint/hadolint
[make]: https://www.gnu.org/software/make/
[node.js]: https://nodejs.org/en/
[npm]: https://www.npmjs.com/
[open issues]: https://github.com/ericcornelissen/js-regex-security-scanner/issues
[podman]: https://podman.io/
[security policy]: ./SECURITY.md
[shellcheck]: https://github.com/koalaman/shellcheck
[submodule]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[syft]: https://github.com/anchore/syft
[yamllint]: https://github.com/adrienverge/yamllint
