# Contributing to camouflage-dart

Thanks for helping improve the Dart implementation of Camouflage!

## Getting started
- Install a recent Dart/Flutter SDK (e.g., Dart 3.x / Flutter 3.x as appropriate).
- Ensure `dart` (and `flutter` if applicable) is on your PATH.
- Recommended: run `dart --version` or `flutter --version` to confirm setup.

## Development workflow
1. Fork the repo and create a branch from `develop` (integration branch).
   - Suggested: `feat/<scope>-<short-desc>` or `fix/<scope>-<short-desc>`
2. Implement your change with small, focused commits.
3. Before committing, run formatting and checks:
   - Format: `dart format .`
   - Lint: `dart analyze` (or `flutter analyze`)
   - Tests: `dart test` (or `flutter test`)
4. Update README/docs if behavior changes.
5. Open a Pull Request in the root repo targeting `develop` (files under `dart-lib/`) and fill out the PR template.

### PR title format (Conventional Commits)
Format your PR title as:

```
<type>(<scope>): <short description>
```

- type: one of `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- scope: the affected package/directory (e.g., `dart-lib`, `parser`, `cli`)
- short description: concise summary

Examples:
- feat(dart-lib): support JSON5 in ConfigLoader
- fix(dart-lib): avoid late initialization error in cache

GitKraken tip: GitKraken uses the first line of the commit message as the PR title. You can copy the PR title format directly when committing.

## Merging policy
- Upstream repository: Squash and merge only on protected branches `main` and `develop`. Merge commits and rebase merges are not used on those branches.
- Forks: You may use any workflow/merge strategy in your own fork. When proposing changes upstream, the final merge into `main`/`develop` will be squashed.
- The final squashed commit title is taken from the PR title; the body is taken from the PR description.
- Keep the PR title in Conventional Commits format and ensure the description explains the "what" and "why`. Maintainers may edit the final message for clarity.

## Testing
- Add/adjust unit tests to cover new or changed behavior.
- Ensure tests pass locally (`dart test` or `flutter test`).
- Prefer hermetic tests; mock file system, network, and time when needed.

## Commit & PR guidelines
- Write clear commit messages and PR descriptions; link issues (e.g., "Fixes #123").
- Keep PRs focused and reasonably small.
- Include screenshots/logs/GIFs for visible or behavioral changes when helpful.

## Code of Conduct
This project adheres to the Contributor Covenant.
See `CODE_OF_CONDUCT.md`. For sensitive reports, email contact@srctool.org.

## License
Contributions to `camouflage-dart` are made under the Apache 2.0 license found in `LICENSE`.

Thank you for contributing!