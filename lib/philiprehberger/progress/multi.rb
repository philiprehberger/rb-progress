# frozen_string_literal: true

module Philiprehberger
  module Progress
    class Multi
      def initialize(output: $stderr)
        @output = output
        @bars = {}
        @order = []
      end

      def add(label, total:, width: 30)
        bar = Bar.new(total: total, width: width, output: @output)
        @bars[label] = bar
        @order << label unless @order.include?(label)
        bar
      end

      def [](label)
        @bars[label]
      end

      def bars
        @bars.dup
      end

      def labels
        @order.dup
      end

      def finished?
        return false if @bars.empty?

        @bars.values.all?(&:finished?)
      end

      def render
        return unless @output.respond_to?(:tty?) && @output.tty?

        lines = @order.map do |label|
          bar = @bars[label]
          "#{label}: #{bar}"
        end
        @output.print("\e[#{lines.size}A") if @rendered_once
        lines.each { |line| @output.puts(line) }
        @rendered_once = true
      end

      def reset
        @bars.clear
        @order.clear
        @rendered_once = false
      end
    end
  end
end
