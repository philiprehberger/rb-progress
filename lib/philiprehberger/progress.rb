# frozen_string_literal: true

require_relative 'progress/version'
require_relative 'progress/bar'
require_relative 'progress/spinner'

module Philiprehberger
  module Progress
    def self.bar(total:, width: 30, output: $stderr)
      progress_bar = Bar.new(total: total, width: width, output: output)

      if block_given?
        result = yield progress_bar
        progress_bar.finish unless progress_bar.finished?
        result
      else
        progress_bar
      end
    end

    def self.spin(message, output: $stderr)
      spinner = Spinner.new(message: message, output: output)

      if block_given?
        result = yield spinner
        spinner.stop unless spinner.stopped?
        result
      else
        spinner
      end
    end

    def self.each(enumerable, label: nil, output: $stderr)
      items = enumerable.to_a
      bar = Bar.new(total: items.length, output: output)

      items.each do |item|
        yield item
        bar.advance
      end

      bar.finish
      items
    end
  end
end
