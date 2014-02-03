# frozen_string_literal: true

require 'stringio'
require_relative 'progress/version'
require_relative 'progress/bar'
require_relative 'progress/spinner'
require_relative 'progress/multi'

module Philiprehberger
  module Progress
    class Error < StandardError; end

    # Create and yield a progress bar
    #
    # @param total [Integer] total number of items
    # @param format [String] format string
    # @param width [Integer] bar width
    # @param output [IO] output stream
    # @yield [Bar] the progress bar
    # @return [Object] the block's return value
    def self.bar(total:, format: Bar::DEFAULT_FORMAT, width: Bar::DEFAULT_WIDTH, output: $stderr, &block)
      progress_bar = Bar.new(total: total, format: format, width: width, output: output)

      if block
        result = yield progress_bar
        progress_bar.finish unless progress_bar.finished?
        result
      else
        progress_bar
      end
    end

    # Create and yield a spinner
    #
    # @param message [String] message to display
    # @param frames [Symbol, Array<String>] frame set
    # @param output [IO] output stream
    # @yield the work to perform
    # @return [Object] the block's return value
    def self.spin(message = 'Loading...', frames: :default, output: $stderr, &block)
      spinner = Spinner.new(message: message, frames: frames, output: output)

      if block
        result = yield spinner
        spinner.done unless spinner.done?
        result
      else
        spinner
      end
    end

    # Create a multi-bar display
    #
    # @param output [IO] output stream
    # @return [Multi]
    def self.multi(output: $stderr)
      Multi.new(output: output)
    end
  end
end

# Enumerable integration
module Enumerable
  # Iterate with a progress bar
  #
  # @param message [String] label for the progress bar
  # @param output [IO] output stream
  # @yield [Object] each element
  # @return [Array]
  def each_with_progress(message = 'Processing', output: $stderr)
    items = to_a
    bar = Philiprehberger::Progress::Bar.new(
      total: items.length,
      format: ":bar :percent | #{message} | :current/:total",
      output: output
    )

    items.each do |item|
      yield item
      bar.advance
    end

    bar.finish
    items
  end
end
