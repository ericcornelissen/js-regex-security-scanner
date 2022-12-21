# Release Guidelines

If you need to release a new version of _JavaScript Regex Security Scanner_,
follow the guidelines found in this document.

Follow these steps to release a new version (using `v0.1.2` as an example):

1. Make sure that your local copy of the repository is up-to-date, sync:

   ```shell
   git checkout main
   git pull origin main
   ```

   Or clone:

   ```shell
   git clone git@github.com:ericcornelissen/js-regex-security-scanner.git
   ```

1. Update the version number in the [npm] manifest and lockfile:

   ```shell
   npm version --no-git-tag-version v0.1.2
   ```

   If that fails, change the value of the version field in `package.json` to the
   new version:

   ```diff
   -  "version": "0.1.1",
   +  "version": "0.1.2",
   ```

   and update the version number in `package-lock.json` using `npm install`
   (after updating `package.json`), which will sync the version number.

1. Manually update the `version` label in the `Dockerfile`.

   ```diff
   -  version="0.1.1" \
   +  version="0.1.2" \
   ```

1. Manually add the following text after the `## [Unreleased]` line:

   ```markdown
   - _No changes yet_

   ## [0.1.2] - YYYY-MM-DD
   ```

   The date should follow the year-month-day format where single-digit months
   and days should be prefixed with a `0` (e.g. `2022-01-01`).

1. Commit the changes to a new release branch and push using:

   ```shell
   git checkout -b release-$(sha1sum package-lock.json | awk '{print $1}')
   git add CHANGELOG.md Dockerfile package.json package-lock.json
   git commit --message "Version bump"
   git push origin release-$(sha1sum package-lock.json | awk '{print $1}')
   ```

1. Create a Pull Request to merge the release branch into `main`.

1. Merge the Pull Request if the changes look OK and all continuous integration
   checks are passing.

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

   > **Note**: At this point, the continuous delivery automation may kick in and
   > complete the release process. If not, or only partially, continue following
   > the remaining steps.

1. Update the `v0` branch to point to the same commit as the new tag:

   ```shell
   git checkout v0
   git merge main
   ```

   and push it:

   ```shell
   git push origin v0
   ```

1. Publish to [Docker], first with a version tag:

   ```shell
   make build TAG=v0.1.2
   docker push ericornelissen/js-re-scan:v0.1.2
   ```

   then the `latest` tag:

   ```shell
   make build TAG=latest
   docker push ericornelissen/js-re-scan:latest
   ```

[docker]: https://www.docker.com/
[git tag]: https://git-scm.com/book/en/v2/Git-Basics-Tagging
[npm]: https://www.npmjs.com/
