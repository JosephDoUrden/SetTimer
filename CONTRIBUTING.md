# Contributing to SetTimer

We welcome contributions to SetTimer! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/settimer.git`
3. Create a new branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Test your changes thoroughly
6. Commit with a clear message: `git commit -m "Add: description of your feature"`
7. Push to your fork: `git push origin feature/your-feature-name`
8. Create a Pull Request

## Development Setup

### Prerequisites
- Flutter SDK 3.0.0 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code
- Git

### Installation
```bash
# Clone the repository
git clone https://github.com/JosephDoUrden/settimer.git
cd settimer

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Building for Release
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Code Style

- Follow [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Keep functions small and focused
- Use proper error handling

### Linting
Run the linter before submitting:
```bash
flutter analyze
```

## Testing

- Write tests for new features
- Ensure existing tests pass
- Test on both Android and iOS when possible

```bash
# Run tests
flutter test
```

## Commit Messages

Use clear, descriptive commit messages:
- `Add: new feature description`
- `Fix: bug description`
- `Update: change description`
- `Remove: deletion description`
- `Refactor: code improvement description`

## Pull Request Guidelines

1. **One feature per PR**: Keep PRs focused on a single feature or fix
2. **Clear description**: Explain what your PR does and why
3. **Test your changes**: Ensure your code works as expected
4. **Update documentation**: Update README or comments if needed
5. **Follow the style guide**: Maintain consistent code style

### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Added/updated tests

## Screenshots (if applicable)
[Add screenshots here]
```

## Feature Requests

- Check existing issues first
- Create a detailed issue describing the feature
- Explain the use case and benefit
- Be patient - we review all requests

## Bug Reports

When reporting bugs, include:
- Device/platform information
- Steps to reproduce
- Expected vs actual behavior
- Screenshots/recordings if helpful
- Relevant logs or error messages

## Project Structure

```
lib/
├── controllers/     # Business logic controllers
├── models/         # Data models
├── services/       # External services and utilities
├── views/          # UI screens
├── widgets/        # Reusable UI components
└── main.dart       # App entry point

assets/
└── sounds/         # Audio files for different themes

android/            # Android-specific configurations
ios/                # iOS-specific configurations
```

## Development Roadmap

See [BACKLOG_V2.md](BACKLOG_V2.md) for planned features and development timeline.

## Questions?

- Check existing [Issues](https://github.com/JosephDoUrden/settimer/issues)
- Start a [Discussion](https://github.com/JosephDoUrden/settimer/discussions)
- Read the [README](README.md) for basic information

## License

By contributing, you agree that your contributions will be licensed under the MIT License.

Thank you for contributing to SetTimer! 🏋️‍♂️ 