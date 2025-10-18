# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2026-04-09

### Added
- `Bar#set(n)` to set absolute progress position
- `Bar#reset` to restart the bar from 0, preserving configuration
- `Spinner#message=` to update the spinner message dynamically

### Changed
- Standardize CHANGELOG header format to match template

## [0.3.0] - 2026-04-09

### Added
- `Spinner#auto_spin(interval: 0.1)` starts a background thread that animates the spinner until `stop` is called
- `Progress.map(enumerable) { |item| ... }` transforms items with a progress bar, returning the collected results

### Fixed
- Gemspec `required_ruby_version` format to `'>= 3.1.0'` (was `'>= 3.1'`)

## [0.2.0] - 2026-04-04

### Added
- Multi-bar support via `Philiprehberger::Progress::Multi` for tracking concurrent tasks
- `Progress.multi` convenience method
- GitHub issue template gem version field
- Feature request "Alternatives considered" field

### Fixed
- Gemspec author and email to match standard template

## [0.1.11] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.10] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.9] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format


## [0.1.8] - 2026-03-24

### Changed
- Expand test coverage to 55+ examples covering edge cases and error paths

## [0.1.7] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements

## [0.1.6] - 2026-03-24

### Fixed
- Fix Installation section quote style to double quotes

## [0.1.5] - 2026-03-23

### Fixed
- Standardize README to match template (installation order, code fences, license section, one-liner format)
- Update gemspec summary to match README description

## [0.1.4] - 2026-03-22

### Changed
- Fix README badges to match template (Tests, Gem Version, License)

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
