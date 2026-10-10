# Contributing to camouflage-dart

Thanks for helping improve the Dart implementation of Camouflage! This repository uses **trunk-based development**, like the rest of the Camouflage repositories: `main` is the only long-lived branch, every change reaches it through a squash-merged pull request, and releases are tags on `main`. The shared rules are on the [Git workflow](https://camouflage-dev.srctool.com/contributing/git-workflow) page.

## Getting started
- The Flutter SDK (stable) with its Dart SDK; the packages are a pub workspace managed with Melos.
- `flutter --version` confirms the setup.

## Development workflow
1. Branch from the latest `main`, named `<type>/<short-description>` (for example `feat/date-picker-typing`, `fix/snackbar-overlap`).
   - Maintainers push branches to `srctool/camouflage-dart`; everyone else forks it.
2. Make small, focused commits.
3. Before opening the PR, run:
- Format: `dart format .`
- Analyze: `flutter analyze`
- Tests: `flutter test` in the package you changed (or `melos run test` for all).
4. Update the README or docs if behavior changes.
5. Open a pull request **into `main` of this repository** and fill out the template. If `main` moves while it's open, update your branch (`git pull --rebase origin main`, or the PR's **Update branch** button).

### PR title format (Conventional Commits)
Format your PR title as:

```
<type>(<scope>): <short description>
```

- type: one of `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- scope: the affected module or package (for example `camouflage_core`, `camouflage_skin_minimal`, or `ci`)
- short description: a concise summary

GitKraken tip: GitKraken uses the first line of the commit message as the PR title, so you can use this format when committing.

## Merging policy
- Squash and merge only, into the protected `main`. Merge commits and rebase merges aren't used, and nobody pushes or force-pushes to `main` directly.
- The squashed commit's title is the PR title and its body is the PR description, so keep both clear: what changed and why. Maintainers may edit the final message.
- Branches are deleted automatically after the merge.

## Releases
A release is a tag on `main`: `<package>-vX.Y.Z`, one tag per package (for example `camouflage_core-v0.3.0`).

```bash
git switch main && git pull
git tag camouflage_core-v0.3.0 && git push origin camouflage_core-v0.3.0
```

The publish workflow checks the tag is on `main`, publishes that package to pub.dev through automated publishing (GitHub OIDC, no stored secrets), then creates the GitHub Release. It stops if the package's `pubspec.yaml` version doesn't match the tag. Tag `camouflage_core` first and wait for it to publish before tagging a skin.

Before tagging, merge a PR that updates the version and `CHANGELOG.md`. A fix to a released version is an ordinary PR into `main` followed by a patch tag. After a release, the umbrella repository (`srctool/camouflage`) picks up the new commit through its Dependabot submodule PR.

## Testing
- Add or adjust tests for new or changed behavior, and make sure they pass locally.
- Prefer hermetic tests; mock the file system, network and time when needed.

## Commit & PR guidelines
- Write clear commit messages and PR descriptions; link issues (for example "Fixes #123").
- Keep PRs focused and reasonably small.
- Include screenshots or logs for visible or behavioral changes when helpful.

## Code of Conduct
This project adheres to the Contributor Covenant.
See `CODE_OF_CONDUCT.md`. For sensitive reports, email contact@srctool.com.

## License
Contributions to `camouflage-dart` are made under the Apache 2.0 license found in `LICENSE`.

Thank you for contributing!
