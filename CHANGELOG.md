# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2020-10-22
### Changed
- Dependency on crashlytics has been removed, and TBOOMDetector must now be passed a block that will be called to determine if the last session crashed.
- Minimum iOS version has changed to 10.0.
- Code is now formatted with Clang Format using pre-commit hooks.
- Removed cocoapods from demo app.
