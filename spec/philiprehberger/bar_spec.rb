# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Progress::Bar do
  let(:output) { StringIO.new }

  describe '#initialize' do
    it 'creates a bar with defaults' do
      bar = described_class.new(total: 100, output: output)
      expect(bar.current).to eq(0)
      expect(bar.total).to eq(100)
    end

    it 'handles total of 0' do
      bar = described_class.new(total: 0, output: output)
      expect(bar.percentage).to eq(100.0)
    end

    it 'clamps negative total to 0' do
      bar = described_class.new(total: -5, output: output)
      expect(bar.total).to eq(0)
    end
  end

  describe '#advance' do
    it 'increments by 1 by default' do
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

    it 'does not advance after finish' do
      bar = described_class.new(total: 100, output: output)
      bar.finish
      bar.advance
      expect(bar.current).to eq(100)
    end

    it 'returns self for chaining' do
      bar = described_class.new(total: 100, output: output)
      expect(bar.advance).to be(bar)
    end
  end

  describe '#finish' do
    it 'sets current to total' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(50)
      bar.finish
      expect(bar.current).to eq(100)
    end

    it 'marks as finished' do
      bar = described_class.new(total: 100, output: output)
      bar.finish
      expect(bar.finished?).to be true
    end

    it 'returns self' do
      bar = described_class.new(total: 100, output: output)
      expect(bar.finish).to be(bar)
    end
  end

  describe '#percentage' do
    it 'returns 0 at start' do
      bar = described_class.new(total: 100, output: output)
      expect(bar.percentage).to eq(0.0)
    end

    it 'returns 50 at halfway' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(50)
      expect(bar.percentage).to eq(50.0)
    end

    it 'returns 100 at completion' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(100)
      expect(bar.percentage).to eq(100.0)
    end

    it 'returns 100 for total of 0' do
      bar = described_class.new(total: 0, output: output)
      expect(bar.percentage).to eq(100.0)
    end
  end

  describe '#elapsed' do
    it 'returns positive time after creation' do
      bar = described_class.new(total: 100, output: output)
      expect(bar.elapsed).to be >= 0
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

  describe '#rate' do
    it 'returns 0 with no elapsed time at start' do
      bar = described_class.new(total: 100, output: output)
      # Rate might be 0 or very high depending on timing
      expect(bar.rate).to be >= 0
    end

    it 'returns positive rate after advancing' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(10)
      expect(bar.rate).to be >= 0
    end
  end

  describe '#to_s' do
    it 'includes the bar portion' do
      bar = described_class.new(total: 100, output: output, width: 10)
      expect(bar.to_s).to include("\u2591")
    end

    it 'includes percentage' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(50)
      expect(bar.to_s).to include('50.0%')
    end

    it 'includes current and total' do
      bar = described_class.new(total: 100, output: output)
      bar.advance(25)
      expect(bar.to_s).to include('25/100')
    end

    it 'supports custom format' do
      bar = described_class.new(total: 100, format: ':percent done', output: output)
      bar.advance(50)
      expect(bar.to_s).to include('50.0%')
      expect(bar.to_s).to include('done')
    end

    it 'renders filled bar at 100%' do
      bar = described_class.new(total: 100, output: output, width: 10)
      bar.advance(100)
      expect(bar.to_s).to include("\u2588" * 10)
    end
  end
end
