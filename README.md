# philiprehberger-progress

[![Tests](https://github.com/philiprehberger/rb-progress/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-progress/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-progress.svg)](https://rubygems.org/gems/philiprehberger-progress)
[![License](https://img.shields.io/github/license/philiprehberger/rb-progress)](LICENSE)

Terminal progress bars and spinners with ETA calculation and throughput display

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem 'philiprehberger-progress'
```

Or install directly:

```bash
gem install philiprehberger-progress
```

## Usage

### Progress Bar

```ruby
require 'philiprehberger/progress'

Philiprehberger::Progress.bar(total: 100) do |bar|
  100.times do
    sleep(0.01)
    bar.advance
  end
end
```

### Custom Format

```ruby
bar = Philiprehberger::Progress::Bar.new(
  total: 100,
  format: ':bar :percent | :current/:total | :rate items/s | ETA: :eta',
  width: 30
)
bar.advance(50)
puts bar.to_s
```

### Spinner

```ruby
Philiprehberger::Progress.spin('Loading...') do |spinner|
  10.times do
    sleep(0.1)
    spinner.spin
  end
end
```

### Enumerable Integration

```ruby
items = (1..100).to_a
items.each_with_progress('Processing') do |item|
  sleep(0.01)
end
```

### Multi-Bar

```ruby
multi = Philiprehberger::Progress.multi
bar1 = multi.bar('Downloads', total: 100)
bar2 = multi.bar('Uploads', total: 50)

bar1.advance(10)
bar2.advance(5)
multi.render
```

## API

### `Philiprehberger::Progress`

| Method | Description |
|--------|-------------|
| `.bar(total:, format:, width:)` | Create a progress bar (yields if block given) |
| `.spin(message, frames:)` | Create a spinner (yields if block given) |
| `.multi` | Create a multi-bar display |

### `Philiprehberger::Progress::Bar`

| Method | Description |
|--------|-------------|
| `.new(total:, format:, width:)` | Create a progress bar |
| `#advance(n)` | Advance by `n` items (default: 1) |
| `#finish` | Mark as complete |
| `#finished?` | Whether the bar is finished |
| `#percentage` | Current percentage (0.0 to 100.0) |
| `#elapsed` | Elapsed time in seconds |
| `#eta` | Estimated time remaining in seconds |
| `#rate` | Throughput in items per second |
| `#to_s` | Render the bar as a string |

### `Philiprehberger::Progress::Spinner`

| Method | Description |
|--------|-------------|
| `.new(message:, frames:)` | Create a spinner |
| `#spin` | Advance to the next frame |
| `#done(message)` | Mark as done with optional message |
| `#done?` | Whether the spinner is done |
| `#to_s` | Render the current frame |

### `Philiprehberger::Progress::Multi`

| Method | Description |
|--------|-------------|
| `.new` | Create a multi-bar display |
| `#bar(label, total:)` | Add a new progress bar |
| `#render` | Render all bars |
| `#size` | Number of bars |
| `#finished?` | Whether all bars are finished |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
