# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.3] - 2026-03-22

### Added
- Expanded test suite from 23 to 30+ examples covering percentage edge cases, advance-after-finish, total=1, throughput, spinner frame cycling, and convenience method coverage

## [0.1.2] - 2026-03-22

### Fixed

- Fix CHANGELOG header wording
- Add bug_tracker_uri to gemspec

## [0.1.0] - 2026-03-22

### Added

- `Bar` class with percentage, ETA, throughput, and progress visualization
- `Spinner` class with braille frame animation
- `Progress.bar` convenience method with block support and auto-finish
- `Progress.spin` convenience method with block support
- `Progress.each` for iterating enumerables with progress display
- TTY detection to auto-disable rendering in non-terminal environments
