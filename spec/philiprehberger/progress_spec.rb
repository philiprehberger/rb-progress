# frozen_string_literal: true

require 'spec_helper'
require 'set'

RSpec.describe Philiprehberger::Progress do
  describe Philiprehberger::Progress::Bar do
    let(:output) { StringIO.new }

    describe '#advance' do
      it 'increments current count' do
        bar = described_class.new(total: 100, output: output)
        bar.advance
        expect(bar.current).to eq(1)
      end

      it 'increments by a specified amount' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(10)
        expect(bar.current).to eq(10)
      end

      it 'does not exceed total' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(20)
        expect(bar.current).to eq(10)
      end
    end

    describe '#to_s' do
      it 'shows 0% at start' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.to_s).to include('0.0%')
      end

      it 'shows 50% at halfway' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(50)
        expect(bar.to_s).to include('50.0%')
      end

      it 'shows 100% when complete' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(100)
        expect(bar.to_s).to include('100.0%')
      end

      it 'shows current/total count' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(25)
        expect(bar.to_s).to include('25/100')
      end
    end

    describe '#eta' do
      it 'returns nil when no progress has been made' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.eta).to be_nil
      end

      it 'returns 0 when complete' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(100)
        expect(bar.eta).to eq(0.0)
      end

      it 'returns a positive number when partially complete' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(50)
        expect(bar.eta).to be >= 0
      end
    end

    describe '#throughput' do
      it 'returns a non-negative number after advancing' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(10)
        expect(bar.throughput).to be >= 0
      end
    end

    describe '#finish' do
      it 'sets to 100%' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(50)
        bar.finish
        expect(bar.current).to eq(100)
        expect(bar.percentage).to eq(100.0)
      end

      it 'marks as finished' do
        bar = described_class.new(total: 100, output: output)
        bar.finish
        expect(bar.finished?).to be true
      end
    end

    describe 'silent when output is not TTY' do
      it 'does not write to non-TTY output' do
        io = StringIO.new
        bar = described_class.new(total: 10, output: io)
        bar.advance(5)
        expect(io.string).to eq('')
      end
    end
  end

  describe Philiprehberger::Progress::Spinner do
    let(:output) { StringIO.new }

    describe '#spin' do
      it 'cycles through frames' do
        spinner = described_class.new(message: 'Loading', output: output)
        first_frame = spinner.current_frame
        spinner.spin
        second_frame = spinner.current_frame
        expect(first_frame).not_to eq(second_frame)
      end

      it 'wraps around after all frames' do
        spinner = described_class.new(message: 'Loading', output: output)
        frames = Philiprehberger::Progress::Spinner::FRAMES
        frames.length.times { spinner.spin }
        expect(spinner.current_frame).to eq(frames[0])
      end
    end

    describe '#stop' do
      it 'marks spinner as stopped' do
        spinner = described_class.new(message: 'Loading', output: output)
        spinner.stop('Complete')
        expect(spinner.stopped?).to be true
      end

      it 'does not spin after stopped' do
        spinner = described_class.new(message: 'Loading', output: output)
        spinner.stop
        frame_before = spinner.current_frame
        spinner.spin
        expect(spinner.current_frame).to eq(frame_before)
      end
    end

    describe '#to_s' do
      it 'includes the message' do
        spinner = described_class.new(message: 'Working', output: output)
        expect(spinner.to_s).to include('Working')
      end
    end
  end

  describe '.bar' do
    it 'yields a bar and auto-finishes' do
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

  describe '.each' do
    it 'iterates all items' do
      output = StringIO.new
      results = []
      described_class.each([1, 2, 3], output: output) { |item| results << item }
      expect(results).to eq([1, 2, 3])
    end

    it 'returns the original items' do
      output = StringIO.new
      result = described_class.each(%w[a b c], output: output) { |_item| nil }
      expect(result).to eq(%w[a b c])
    end
  end

  describe Philiprehberger::Progress::Bar do
    let(:output) { StringIO.new }

    describe '#percentage' do
      it 'returns 0.0 at start' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.percentage).to eq(0.0)
      end

      it 'returns 100.0 when total is zero' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.percentage).to eq(100.0)
      end

      it 'returns 100.0 when finished' do
        bar = described_class.new(total: 10, output: output)
        bar.finish
        expect(bar.percentage).to eq(100.0)
      end
    end

    describe '#advance after finish' do
      it 'does not change current after finish' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(5)
        bar.finish
        bar.advance(3)
        expect(bar.current).to eq(10)
      end
    end

    describe '#advance by N' do
      it 'advances by a custom amount' do
        bar = described_class.new(total: 100, output: output)
        bar.advance(25)
        expect(bar.current).to eq(25)
        bar.advance(30)
        expect(bar.current).to eq(55)
      end
    end

    describe 'total of 1' do
      it 'goes from 0% to 100% in one advance' do
        bar = described_class.new(total: 1, output: output)
        expect(bar.percentage).to eq(0.0)
        bar.advance
        expect(bar.percentage).to eq(100.0)
      end
    end

    describe '#elapsed' do
      it 'returns a non-negative value' do
        bar = described_class.new(total: 10, output: output)
        expect(bar.elapsed).to be >= 0
      end
    end

    describe '#throughput' do
      it 'returns zero at start' do
        bar = described_class.new(total: 10, output: output)
        expect(bar.throughput).to eq(0.0)
      end
    end

    describe '#to_s format' do
      it 'includes ETA label' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.to_s).to include('ETA:')
      end

      it 'includes throughput suffix' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.to_s).to include('/s')
      end
    end
  end

  describe Philiprehberger::Progress::Spinner do
    let(:output) { StringIO.new }

    describe '#current_frame' do
      it 'returns a valid braille character' do
        spinner = described_class.new(message: 'test', output: output)
        frames = Philiprehberger::Progress::Spinner::FRAMES
        expect(frames).to include(spinner.current_frame)
      end

      it 'cycles through all frames' do
        spinner = described_class.new(message: 'test', output: output)
        frames = Philiprehberger::Progress::Spinner::FRAMES
        seen = Set.new
        frames.length.times do
          seen.add(spinner.current_frame)
          spinner.spin
        end
        expect(seen.length).to eq(frames.length)
      end
    end

    describe '#message' do
      it 'returns the configured message' do
        spinner = described_class.new(message: 'Loading data', output: output)
        expect(spinner.message).to eq('Loading data')
      end
    end

    describe '#stopped?' do
      it 'is false initially' do
        spinner = described_class.new(message: 'test', output: output)
        expect(spinner.stopped?).to be false
      end
    end
  end

  describe '.spin' do
    it 'yields a spinner' do
      output = StringIO.new
      described_class.spin('Working', output: output) do |s|
        expect(s).to be_a(Philiprehberger::Progress::Spinner)
      end
    end

    it 'returns the block result' do
      result = described_class.spin('Working', output: StringIO.new) { 'done' }
      expect(result).to eq('done')
    end
  end

  describe '.bar without block' do
    it 'returns a bar instance' do
      bar = described_class.bar(total: 10, output: StringIO.new)
      expect(bar).to be_a(Philiprehberger::Progress::Bar)
    end
  end
end
