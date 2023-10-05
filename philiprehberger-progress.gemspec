# frozen_string_literal: true

require_relative 'lib/philiprehberger/progress/version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-progress'
  spec.version = Philiprehberger::Progress::VERSION
  spec.authors = ['philiprehberger']
  spec.email = ['philiprehberger@users.noreply.github.com']

  spec.summary = 'Terminal progress bars and spinners with ETA calculation and throughput display'
  spec.description = 'Display progress bars with percentage, ETA, and throughput, or spinners for ' \
                     'indeterminate tasks. Supports block-based usage, enumerable iteration, ' \
                     'and auto-disables rendering when not connected to a terminal.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-progress'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/philiprehberger/rb-progress'
  spec.metadata['changelog_uri'] = 'https://github.com/philiprehberger/rb-progress/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/philiprehberger/rb-progress/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
