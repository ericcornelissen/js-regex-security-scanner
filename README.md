# JavaScript Regex Security Scanner

A static analyzer to scan JavaScript and TypeScript code for problematic regular
expressions.

## Getting started

The scanner is available as a [Docker] image that you can run against any
JavaScript or TypeScript project - for example:

```shell
docker run --rm -v $(pwd):/project ericornelissen/js-re-scan:latest
```

### Ignore patterns

If necessary you can ignore certain files or directories using the option
`--ignore-pattern`. For example, to ignore vendored code to focus on problems
in your own project you can use:

```shell
docker run --rm -v $(pwd):/project ericornelissen/js-re-scan:latest  \
  --ignore-pattern vendor/
```

### Exit codes

The scanner has the following exit codes.

| Exit code | Meaning                                          |
| --------: | :----------------------------------------------- |
| 0         | No problems found                                |
| 1         | Files with problematic regular expressions found |
| 2         | Something went wrong while scanning              |

## Features

- Detect cases of exponential and polynomial backtracking.
- Detect super-linear worst-case runtime caused by a regex being moved across
  the input string.
- Ignore generated code based on standard file and folder patterns.
- Ignore tests based on standard file and folder patterns.
- Scan documentation.

## Build from source

If you want you can build the scanner from scratch using [Docker]. From the root
of this project run something like:

```shell
docker build . --tag js-regex-scanner
```

Or use the convenience [Make] target:

```shell
make build
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

## Behind the Scenes

This scanner runs [ESLint] with the [eslint-plugin-regexp] plugin to find and
report on regular expressions that violate rules with security implications.

TypeScript support is provided by [@typescript-eslint/parser], MarkDown support
is provided by [eslint-plugin-markdown].

## License

This project is licensed under the Apache 2.0 license, see [LICENSE] for the
full license text.

---

Please [open an issue] if you found a mistake or if you have a suggestion for
how to improve the documentation.

[@typescript-eslint/parser]: https://www.npmjs.com/package/@typescript-eslint/parser
[docker]: https://www.docker.com/
[eslint]: https://eslint.org/
[eslint-plugin-markdown]: https://www.npmjs.com/package/eslint-plugin-markdown
[eslint-plugin-regexp]: https://github.com/ota-meshi/eslint-plugin-regexp
[license]: ./LICENSE
[make]: https://www.gnu.org/software/make/
[open an issue]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=documentation&template=documentation.md
[redos-detector]: https://github.com/tjenkinson/redos-detector
