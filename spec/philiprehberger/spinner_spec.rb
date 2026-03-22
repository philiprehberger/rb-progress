# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::Progress::Spinner do
  let(:output) { StringIO.new }

  describe '#initialize' do
    it 'creates a spinner with defaults' do
      spinner = described_class.new(output: output)
      expect(spinner.done?).to be false
    end

    it 'accepts a custom message' do
      spinner = described_class.new(message: 'Loading...', output: output)
      expect(spinner.to_s).to include('Loading...')
    end

    it 'accepts a frame set by name' do
      spinner = described_class.new(frames: :braille, output: output)
      expect(spinner.to_s).not_to be_empty
    end

    it 'accepts custom frames' do
      spinner = described_class.new(frames: %w[a b c], output: output)
      expect(spinner.to_s).to start_with('a')
    end
  end

  describe '#spin' do
    it 'advances the frame' do
      spinner = described_class.new(frames: %w[a b c], output: output)
      first = spinner.to_s
      spinner.spin
      second = spinner.to_s
      expect(first).not_to eq(second)
    end

    it 'cycles through frames' do
      spinner = described_class.new(frames: %w[a b], output: output, message: '')
      expect(spinner.to_s).to eq('a')
      spinner.spin
      expect(spinner.to_s).to eq('b')
      spinner.spin
      expect(spinner.to_s).to eq('a')
    end

    it 'returns self' do
      spinner = described_class.new(output: output)
      expect(spinner.spin).to be(spinner)
    end

    it 'does not advance after done' do
      spinner = described_class.new(frames: %w[a b], output: output, message: '')
      spinner.done
      spinner.spin
      # Should not error
      expect(spinner.done?).to be true
    end
  end

  describe '#done' do
    it 'marks as done' do
      spinner = described_class.new(output: output)
      spinner.done
      expect(spinner.done?).to be true
    end

    it 'returns self' do
      spinner = described_class.new(output: output)
      expect(spinner.done).to be(spinner)
    end
  end

  describe '#to_s' do
    it 'returns the current frame with message' do
      spinner = described_class.new(message: 'Working', frames: %w[*], output: output)
      expect(spinner.to_s).to eq('* Working')
    end

    it 'returns just the frame when message is empty' do
      spinner = described_class.new(message: '', frames: %w[*], output: output)
      expect(spinner.to_s).to eq('*')
    end
  end

  describe 'frame sets' do
    it 'has default frames' do
      expect(Philiprehberger::Progress::Spinner::DEFAULT_FRAMES).not_to be_empty
    end

    it 'has braille frames' do
      expect(Philiprehberger::Progress::Spinner::BRAILLE_FRAMES).not_to be_empty
    end

    it 'has dots frames' do
      expect(Philiprehberger::Progress::Spinner::DOTS_FRAMES).not_to be_empty
    end
  end
end
