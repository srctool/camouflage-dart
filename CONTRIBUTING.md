# Contributing to camouflage-dart

Thanks for helping improve the Dart implementation of Camouflage!

## Getting started
- Install a recent Dart/Flutter SDK (e.g., Dart 3.x / Flutter 3.x as appropriate).
- Ensure `dart` (and `flutter` if applicable) is on your PATH.

## Development workflow
1. Fork and create a branch from `main`: `feat/<scope>-<short-desc>` or `fix/<scope>-<short-desc>`.
2. Implement your change.
3. Run formatting and static checks before committing:
   - Format: `dart format .`
   - Lint: `dart analyze` (or `flutter analyze` for Flutter packages)
   - Tests: `dart test` (or `flutter test`)
4. Update README/docs if behavior changes.
5. Open a Pull Request in the root repo targeting changes under `dart-lib/` and fill out the PR template.

## Testing
- Add/adjust unit tests to cover new or changed behavior.
- Ensure tests pass locally (`dart test` or `flutter test`).

## Commit & PR guidelines
- Write clear commit messages and PR descriptions; link issues (e.g., "Fixes #123").
- Keep PRs focused and reasonably small.
- Include screenshots/logs/GIFs for visible or behavioral changes when helpful.

## Code of Conduct
This project adheres to the Contributor Covenant.
See CODE_OF_CONDUCT.md. For sensitive reports, email contact@srctool.org.

## License
Contributions to `camouflage-dart` are made under the Apache 2.0 license found in LICENSE.

Thank you for contributing!