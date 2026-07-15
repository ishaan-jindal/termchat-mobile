# Contributing to termchat-mobile

Thank you for your interest in contributing to termchat-mobile!

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Making Changes](#making-changes)
- [Style Guidelines](#style-guidelines)
- [Testing](#testing)
- [Pull Request Process](#pull-request-process)
- [Questions?](#questions)

## Code of Conduct

This project is governed by the [Contributor Covenant](https://www.contributor-covenant.org/version/2/1/code_of_conduct/). By participating, you are expected to uphold this code.

## Getting Started

1. **Open an Issue** — Before submitting a Pull Request, please open a corresponding issue to discuss your proposed changes.
2. **Fork the repository** on GitHub.
3. **Clone your fork** to your local machine.
4. **Create a new branch** — Use a descriptive name like `feat/amazing-feature` or `fix/bug-description`.

## Development Setup

### Prerequisites

- **Flutter** (stable channel) — [Install](https://docs.flutter.dev/get-started/install)
- **Dart** (bundled with Flutter)
- **Android Studio / Xcode** — for running on device/emulator

### Setup

```bash
# Get dependencies
flutter pub get

# Run code generation (if you changed models or DI)
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

## Project Structure

```
lib/
  core/           — Theme, router, constants, shared widgets
  data/           — Backend DTOs (JSON models)
  features/       — Feature modules, each with:
    <feature>/
      bloc/       — BLoC events, states, and logic
      pages/      — UI screens
      widgets/    — Reusable widgets for this feature
      repositories/ — Data access layer
  di/             — Dependency injection (GetIt + Injectable)
```

Each feature is organized around the BLoC pattern: Event → BLoC → State → UI.

## Making Changes

### What to Work On

Check [open issues](https://github.com/ishaan-jindal/termchat-mobile/issues) for `good first issue` or `help wanted` labels.

### Commit Messages

Write clear, concise commit messages:

```
feat: add copy room code button to chat top bar
fix: handle WebSocket reconnection timeout
refactor: extract notification helper
```

## Style Guidelines

- Run `flutter analyze` and fix all warnings before committing.
- Follow the [Flutter style guide](https://docs.flutter.dev/style-guide).
- Use `snake_case` for file and directory names.
- Use `lowerCamelCase` for variables, methods, and parameters.
- Use `UpperCamelCase` for types and classes.
- Keep widgets focused — extract reusable widgets when a build method exceeds ~100 lines.
- Prefer `const` constructors where possible.
- Use `@injectable` / `@lazySingleton` for services registered with GetIt.

## Testing

```bash
# Run all tests
flutter test

# Run tests for a specific feature
flutter test test/features/chat/

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

We use `mocktail` for mocking. See existing test files in `test/` for patterns.

## Pull Request Process

1. Ensure your code passes `flutter analyze` with no warnings.
2. Run `flutter test` and ensure all tests pass. Add tests for new functionality.
3. If you changed models or DI, run code generation and commit the generated files.
4. Reference the issue number in your PR description (e.g., `Fixes #123`).
5. Provide a clear, concise description of your changes.
6. Wait for feedback and address any requested changes.

## Questions?

Open a [discussion](https://github.com/ishaan-jindal/termchat-mobile/discussions) or ask in the issue you're working on.
