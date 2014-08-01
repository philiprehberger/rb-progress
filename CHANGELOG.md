# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-22

### Added

- `Bar` class with percentage, ETA, throughput, and progress visualization
- `Spinner` class with braille frame animation
- `Progress.bar` convenience method with block support and auto-finish
- `Progress.spin` convenience method with block support
- `Progress.each` for iterating enumerables with progress display
- TTY detection to auto-disable rendering in non-terminal environments
