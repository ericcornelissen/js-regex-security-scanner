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

> **Note** If you, for whatever reason, can no longer continue your contribution
> please share this in the issue or your Pull Request. This gives others the
> opportunity to work on it. If we don't hear from you for an extended period of
> time we may decide to allow others to work on the issue you were assigned to.

### Prerequisites

To be able to contribute you need at least the following:

- [Git];
- [Docker];
- [Make];
- [Node.js] v18.0.0 or higher and [npm] v8.1.2 or higher;
- (Recommended) a code editor with [EditorConfig] support;
- (Optional) [yamllint];

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
[Docker] image. As a first principle, all changes should be made by adjusting
this setup. This means the two most important files are:

- `.eslintrc.yml`: The [ESLint] configuration file.
- `Dockerfile`: The file telling [Docker] how to make the scanner image.

#### Building

To build the Docker image for this scanner, run:

```shell
make build
```

#### Linting

This project uses linters to catch mistakes and enforce style. Run:

```shell
make lint
```

to run all linters or use the following commands to check specific file types:

| File type        | Command            | Linter         |
| :--------------- | :----------------- | :------------- |
| `Dockerfile`     | `make lint-docker` | [hadolint]     |
| MarkDown (`.md`) | `make lint-md`     | [markdownlint] |
| YAML (`.yml`)    | `make lint-yml`    | [yamllint]     |

#### Testing

This project is tested using "snapshot testing" with [AVA]. In short, this means
that the scanner is run against known projects and the scanner's output is
compared against a previous output of the scanner (the snapshot) for that same
project.

##### Running Tests

To be able to run the tests, make sure you:

- Initialized the [git] submodules.
  - If you're cloning the project, use the `--recurse-submodules` flag.
  - If you already cloned the repo, use `git submodule update --init`.

To run the tests, run:

```shell
make test
```

##### Updating Snapshots

If you made changes to the scanner, it is likely necessary to update the test
snapshots. To do this, run:

```shell
make update-test-snapshots
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

---

## Auditing

### SBOM

To generate a Software Bill Of Materials (SBOM) at `./sbom.json`, run:

```shell
make sbom
```

This uses [Syft] to generate an SBOM for the Docker image.

### Vulnerability Scanning

#### Docker

To get a vulnerability report for the Docker image at `./vulns.json`, run:

```shell
make audit-docker
```

This uses [Grype] to determine vulnerabilities based on the SBOM (excluding
npm).

#### Node.js

To scan for vulnerabilities in Node.js dependencies, run:

```shell
make audit-npm
```

[ava]: https://github.com/avajs/ava
[bug report]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=bug
[docker]: https://www.docker.com/
[editorconfig]: https://editorconfig.org/
[eslint]: https://eslint.org/
[feature request]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=enhancement
[git]: https://git-scm.com/
[grype]: https://github.com/anchore/grype
[hadolint]: https://github.com/hadolint/hadolint
[make]: https://www.gnu.org/software/make/
[markdownlint]: https://github.com/DavidAnson/markdownlint
[node.js]: https://nodejs.org/en/
[npm]: https://www.npmjs.com/
[open issues]: https://github.com/ericcornelissen/js-regex-security-scanner/issues
[security policy]: ./SECURITY.md
[submodule]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[syft]: https://github.com/anchore/syft
[yamllint]: https://github.com/adrienverge/yamllint
