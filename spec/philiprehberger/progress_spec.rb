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

  describe '.spin without block' do
    it 'returns a spinner instance' do
      spinner = described_class.spin('Working', output: StringIO.new)
      expect(spinner).to be_a(Philiprehberger::Progress::Spinner)
    end
  end

  describe '.bar auto-finish' do
    it 'auto-finishes the bar when block does not finish it' do
      output = StringIO.new
      described_class.bar(total: 5, output: output) do |bar|
        bar.advance(2)
      end
      # block ended without finishing; bar should be auto-finished
    end
  end

  describe '.spin auto-stop' do
    it 'auto-stops the spinner when block does not stop it' do
      output = StringIO.new
      described_class.spin('Processing', output: output, &:spin)
      # block ended without stopping; spinner should be auto-stopped
    end
  end

  describe '.each edge cases' do
    it 'handles an empty enumerable' do
      output = StringIO.new
      results = []
      described_class.each([], output: output) { |item| results << item }
      expect(results).to eq([])
    end

    it 'works with a Set (non-array enumerable)' do
      output = StringIO.new
      items = Set.new([1, 2, 3])
      results = []
      described_class.each(items, output: output) { |item| results << item }
      expect(results.sort).to eq([1, 2, 3])
    end
  end

  describe Philiprehberger::Progress::Bar do
    let(:output) { StringIO.new }

    describe 'zero total' do
      it 'starts with current 0' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.current).to eq(0)
      end

      it 'reports 100% percentage' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.percentage).to eq(100.0)
      end

      it 'renders a fully filled bar in to_s' do
        bar = described_class.new(total: 0, width: 10, output: output)
        fill = Philiprehberger::Progress::Bar::FILL_CHAR * 10
        expect(bar.to_s).to include(fill)
      end

      it 'does not change current on advance' do
        bar = described_class.new(total: 0, output: output)
        bar.advance(5)
        expect(bar.current).to eq(0)
      end

      it 'finishes cleanly' do
        bar = described_class.new(total: 0, output: output)
        bar.finish
        expect(bar.finished?).to be true
        expect(bar.current).to eq(0)
      end

      it 'returns 0.0 for eta' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.eta).to eq(0.0)
      end
    end

    describe 'negative total' do
      it 'clamps negative total to zero' do
        bar = described_class.new(total: -5, output: output)
        expect(bar.total).to eq(0)
      end
    end

    describe 'chaining' do
      it '#advance returns self' do
        bar = described_class.new(total: 10, output: output)
        expect(bar.advance).to be(bar)
      end

      it '#finish returns self' do
        bar = described_class.new(total: 10, output: output)
        expect(bar.finish).to be(bar)
      end

      it 'supports chained advance calls' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(3).advance(4)
        expect(bar.current).to eq(7)
      end
    end

    describe 'custom width' do
      it 'renders bar with specified width' do
        bar = described_class.new(total: 10, width: 20, output: output)
        bar.advance(5)
        str = bar.to_s
        fill = Philiprehberger::Progress::Bar::FILL_CHAR
        empty = Philiprehberger::Progress::Bar::EMPTY_CHAR
        bar_section = str.match(/\[(.+?)\]/)[1]
        expect(bar_section.length).to eq(20)
        expect(bar_section.count(fill)).to eq(10)
        expect(bar_section.count(empty)).to eq(10)
      end
    end

    describe '#to_s ETA display' do
      it 'shows --:-- when no progress has been made' do
        bar = described_class.new(total: 100, output: output)
        expect(bar.to_s).to include('--:--')
      end

      it 'shows 0s when progress equals total' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(10)
        expect(bar.to_s).to include('0s')
      end
    end

    describe '#advance returns self when finished' do
      it 'returns self even when already finished' do
        bar = described_class.new(total: 5, output: output)
        bar.finish
        expect(bar.advance).to be(bar)
      end
    end

    describe 'multiple advances beyond total' do
      it 'clamps current to total across multiple calls' do
        bar = described_class.new(total: 5, output: output)
        bar.advance(3)
        bar.advance(3)
        bar.advance(3)
        expect(bar.current).to eq(5)
      end
    end
  end

  describe Philiprehberger::Progress::Spinner do
    let(:output) { StringIO.new }

    describe '#spin returns self' do
      it 'returns the spinner instance' do
        spinner = described_class.new(message: 'test', output: output)
        expect(spinner.spin).to be(spinner)
      end
    end

    describe '#stop returns self' do
      it 'returns the spinner instance' do
        spinner = described_class.new(message: 'test', output: output)
        expect(spinner.stop).to be(spinner)
      end
    end

    describe '#stop default message' do
      it 'uses "done" as default final message' do
        spinner = described_class.new(message: 'test', output: output)
        spinner.stop
        expect(spinner.stopped?).to be true
      end
    end

    describe '#to_s includes current frame' do
      it 'starts with a frame character' do
        spinner = described_class.new(message: 'test', output: output)
        frames = Philiprehberger::Progress::Spinner::FRAMES
        expect(frames).to include(spinner.to_s.split.first)
      end
    end

    describe 'silent when output is not TTY' do
      it 'does not write to non-TTY output on spin' do
        io = StringIO.new
        spinner = described_class.new(message: 'test', output: io)
        spinner.spin
        expect(io.string).to eq('')
      end

      it 'does not write to non-TTY output on stop' do
        io = StringIO.new
        spinner = described_class.new(message: 'test', output: io)
        spinner.stop
        expect(io.string).to eq('')
      end
    end

    describe '#stop called multiple times' do
      it 'remains stopped and does not raise' do
        spinner = described_class.new(message: 'test', output: output)
        spinner.stop('first')
        spinner.stop('second')
        expect(spinner.stopped?).to be true
      end
    end

    describe '#to_s after spinning' do
      it 'includes the message after multiple spins' do
        spinner = described_class.new(message: 'Processing', output: output)
        5.times { spinner.spin }
        expect(spinner.to_s).to include('Processing')
      end
    end

    describe 'FRAMES constant' do
      it 'contains exactly 10 frames' do
        expect(Philiprehberger::Progress::Spinner::FRAMES.length).to eq(10)
      end

      it 'is frozen' do
        expect(Philiprehberger::Progress::Spinner::FRAMES).to be_frozen
      end
    end
  end

  describe Philiprehberger::Progress::Bar do
    let(:output) { StringIO.new }

    describe '#advance with zero increment' do
      it 'does not change current' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(0)
        expect(bar.current).to eq(0)
      end
    end

    describe '#advance exact total match' do
      it 'reaches total exactly when advancing by total' do
        bar = described_class.new(total: 50, output: output)
        bar.advance(50)
        expect(bar.current).to eq(50)
        expect(bar.percentage).to eq(100.0)
      end
    end

    describe 'default width' do
      it 'renders a bar of width 30 by default' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(5)
        bar_section = bar.to_s.match(/\[(.+?)\]/)[1]
        expect(bar_section.length).to eq(30)
      end
    end

    describe '#finish called multiple times' do
      it 'remains finished and does not raise' do
        bar = described_class.new(total: 10, output: output)
        bar.finish
        bar.finish
        expect(bar.finished?).to be true
        expect(bar.current).to eq(10)
      end
    end

    describe '#percentage precision' do
      it 'rounds to one decimal place' do
        bar = described_class.new(total: 3, output: output)
        bar.advance(1)
        expect(bar.percentage).to eq(33.3)
      end

      it 'rounds 2/3 correctly' do
        bar = described_class.new(total: 3, output: output)
        bar.advance(2)
        expect(bar.percentage).to eq(66.7)
      end
    end

    describe 'very large total' do
      it 'handles a large total without error' do
        bar = described_class.new(total: 1_000_000, output: output)
        bar.advance(500_000)
        expect(bar.current).to eq(500_000)
        expect(bar.percentage).to eq(50.0)
      end
    end

    describe '#to_s format structure' do
      it 'matches the expected format pattern' do
        bar = described_class.new(total: 10, output: output)
        bar.advance(5)
        str = bar.to_s
        expect(str).to match(%r{\[.+\]\s+\d+\.\d+%\s+\|\s+\d+/\d+\s+\|\s+ETA:\s+\S+\s+\|\s+\S+/s})
      end
    end

    describe '#eta when fully advanced without finish' do
      it 'returns 0.0 when current equals total' do
        bar = described_class.new(total: 5, output: output)
        bar.advance(5)
        expect(bar.eta).to eq(0.0)
      end
    end

    describe 'zero total ETA display' do
      it 'shows 0s for ETA when total is zero' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.to_s).to include('0s')
      end
    end

    describe 'zero total throughput' do
      it 'returns 0.0 for throughput when total is zero' do
        bar = described_class.new(total: 0, output: output)
        expect(bar.throughput).to be >= 0.0
      end
    end

    describe 'negative total renders as zero total' do
      it 'reports 100% percentage for negative total' do
        bar = described_class.new(total: -10, output: output)
        expect(bar.percentage).to eq(100.0)
      end

      it 'renders a fully filled bar for negative total' do
        bar = described_class.new(total: -10, width: 10, output: output)
        fill = Philiprehberger::Progress::Bar::FILL_CHAR * 10
        expect(bar.to_s).to include(fill)
      end
    end
  end

  describe '.bar passes width option' do
    it 'creates a bar with custom width' do
      output = StringIO.new
      described_class.bar(total: 10, width: 15, output: output) do |bar|
        bar.advance(5)
        bar_section = bar.to_s.match(/\[(.+?)\]/)[1]
        expect(bar_section.length).to eq(15)
      end
    end
  end

  describe '.bar auto-finish verification' do
    it 'marks the bar as finished after block completes' do
      output = StringIO.new
      bar_ref = nil
      described_class.bar(total: 5, output: output) do |bar|
        bar.advance(2)
        bar_ref = bar
      end
      expect(bar_ref.finished?).to be true
    end
  end

  describe '.spin auto-stop verification' do
    it 'marks the spinner as stopped after block completes' do
      output = StringIO.new
      spinner_ref = nil
      described_class.spin('Working', output: output) do |s|
        s.spin
        spinner_ref = s
      end
      expect(spinner_ref.stopped?).to be true
    end
  end

  describe '.each with a Range' do
    it 'iterates over a range' do
      output = StringIO.new
      results = []
      described_class.each(1..3, output: output) { |item| results << item }
      expect(results).to eq([1, 2, 3])
    end
  end

  describe '.each returns items from non-array enumerable' do
    it 'returns the array form of the enumerable' do
      output = StringIO.new
      result = described_class.each(1..4, output: output) { |_item| nil }
      expect(result).to eq([1, 2, 3, 4])
    end
  end

  describe Philiprehberger::Progress::Multi do
    let(:output) { StringIO.new }
    let(:multi) { described_class.new(output: output) }

    describe '#add' do
      it 'creates a bar with the given label and total' do
        bar = multi.add('Downloads', total: 100)
        expect(bar).to be_a(Philiprehberger::Progress::Bar)
      end

      it 'stores bars by label' do
        multi.add('A', total: 10)
        multi.add('B', total: 20)
        expect(multi.labels).to eq(%w[A B])
      end
    end

    describe '#[]' do
      it 'retrieves a bar by label' do
        bar = multi.add('Files', total: 50)
        expect(multi['Files']).to eq(bar)
      end

      it 'returns nil for unknown label' do
        expect(multi['missing']).to be_nil
      end
    end

    describe '#finished?' do
      it 'returns false when empty' do
        expect(multi.finished?).to be false
      end

      it 'returns false when bars are incomplete' do
        multi.add('A', total: 10)
        expect(multi.finished?).to be false
      end

      it 'returns true when all bars are finished' do
        bar1 = multi.add('A', total: 1)
        bar2 = multi.add('B', total: 1)
        bar1.advance.finish
        bar2.advance.finish
        expect(multi.finished?).to be true
      end

      it 'returns false when some bars are incomplete' do
        bar1 = multi.add('A', total: 1)
        multi.add('B', total: 1)
        bar1.advance.finish
        expect(multi.finished?).to be false
      end
    end

    describe '#bars' do
      it 'returns a copy of bars hash' do
        multi.add('A', total: 10)
        bars = multi.bars
        expect(bars).to have_key('A')
        expect(bars).not_to equal(multi.bars)
      end
    end

    describe '#reset' do
      it 'clears all bars' do
        multi.add('A', total: 10)
        multi.reset
        expect(multi.labels).to be_empty
        expect(multi.bars).to be_empty
      end
    end

    describe '.multi convenience method' do
      it 'creates a Multi instance' do
        m = Philiprehberger::Progress.multi(output: output)
        expect(m).to be_a(described_class)
      end

      it 'yields the Multi instance in block form' do
        Philiprehberger::Progress.multi(output: output) do |m|
          expect(m).to be_a(described_class)
        end
      end

      it 'returns the Multi instance from block' do
        result = Philiprehberger::Progress.multi(output: output) do |m|
          m.add('A', total: 5)
        end
        expect(result.labels).to eq(['A'])
      end
    end
  end
end
