# frozen_string_literal: true

require_relative 'progress/version'
require_relative 'progress/bar'
require_relative 'progress/spinner'
require_relative 'progress/multi'

module Philiprehberger
  module Progress
    @json_mode = false

    def self.json_mode!
      @json_mode = true
    end

    def self.text_mode!
      @json_mode = false
    end

    def self.json_mode?
      @json_mode
    end

    def self.bar(total:, width: 30, output: $stderr, fill: '=', empty: ' ', tip: '>')
      progress_bar = Bar.new(total: total, width: width, output: output, fill: fill, empty: empty, tip: tip)

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

    def self.multi(output: $stderr)
      m = Multi.new(output: output)
      if block_given?
        yield m
        m
      else
        m
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

    def self.map(enumerable, label: nil, output: $stderr)
      items = enumerable.to_a
      bar = Bar.new(total: items.length, output: output)

      results = items.map do |item|
        result = yield item
        bar.advance
        result
      end

      bar.finish
      results
    end
  end
end
