# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this gem adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-03-21

### Added
- Initial release
- `Bar` class with percentage, ETA, throughput, and customizable format
- `Spinner` class with multiple frame sets (default, braille, dots)
- `Multi` class for tracking multiple concurrent progress bars
- Convenience methods `Progress.bar`, `Progress.spin`, `Progress.multi`
- `Enumerable#each_with_progress` integration
- TTY detection to auto-disable rendering in non-terminal environments
