<!-- SPDX-License-Identifier: CC0-1.0 -->
<!-- doctest:ignore-file -->

# Release Guidelines

If you need to release a new version of the _JavaScript Regex Security Scanner_,
follow the guidelines found in this document.

## Automated Releases (Preferred)

To release a new version follow these steps:

1. [Manually trigger] the [release workflow] from the `main` branch; Use an
   update type in accordance with [Semantic Versioning]. This will create a Pull
   Request that start the release process.
1. Follow the instructions in the description of the created Pull Request.

## Manual Releases (Discouraged)

If it's not possible to use automated releases, or if something goes wrong with
the automatic release process, follow these steps to release a new version
(using `v0.1.2` as an example):

1. Make sure that your local copy of the repository is up-to-date, sync:

   ```shell
   git checkout main
   git pull origin main
   ```

   Or clone:

   ```shell
   git clone git@github.com:ericcornelissen/js-regex-security-scanner.git
   ```

1. Update the `version` label in the `Containerfile` using:

   ```shell
   node scripts/bump-version.js [patch|minor|major]
   ```

   If that fails, manually update the `version` label in the `Containerfile`:

   ```diff
   -  version="0.1.1" \
   +  version="0.1.2" \
   ```

1. Update the changelog:

   ```shell
   node scripts/bump-changelog.js
   ```

   If that fails, manually add the following text after the `## [Unreleased]`
   line:

   ```markdown
   - _No changes yet_

   ## [0.1.2] - YYYY-MM-DD
   ```

   The date should follow the year-month-day format where single-digit months
   and days should be prefixed with a `0` (e.g. `2022-01-01`).

1. Commit the changes to a new release branch and push using:

   ```shell
   git checkout -b release-$(sha1sum Containerfile | awk '{print $1}')
   git add CHANGELOG.md Containerfile
   git commit --message "Version bump"
   git push origin release-$(sha1sum Containerfile | awk '{print $1}')
   ```

1. Create a Pull Request to merge the release branch into `main`.

1. Merge the Pull Request if the changes look OK and all continuous integration
   checks are passing.

   > **NOTE:** At this point, the continuous delivery automation may kick in and
   > complete the release process. If not, or only partially, continue following
   > the remaining steps.

1. Immediately after the Pull Request is merged, sync the `main` branch:

   ```shell
   git checkout main
   git pull origin main
   ```

1. Create a [git tag] for the new version:

   ```shell
   git tag v0.1.2
   ```

   and push it:

   ```shell
   git push origin v0.1.2
   ```

1. Update the `v0` branch to point to the same commit as the new tag:

   ```shell
   git checkout v0
   git merge main
   ```

   and push it:

   ```shell
   git push origin v0
   ```

1. Publish to [Docker Hub], first with a version tag:

   ```shell
   make build TAG=v0.1.2
   docker push docker.io/ericornelissen/js-re-scan:v0.1.2
   ```

   then the `latest` tag:

   ```shell
   make build TAG=latest
   docker push docker.io/ericornelissen/js-re-scan:latest
   ```

1. Publish to [GitHub Container Registry], first with a version tag:

   ```shell
   make build TAG=v0.1.2
   docker push ghcr.io/ericcornelissen/js-re-scan:v0.1.2
   ```

   then the `latest` tag:

   ```shell
   make build TAG=latest
   docker push ghcr.io/ericcornelissen/js-re-scan
   ```

[docker hub]: https://hub.docker.com/
[git tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging
[github container registry]: https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry
[manually trigger]: https://docs.github.com/en/actions/managing-workflow-runs/manually-running-a-workflow
[release workflow]: ./.github/workflows/release.yml
[semantic versioning]: https://semver.org/spec/v2.0.0.html
