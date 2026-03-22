# frozen_string_literal: true

module Philiprehberger
  module Progress
    # Multi-bar progress display for tracking multiple concurrent tasks
    #
    # @example
    #   multi = Multi.new
    #   bar1 = multi.bar('Downloads', total: 100)
    #   bar2 = multi.bar('Uploads', total: 50)
    class Multi
      # Create a new multi-bar display
      #
      # @param output [IO] output stream (default: $stderr)
      def initialize(output: $stderr)
        @output = output
        @bars = []
      end

      # Add a new progress bar
      #
      # @param label [String] label for the bar
      # @param total [Integer] total items
      # @param format [String] format string
      # @param width [Integer] bar width
      # @return [Bar]
      def bar(label, total:, format: nil, width: 20)
        bar_format = format || ":bar :percent | #{label}"
        progress_bar = Bar.new(total: total, format: bar_format, width: width, output: StringIO.new)
        @bars << { label: label, bar: progress_bar }
        progress_bar
      end

      # Render all bars
      #
      # @return [self]
      def render
        return self unless tty?

        # Move cursor up to overwrite previous render
        @output.write("\e[#{@bars.length}A") if @rendered_once
        @bars.each do |entry|
          @output.write("\r\e[2K#{entry[:bar]}\n")
        end
        @rendered_once = true
        self
      end

      # Number of bars being tracked
      #
      # @return [Integer]
      def size
        @bars.length
      end

      # Check if all bars are finished
      #
      # @return [Boolean]
      def finished?
        @bars.all? { |entry| entry[:bar].finished? }
      end

      private

      def tty?
        @output.respond_to?(:tty?) && @output.tty?
      end
    end
  end
end
