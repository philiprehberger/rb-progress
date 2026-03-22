# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Progress do
  it 'has a version number' do
    expect(Philiprehberger::Progress::VERSION).not_to be_nil
  end

  describe '.bar' do
    it 'creates a progress bar' do
      bar = described_class.bar(total: 100, output: StringIO.new)
      expect(bar).to be_a(Philiprehberger::Progress::Bar)
    end

    it 'yields a progress bar and auto-finishes' do
      output = StringIO.new
      described_class.bar(total: 10, output: output) do |bar|
        10.times { bar.advance }
      end
    end

    it 'returns the block result' do
      result = described_class.bar(total: 1, output: StringIO.new) { |_bar| 42 }
      expect(result).to eq(42)
    end
  end

  describe '.spin' do
    it 'creates a spinner' do
      spinner = described_class.spin('Working', output: StringIO.new)
      expect(spinner).to be_a(Philiprehberger::Progress::Spinner)
    end

    it 'yields a spinner and auto-finishes' do
      output = StringIO.new
      described_class.spin('Working', output: output) do |spinner|
        spinner.spin
      end
    end
  end

  describe '.multi' do
    it 'creates a multi-bar display' do
      multi = described_class.multi(output: StringIO.new)
      expect(multi).to be_a(Philiprehberger::Progress::Multi)
    end
  end

  describe 'Enumerable#each_with_progress' do
    it 'iterates all items' do
      output = StringIO.new
      results = []
      [1, 2, 3].each_with_progress('Test', output: output) { |item| results << item }
      expect(results).to eq([1, 2, 3])
    end

    it 'returns the original array' do
      output = StringIO.new
      result = [1, 2, 3].each_with_progress('Test', output: output) { |_item| nil }
      expect(result).to eq([1, 2, 3])
    end
  end
end
