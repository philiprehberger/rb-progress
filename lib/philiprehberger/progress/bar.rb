# frozen_string_literal: true

module Philiprehberger
  module Progress
    # A terminal progress bar with ETA and throughput display
    #
    # @example
    #   bar = Bar.new(total: 100)
    #   100.times { bar.advance }
    #   bar.finish
    class Bar
      DEFAULT_FORMAT = ':bar :percent | :current/:total | :rate items/s | ETA: :eta'
      DEFAULT_WIDTH = 30
      FILL_CHAR = "\u2588"
      EMPTY_CHAR = "\u2591"

      attr_reader :current, :total

      # Create a new progress bar
      #
      # @param total [Integer] total number of items
      # @param format [String] format string with placeholders
      # @param width [Integer] width of the bar portion in characters
      # @param output [IO] output stream (default: $stderr)
      def initialize(total:, format: DEFAULT_FORMAT, width: DEFAULT_WIDTH, output: $stderr)
        @total = [total, 0].max
        @format = format
        @width = width
        @output = output
        @current = 0
        @start_time = now
        @finished = false
      end

      # Advance the progress bar
      #
      # @param n [Integer] number of items to advance (default: 1)
      # @return [self]
      def advance(n = 1)
        return self if @finished

        @current = [@current + n, @total].min
        render if tty?
        self
      end

      # Mark the progress as complete
      #
      # @return [self]
      def finish
        @current = @total
        @finished = true
        render if tty?
        @output.write("\n") if tty?
        self
      end

      # Check if the progress is finished
      #
      # @return [Boolean]
      def finished?
        @finished
      end

      # Get the progress percentage
      #
      # @return [Float] percentage from 0.0 to 100.0
      def percentage
        return 100.0 if @total.zero?

        (@current.to_f / @total * 100).round(1)
      end

      # Get the elapsed time in seconds
      #
      # @return [Float]
      def elapsed
        now - @start_time
      end

      # Get the estimated time remaining in seconds
      #
      # @return [Float, nil] nil if no progress has been made
      def eta
        return 0.0 if @current >= @total
        return nil if @current.zero?

        elapsed_time = elapsed
        rate = @current.to_f / elapsed_time
        (@total - @current) / rate
      end

      # Get the throughput in items per second
      #
      # @return [Float]
      def rate
        elapsed_time = elapsed
        return 0.0 if elapsed_time.zero?

        @current.to_f / elapsed_time
      end

      # Render the progress bar as a string
      #
      # @return [String]
      def to_s
        result = @format.dup
        result.gsub!(':bar', render_bar)
        result.gsub!(':percent', format('%<pct>5.1f%%', pct: percentage))
        result.gsub!(':current', @current.to_s)
        result.gsub!(':total', @total.to_s)
        result.gsub!(':rate', format('%<r>.1f', r: rate))
        result.gsub!(':eta', format_duration(eta))
        result.gsub!(':elapsed', format_duration(elapsed))
        result
      end

      private

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def tty?
        @output.respond_to?(:tty?) && @output.tty?
      end

      def render
        @output.write("\r#{self}")
      end

      def render_bar
        return FILL_CHAR * @width if @total.zero?

        filled = (@current.to_f / @total * @width).round
        empty = @width - filled
        (FILL_CHAR * filled) + (EMPTY_CHAR * empty)
      end

      def format_duration(seconds)
        return '--:--' if seconds.nil? || seconds.negative?

        seconds = seconds.to_i
        if seconds < 60
          format('0:%02d', seconds)
        elsif seconds < 3600
          format('%d:%02d', seconds / 60, seconds % 60)
        else
          format('%d:%02d:%02d', seconds / 3600, (seconds % 3600) / 60, seconds % 60)
        end
      end
    end
  end
end
