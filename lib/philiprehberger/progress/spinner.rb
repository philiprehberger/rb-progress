# frozen_string_literal: true

module Philiprehberger
  module Progress
    class Spinner
      FRAMES = ["\u280B", "\u2819", "\u2839", "\u2838", "\u283C", "\u2834", "\u2826", "\u2827", "\u2807",
                "\u280F"].freeze

      attr_reader :message

      def initialize(message:, output: $stderr)
        @message = message
        @output = output
        @index = 0
        @stopped = false
      end

      def spin
        return self if @stopped

        render_to_output
        @index = (@index + 1) % FRAMES.length
        self
      end

      def auto_spin(interval: 0.1)
        @auto_thread = Thread.new do
          until @stopped
            spin
            sleep(interval)
          end
        end
        self
      end

      def stop(final_message = 'done')
        @stopped = true
        @auto_thread&.join
        @auto_thread = nil
        @output.write("\r\e[2K#{final_message}\n") if tty?
        self
      end

      def stopped?
        @stopped
      end

      def current_frame
        FRAMES[@index % FRAMES.length]
      end

      def to_s
        "#{current_frame} #{@message}"
      end

      private

      def tty?
        @output.respond_to?(:tty?) && @output.tty?
      end

      def render_to_output
        @output.write("\r#{self}") if tty?
      end
    end
  end
end
