# frozen_string_literal: true

module Philiprehberger
  module Progress
    # A terminal spinner for indeterminate progress
    #
    # @example
    #   spinner = Spinner.new(message: 'Loading...')
    #   spinner.spin
    #   spinner.done
    class Spinner
      DEFAULT_FRAMES = %w[| / - \\].freeze
      BRAILLE_FRAMES = %W[\u2807 \u2816 \u2830 \u2821 \u280B \u2819 \u2838 \u2824].freeze
      DOTS_FRAMES = %W[\u2800 \u2801 \u2803 \u2807 \u280F \u281F \u283F \u287F \u28FF].freeze

      FRAME_SETS = {
        default: DEFAULT_FRAMES,
        braille: BRAILLE_FRAMES,
        dots: DOTS_FRAMES
      }.freeze

      # Create a new spinner
      #
      # @param message [String] message to display next to the spinner
      # @param frames [Symbol, Array<String>] frame set name or custom frames
      # @param output [IO] output stream (default: $stderr)
      def initialize(message: '', frames: :default, output: $stderr)
        @message = message
        @frames = frames.is_a?(Symbol) ? FRAME_SETS.fetch(frames, DEFAULT_FRAMES) : frames
        @output = output
        @index = 0
        @done = false
      end

      # Advance the spinner by one frame
      #
      # @return [self]
      def spin
        return self if @done

        render if tty?
        @index = (@index + 1) % @frames.length
        self
      end

      # Mark the spinner as done
      #
      # @param message [String] optional completion message
      # @return [self]
      def done(message = nil)
        @done = true
        if tty?
          clear_line
          @output.write("#{message || @message}\n") if message || !@message.empty?
        end
        self
      end

      # Check if the spinner is done
      #
      # @return [Boolean]
      def done?
        @done
      end

      # Return the current frame
      #
      # @return [String]
      def to_s
        frame = @frames[@index % @frames.length]
        @message.empty? ? frame : "#{frame} #{@message}"
      end

      private

      def tty?
        @output.respond_to?(:tty?) && @output.tty?
      end

      def render
        @output.write("\r#{self}")
      end

      def clear_line
        @output.write("\r\e[2K")
      end
    end
  end
end
