<!-- SPDX-License-Identifier: CC0-1.0 -->

# Security Policy

The maintainers of the _JavaScript Regex Security Scanner_ project take security
issues seriously. We appreciate your efforts to responsibly disclose your
findings. Due to the non-funded and open-source nature of the project, we take a
best-efforts approach when it comes to engaging with security reports.

This document should be considered expired after 2026-06-01. If you are reading
this after that date you should try to find an up-to-date version in the
official source repository.

## Supported Versions

The table below shows which versions of the project are currently supported
with security updates.

| Version | End-of-life |
| ------: | :---------- |
|   0.x.x | -           |

## Reporting a Vulnerability

To report a security issue in the latest version of a supported version range,
either:

- [Report it through GitHub][new github advisory], or
- Send an email to [security@ericcornelissen.dev] with the terms "SECURITY" and
  "js-re-scan" in the subject line.

Please do not open a regular issue or Pull Request in the public repository.

To report a security issue in an unsupported version of the project, or if the
latest version of a supported version range isn't affected, please report it
publicly. For example, as a regular issue in the public repository. If in doubt,
report the issue privately.

[new github advisory]: https://github.com/ericcornelissen/js-regex-security-scanner/security/advisories/new
[security@ericcornelissen.dev]: mailto:security@ericcornelissen.dev?subject=SECURITY%20%28js-re-scan%29

### What to Include in a Report

Try to include as many of the following items as possible in a security report:

- An explanation of the issue
- A proof of concept exploit
- A suggested severity
- Relevant [CWE] identifiers
- The latest affected version
- The earliest affected version
- A suggested patch
- An automated regression test

[cwe]: https://cwe.mitre.org/

### Threat Model

The scanner considers Docker, ESLint, and its plugins to be trusted. All inputs
are considered untrusted. Any violation of confidentiality, integrity, and
availability is considered a security issue.

The project considers the GitHub infrastructure and all project maintainers to
be trusted. Any action performed on the repository by any other GitHub user is
considered untrusted.

## Advisories

> **NOTE:** Advisories will be created only for vulnerabilities present in
> released versions of the project.

| ID  | Date | Affected versions | Patched versions |
| :-- | :--- | :---------------- | :--------------- |
| -   | -    | -                 | -                |

_This table is ordered most to least recent._

## Acknowledgments

We would like to publicly thank the following reporters:

- _None yet_
