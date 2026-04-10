# philiprehberger-progress

[![Tests](https://github.com/philiprehberger/rb-progress/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-progress/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-progress.svg)](https://rubygems.org/gems/philiprehberger-progress)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-progress)](https://github.com/philiprehberger/rb-progress/commits/main)

Terminal progress bars and spinners with ETA calculation and throughput display

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-progress"
```

Or install directly:

```bash
gem install philiprehberger-progress
```

## Usage

### Progress Bar

```ruby
require "philiprehberger/progress"

bar = Philiprehberger::Progress::Bar.new(total: 100)
100.times do
  sleep(0.01)
  bar.advance
end
bar.finish
# [████████████████████████████████] 100.0% | 100/100 | ETA: 0s | 100.0/s
```

### Block Usage

```ruby
Philiprehberger::Progress.bar(total: 100) do |bar|
  100.times { bar.advance }
end
# Auto-finishes when block completes
```

### Spinner

```ruby
spinner = Philiprehberger::Progress::Spinner.new(message: 'Loading...')
10.times do
  sleep(0.1)
  spinner.spin
end
spinner.stop('done')
```

### Block Spinner

```ruby
Philiprehberger::Progress.spin('Processing...') do |spinner|
  10.times { spinner.spin; sleep(0.1) }
end
```

### Auto-spinning

Start a background thread that animates the spinner automatically:

```ruby
Philiprehberger::Progress.spin("Deploying...") do |spinner|
  spinner.auto_spin
  deploy!  # spinner animates while you work
end
```

The thread is joined automatically when `stop` is called (or when the block completes).

### Enumerable Integration

```ruby
items = (1..100).to_a
Philiprehberger::Progress.each(items) do |item|
  sleep(0.01)
end
```

### Mapping with Progress

Transform items while displaying progress:

```ruby
results = Philiprehberger::Progress.map(urls) { |url| fetch(url) }
# results contains the return values from each block call
```

### Multi-bar

```ruby
require "philiprehberger/progress"

multi = Philiprehberger::Progress.multi do |m|
  downloads = m.add("Downloads", total: 100)
  uploads   = m.add("Uploads", total: 50)

  100.times { downloads.advance }
  50.times { uploads.advance }
end

multi.finished?  # => true
```

## API

### `Philiprehberger::Progress::Bar`

| Method | Description |
|--------|-------------|
| `.new(total:, width: 30, output: $stderr)` | Create a progress bar |
| `#advance(n = 1)` | Advance by `n` items |
| `#set(n)` | Set absolute progress position (clamped to 0..total) |
| `#reset` | Reset to 0, clear finished state, restart timer |
| `#finish` | Mark as complete |
| `#finished?` | Whether the bar is finished |
| `#percentage` | Current percentage (0.0 to 100.0) |
| `#elapsed` | Elapsed time in seconds |
| `#eta` | Estimated time remaining in seconds |
| `#throughput` | Items per second |
| `#to_s` | Render the bar as a string |

### `Philiprehberger::Progress::Spinner`

| Method | Description |
|--------|-------------|
| `.new(message:, output: $stderr)` | Create a spinner |
| `#message=` | Update the spinner message dynamically |
| `#spin` | Advance to the next frame |
| `#auto_spin(interval: 0.1)` | Start background thread animation |
| `#stop(final_message = 'done')` | Stop with a message (joins background thread) |
| `#stopped?` | Whether the spinner is stopped |
| `#to_s` | Render the current frame with message |

### `Philiprehberger::Progress::Multi`

| Method | Description |
|--------|-------------|
| `Multi.new(output: $stderr)` | Create multi-bar tracker |
| `Multi#add(label, total:, width: 30)` | Add a named progress bar |
| `Multi#[](label)` | Retrieve a bar by label |
| `Multi#labels` | List of bar labels in order |
| `Multi#bars` | Hash of label to bar |
| `Multi#finished?` | True when all bars are finished |
| `Multi#render` | Render all bars to output |
| `Multi#reset` | Clear all bars |

### Module Methods

| Method | Description |
|--------|-------------|
| `Progress.bar(total:, &block)` | Create bar, auto-finish after block |
| `Progress.spin(message, &block)` | Create spinner, auto-stop after block |
| `Progress.multi(output: $stderr, &block)` | Create multi-bar tracker |
| `Progress.each(enumerable, label: nil) { \|item\| }` | Iterate with progress |
| `Progress.map(enumerable, label: nil) { \|item\| }` | Transform with progress, returns results |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-progress)

🐛 [Report issues](https://github.com/philiprehberger/rb-progress/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-progress/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
