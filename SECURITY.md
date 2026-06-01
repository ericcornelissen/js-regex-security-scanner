<!-- SPDX-License-Identifier: CC0-1.0 -->

# Security Policy

The maintainers of the _JavaScript Regex Security Scanner_ project take security
issues seriously. We appreciate your efforts to responsibly disclose your
findings. Due to the non-funded and open-source nature of the project, we take a
best-efforts approach when it comes to engaging with security reports.

This document should be considered expired after 2027-01-01. If you are reading
this after that date, try to find an up-to-date version in the official source
repository.

## Supported Versions

The table below shows which versions of the project are currently supported with
security updates.

| Version | End-of-life |
| ------: | :---------- |
|   0.x.x | -           |

## Reporting a Vulnerability

To report a security issue in a supported version or the development head of the
project, either (in order of preference):

- [Report it through GitHub][new github advisory], or
- Send an email to [ericornelissen+security@gmail.com] with the terms "SECURITY"
  and "js-regex-security-scanner" in the subject line.

Please do not open a regular issue or Pull Request in the public repository.

If a security issue only affects an unsupported version of the project, or the
latest version of a supported version range is not affected, please report it
publicly. For example, as a regular issue in the public repository. If in doubt,
report the issue privately.

[new github advisory]: https://github.com/ericcornelissen/js-regex-security-scanner/security/advisories/new
[ericornelissen+security@gmail.com]: mailto:ericornelissen+security@gmail.com?subject=SECURITY%20%28js-regex-security-scanner%29

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

## Threat Model

The scanner considers Docker, ESLint, and its plugins to be trusted. All inputs
are considered untrusted. Any violation of confidentiality, integrity, and
availability is considered a security issue.

The project considers the GitHub infrastructure and all project maintainers to
be trusted. Any action performed on the repository by any other GitHub user is
considered untrusted.

## Advisories

An advisory will be created only if a vulnerability affects at least one
released versions of the project. The affected versions range of an advisory
will by default include all unsupported versions of the project at the time of
disclosure.

All advisories are listed in the table below, ordered most to least recent by
publication date.

| ID  | Date | Affected version(s) | Patched version(s) |
| :-- | :--- | :------------------ | :----------------- |
| -   | -    | -                   | -                  |

## Acknowledgments

If you conduct a security audit of this project we would like to acknowledge it.
If you found a security issue, you will be credited in the advisory. If you find
nothing but the audit report is publicly available we will acknowledge it too.

We would like to publicly thank the following reporters:

- _None yet_
