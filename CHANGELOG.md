# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic
Versioning].

## [Unreleased]

- (`9d2829c`) Add support for scanning TypeScript projects.
- (`3aebaf0`) Bump ESLint from `8.23.0` to `8.23.1`.
- (`8d5b874`) Ignore more dependency as well as common output/temporary folders.
- (`1353931`) Ignore IDE related folders.
- (`8863b7b`) Ignore the `vendor/` folder.

## [0.1.1] - 2022-09-17

- (`3bc7786`) Correctly scan `.cjs` and `.mjs` files.
- (`20b5b18`) Document the scanner's exit codes.
- (`f2f6242`) Suggest using `--rm` flag when running the scanner in the docs.

## [0.1.0] - 2022-09-14

- (`7dfe68a`) Create a Docker-based static scanner to find problematic regular
  expressions in JavaScript code.

[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
