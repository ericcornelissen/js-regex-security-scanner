# 0002 - Testing

## Introduction

This decision record describes how the project is tested and why it is tested in
this way.

## Description

### Overview

The tests for this project run the scanner on known files/projects and verify
that the output is as expected. Here, "as expected" means that it's the same
output as it was previously. This concept is typically referred to as "snapshot
testing".

### Framework

The testing framework that is used for testing is [AVA]. This is because:

1. Being an Node.js testing framework, it can be included as a (development)
   dependency in a way that is easy to use and maintain.
2. It has built-in support for snapshot testing ([ref][ava-snapshot]).

### Tests

The tests for this project can be found in the `tests/` folder and are written
in JavaScript (as a result of the test framework being [AVA]). Tests can be run
using:

```shell
make test
```

which shall perform all steps necessary for running all tests.

Test are written in an end-to-end style. I.e., the tests invoke the scanner on
known data (see [testdata]) and asserts things about its output. In practice
this is achieved by invoking the scanner using the [`node:child_process`]
module.

#### Snapshots

As described, the tests run the scanner and "assert things about its output".
What is asserted is that the current output matches a snapshot of the old output
of the scanner.

However, in some cases the output of the scanner changes intentionally. In this
case the snapshots have to be updated. It shall be possible to update the
snapshots using:

```shell
make update-test-snapshots
```

### Testdata

The tests run the scanner on known data. This data can be found in the
`testdata/` folder. The test data is a mix of custom and real-world projects.
Custom projects are created to test specific behaviour of the scanner (for
example, ignoring certain folders). Real-world projects are used to test if the
scanner can find meaningful results in practice.

Real-world testdata is included in the project through [git submodules]. As
such, it is necessary to properly initialize the repository prior to running
tests. In particular, it is necessary to either:

- clone the repository using the `--recurse-submodules` option, or
- run `git submodule update --init` if the repository is already cloned.

### Continuous Testing

The test suite should be run continuously. This is achieved using the continuous
integration workflow `.github/workflows/check.yml` in the job named "Test".

## Miscellaneous

### Git Attributes

[AVA] stores snapshots as binaries in `.snap` files. As such, the pattern
`*.snap` is included in the `.gitattributes` with the `-diff` flag to avoid
binary diffs from being displayed by git.

<!-- External links -->

[ava]: https://www.npmjs.com/package/ava
[ava-snapshot]: https://github.com/avajs/ava/blob/52b22700e995eda3fd0f95e4b8fd31ab3c7644be/docs/04-snapshot-testing.md
[git submodules]: https://git-scm.com/book/en/v2/Git-Tools-Submodules
[`node:child_process`]: https://nodejs.org/api/child_process.html

<!-- Internal links -->

[testdata]: #testdata
