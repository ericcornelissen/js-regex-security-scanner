# Changelog

All notable changes to the _JavaScript Regex Security Scanner_ will be
documented in this file.

The format is based on [Keep a Changelog], and this project adheres to [Semantic
Versioning].

## [Unreleased]

- (`94fd158`) Bump ESLint from `8.28.0` to `8.29.0`.
- (`49fc85d`) Bump `@typescript-eslint/parser` from `5.44.0` to `5.45.0`.
- (`65ada49`) Bump `@typescript-eslint/parser` from `5.45.0` to `5.45.1`.
- (`d0298f8`) Bump `@typescript-eslint/parser` from `5.45.1` to `5.46.0`.
- (`94d7c9d`) Omit project and ESLint command details from scanner output.

## [0.2.5] - 2022-11-26

- (`b13616d`) Bump ESLint from `8.27.0` to `8.28.0`.
- (`084a590`) Bump `eslint-plugin-regexp` from `1.9.0` to `1.10.0`.
- (`862e731`) Bump `eslint-plugin-regexp` from `1.10.0` to `1.11.0`.
- (`f1a9baf`) Bump `@typescript-eslint/parser` from `5.42.1` to `5.44.0`.

## [0.2.4] - 2022-11-09

- (`621a364`) Bump ESLint from `8.26.0` to `8.27.0`.
- (`42753f0`) Bump Node.js runtime from `18.11.0` to `18.12.0`.
- (`0f1a8dc`) Bump Node.js runtime from `18.12.0` to `18.12.1`.
- (`a7e249f`) Bump `@typescript-eslint/parser` from `5.40.1` to `5.41.0`.
- (`a72cfc8`) Bump `@typescript-eslint/parser` from `5.41.0` to `5.42.0`.
- (`9d5aa6e`) Bump `@typescript-eslint/parser` from `5.42.0` to `5.42.1`.
- (`07f3424`) Ignore test-related folders and files.

## [0.2.3] - 2022-10-24

- (`2d098a0`) Bump ESLint from `8.24.0` to `8.25.0`.
- (`ec45b29`) Bump ESLint from `8.25.0` to `8.26.0`.
- (`e45e9c3`) Bump Node.js runtime from `18.10.0` to `18.11.0`.
- (`ea4e966`) Bump `@typescript-eslint/parser` from `5.38.0` to `5.40.0`.
- (`f0472d3`) Bump `@typescript-eslint/parser` from `5.40.0` to `5.40.1`.

## [0.2.2] - 2022-10-03

- (`1222760`) Bump ESLint from `8.23.1` to `8.24.0`.
- (`fa669fa`) Bump Node.js runtime from `18.9.0` to `18.9.1`.
- (`ed6e031`) Bump Node.js runtime from `18.9.1` to `18.10.0`.
- (`b58666b`) Fix some folders not being ignored correctly.

## [0.2.1] - 2022-09-25

- (`4c29319`) Add labels with metadata to the Docker image.
- (`1643b5e`) Fix incorrect errors due to ESLint ignore directives.

## [0.2.0] - 2022-09-21

- (`9d2829c`) Add support for scanning TypeScript projects.
- (`3aebaf0`) Bump ESLint from `8.23.0` to `8.23.1`.
- (`8d5b874`) Ignore more dependency as well as common output/temporary folders.
- (`1353931`) Ignore IDE related folders.
- (`8863b7b`) Ignore the `vendor/` folder.
- (`20b948a`) Pin Docker image to specific Node.js and Alpine version.

## [0.1.1] - 2022-09-17

- (`3bc7786`) Correctly scan `.cjs` and `.mjs` files.
- (`20b5b18`) Document the scanner's exit codes.
- (`f2f6242`) Update usage example to use the `--rm` flag.

## [0.1.0] - 2022-09-14

- (`7dfe68a`) Create a Docker-based static scanner to find problematic regular
  expressions in JavaScript code.

[keep a changelog]: https://keepachangelog.com/en/1.0.0/
[semantic versioning]: https://semver.org/spec/v2.0.0.html
