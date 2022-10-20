# JavaScript Regex Security Scanner

A static analyzer to scan JavaScript code for problematic regular expressions.

## Getting started

The scanner is available as a [Docker] image that you can run against any
JavaScript project - for example:

```shell
docker run --rm -v $(pwd):/project ericornelissen/js-re-scan:latest
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

## About

This scanner runs [ESLint] with the [eslint-plugin-regexp] plugin to find and
report on regular expressions that violate rules with security implications.

## License

This project is licensed under the Apache 2.0 license, see [LICENSE] for the
full license text.

---

Please [open an issue] if you found a mistake or if you have a suggestion for
how to improve the documentation.

[docker]: https://www.docker.com/
[eslint]: https://eslint.org/
[eslint-plugin-regexp]: https://github.com/ota-meshi/eslint-plugin-regexp
[license]: ./LICENSE
[open an issue]: https://github.com/ericcornelissen/js-regex-security-scanner/issues/new?labels=documentation&template=documentation.md
