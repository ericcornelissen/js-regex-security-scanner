<!-- SPDX-License-Identifier: CC-BY-SA-4.0 -->

# JavaScript Regex Security Scanner

A static analyzer to scan JavaScript and TypeScript code for problematic regular
expressions.

## Getting started

The scanner is available as a container image, install it using:

```shell
docker pull docker.io/ericornelissen/js-re-scan:latest
```

Validate the container provenance using cosign (optional but recommended):

<!-- doctest:ignore -->

```shell
cosign verify \
  --certificate-identity-regexp \
    'https://github.com/ericcornelissen/js-regex-security-scanner/.+' \
  --certificate-oidc-issuer \
    'https://token.actions.githubusercontent.com' \
  docker.io/ericornelissen/js-re-scan:latest
```

Now you can use it to scan a JavaScript or TypeScript project. For example, to
scan the current directory:

```shell
docker run --rm -v $(pwd):/project docker.io/ericornelissen/js-re-scan:latest
```

To use [Podman] instead of [Docker] you can replace `docker` by `podman` in any
example command. To use the [GitHub Container Registry] instead of [Docker] hub
you can use `ghcr.io/ericcornelissen/js-re-scan` instead.

### Ignore patterns

If necessary you can ignore certain files or directories using the option
`--ignore-pattern`. For example, to ignore vendored code to focus on problems
in your own project you can use:

```shell
docker run --rm -v $(pwd):/project docker.io/ericornelissen/js-re-scan:latest  \
  --ignore-pattern vendor/
```

### Exit codes

The scanner has the following exit codes.

| Exit code | Meaning                                          |
| --------: | :----------------------------------------------- |
|         0 | No problems found                                |
|         1 | Files with problematic regular expressions found |
|         2 | Something went wrong while scanning              |

## Features

- Detect cases of exponential and polynomial backtracking.
- Detect super-linear worst-case runtime caused by a regex being moved across
  the input string.
- Ignore generated code based on standard file and folder patterns.
- Ignore tests based on standard file and folder patterns.
- Scan documentation.

## Trophies

The table below provides an overview of bugs and security advisories discovered
with the help of this scanner (from most to least recent). If you reported a bug
or advisory based on the results of this scanner, feel free to add it to the
list!

| Project              | Fix / Advisory               |
| -------------------- | ---------------------------- |
| [decamelize]         | [`e9e3041`]                  |
| [browserslist]       | [`c331c95`]                  |
| [st]                 | [#103][st-103]               |
| [@std/path]          | [#6764][@std/path-6764]      |
| [@eslint/markdown]   | [#463][@eslint/markdown-463] |
| [@eslint/plugin-kit] | [GHSA-xffm-g5w8-qvg7]        |
| [shescape]           | [CVE-2022-36064]             |

[`c331c95`]: https://github.com/browserslist/browserslist/commit/c331c95c6aaf77ab284d7e338e462ad74bb5081a
[`e9e3041`]: https://github.com/sindresorhus/decamelize/commit/e9e304170ecaaccc39d3696d7d816408c29eed71
[@eslint/markdown-463]: https://github.com/eslint/markdown/pull/463
[@eslint/plugin-kit]: https://www.npmjs.com/package/@eslint/plugin-kit
[@std/path]: https://jsr.io/@std/path
[@std/path-6764]: https://github.com/denoland/std/pull/6764
[browserslist]: https://www.npmjs.com/package/browserslist
[cve-2022-36064]: https://nvd.nist.gov/vuln/detail/CVE-2022-36064
[decamelize]: https://www.npmjs.com/package/decamelize
[ghsa-xffm-g5w8-qvg7]: https://github.com/advisories/GHSA-xffm-g5w8-qvg7
[shescape]: https://www.npmjs.com/package/shescape
[st]: https://www.npmjs.com/package/st
[st-103]: https://github.com/isaacs/st/pull/103

## Migrating to ESLint

If you have found this scanner helpful, consider using [eslint-plugin-regexp]
instead. This [ESLint] plugin is what powers the scanner, and it may integrate
better with your project's existing workflows.

Follow these steps to update your ESLint setup to cover what this scanner does:

1. Install the plugin:

   <!-- doctest:ignore -->

   ```shell
   npm install --save-dev eslint-plugin-regexp
   ```

1. Update your ESLint configuration:
   - ESLint v9 with flat config:

     ```javascript
     import regexp from "eslint-plugin-regexp";
     // ... other plugins you're already using

     export default [
       {
         files: ["**/*.{js,jsx,cjs,mjs,ts,cts,mts}"],
         plugins: {
           regexp,
         },
         rules: {
           "regexp/no-super-linear-backtracking": [
             "error",
             {
               report: "certain",
             },
           ],
           "regexp/no-super-linear-move": [
             "error",
             {
               ignorePartial: false,
               ignoreSticky: false,
               report: "certain",
             },
           ],
         },
       },
       // ... rest of your configuration
     ];
     ```

   - ESLint v8 and earlier _or_ legacy config:

     ```yaml
     # .eslintrc.yml or similar

     plugins:
       # ... other plugins you're already using
       - regexp

     rules:
       # ... other rules you already configured
       regexp/no-super-linear-backtracking:
         - error
         - report: certain
       regexp/no-super-linear-move:
         - error
         - ignorePartial: false
           ignoreSticky: false
           report: certain
     # ... rest of your configuration
     ```

     ```javascript
     // .eslintrc.json, .eslintrc.js or similar

     {
       "plugins": [
         // ... other plugins you're already using
         "regexp"
       ],
       "rules": {
         // ... other rules you already configured
         "regexp/no-super-linear-backtracking": [
           "error",
           {
             "report": "certain"
           }
         ],
         "regexp/no-super-linear-move": [
           "error",
           {
             "ignorePartial": false,
             "ignoreSticky": false,
             "report": "certain"
           }
         ]
       }
       // ... rest of your configuration
     }
     ```

## Build from source

If you want you can build the scanner from scratch. From the root of this
project run something like:

```shell
docker build --file Containerfile .
```

Or use the convenience [Make] target:

```shell
make build ENGINE=docker
```

## Philosophy

This scanner aims to provide developers with a tool to find vulnerable regular
expression in their code. As such, the goal is to only report _true positives_.
The result is that all findings are relevant, but a clean report does not mean
your project has no vulnerable regular expressions.

This is contrast to tools like [redos-detector], which will find vulnerable
regular expressions this scanner won't, but also reports _false positives_. As
it is difficult to determine if a particular report is a false positive, other
tools are hard to use.

## Behind the scenes

This scanner runs [ESLint] with the [eslint-plugin-regexp] plugin to find and
report on regular expressions that violate rules with security implications.

TypeScript support is provided by [@typescript-eslint/parser], MarkDown support
is provided by [@eslint/markdown].

## License

This project is licensed under the Apache 2.0 license, see [LICENSE] for the
full license text. The documentation text is licensed under [CC BY-SA 4.0].

---

Please [open an issue] if you found a mistake or if you have a suggestion for
how to improve the documentation.

[@eslint/markdown]: https://www.npmjs.com/package/@eslint/markdown
[@typescript-eslint/parser]: https://www.npmjs.com/package/@typescript-eslint/parser
[cc by-sa 4.0]: https://creativecommons.org/licenses/by-sa/4.0/
[docker]: https://www.docker.com/
[eslint]: https://eslint.org/
[eslint-plugin-regexp]: https://github.com/ota-meshi/eslint-plugin-regexp
[github container registry]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
[license]: ./LICENSE
[make]: https://www.gnu.org/software/make/
[open an issue]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=documentation&template=documentation.md
[podman]: https://podman.io/
[redos-detector]: https://github.com/tjenkinson/redos-detector
