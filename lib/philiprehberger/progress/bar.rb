# frozen_string_literal: true

require 'json'

module Philiprehberger
  module Progress
    class Bar
      FILL_CHAR = "\u2588"
      EMPTY_CHAR = "\u2591"

      attr_reader :current, :total

      def initialize(total:, width: 30, output: $stderr, fill: '=', empty: ' ', tip: '>')
        @total = [total, 0].max
        @width = width
        @output = output
        @current = 0
        @start_time = now
        @finished = false
        @paused = false
        @pause_elapsed = 0.0
        @pause_start = nil
        @fill = fill
        @empty = empty
        @tip = tip
      end

      def advance(n = 1)
        return self if @finished

        @current = [@current + n, @total].min
        render_to_output
        self
      end

      # Set absolute progress position.
      #
      # @param n [Integer] the new current value (clamped to 0..total)
      # @return [self]
      def set(n)
        return self if @finished

        @current = [[n, 0].max, @total].min
        render_to_output
        self
      end

      # Reset the bar to 0, preserving total and width. Restarts the timer.
      #
      # @return [self]
      def reset
        @current = 0
        @finished = false
        @paused = false
        @pause_elapsed = 0.0
        @pause_start = nil
        @start_time = now
        self
      end

      # Pause the progress bar, freezing elapsed time calculation.
      #
      # @return [self]
      def pause
        return self if @paused || @finished

        @paused = true
        @pause_start = now
        self
      end

      # Resume after pause.
      #
      # @return [self]
      def resume
        return self unless @paused

        @pause_elapsed += now - @pause_start
        @pause_start = nil
        @paused = false
        self
      end

      def paused?
        @paused
      end

      def finish
        @current = @total
        @finished = true
        render_to_output
        @output.write("\n") if tty?
        self
      end

      def finished?
        @finished
      end

      def percentage
        return 100.0 if @total.zero?

        (@current.to_f / @total * 100).round(1)
      end

      def elapsed
        raw = now - @start_time - @pause_elapsed
        raw -= (now - @pause_start) if @paused
        raw
      end

      def eta
        return 0.0 if @current >= @total
        return nil if @current.zero?

        elapsed_time = elapsed
        items_per_sec = @current.to_f / elapsed_time
        (@total - @current) / items_per_sec
      end

      def throughput
        elapsed_time = elapsed
        return 0.0 if elapsed_time.zero?

        @current.to_f / elapsed_time
      end

      def to_h
        {
          percentage: percentage,
          elapsed: elapsed,
          eta: eta,
          throughput: throughput,
          current: @current,
          total: @total
        }
      end

      def to_s
        return to_h.to_json if Philiprehberger::Progress.json_mode?

        bar_str = render_bar
        pct = format('%<p>5.1f%%', p: percentage)
        eta_str = format_eta(eta)
        tput = format('%<t>.1f/s', t: throughput)

        "[#{bar_str}] #{pct} | #{@current}/#{@total} | ETA: #{eta_str} | #{tput}"
      end

      private

      def now
        Process.clock_gettime(Process::CLOCK_MONOTONIC)
      end

      def tty?
        @output.respond_to?(:tty?) && @output.tty?
      end

      def render_to_output
        @output.write("\r#{self}") if tty?
      end

      def render_bar
        return @fill * @width if @total.zero?

        filled = (@current.to_f / @total * @width).round
        empty = @width - filled

        if filled.positive? && filled < @width
          (@fill * (filled - 1)) + @tip + (@empty * empty)
        else
          (@fill * filled) + (@empty * empty)
        end
      end

      def format_eta(seconds)
        return '--:--' if seconds.nil?

        secs = seconds.to_i
        return '0s' if secs <= 0

        if secs < 60
          "#{secs}s"
        elsif secs < 3600
          format('%dm%02ds', secs / 60, secs % 60)
        else
          format('%dh%02dm%02ds', secs / 3600, (secs % 3600) / 60, secs % 60)
        end
      end
    end
  end
end
