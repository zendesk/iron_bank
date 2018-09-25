# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Instrumentation do
  class Sample
    include IronBank::Instrumentation
  end

  subject(:instance) { Sample.new }

  describe '#instrumenter' do
    subject(:instrumenter) { instance.instrumenter }

    context 'when an instrumenter has been configured' do
      let(:configured_instrumenter) { double }

      before do
        IronBank.configure do |config|
          config.instrumenter = configured_instrumenter
        end
      end

      after do
        IronBank.configure { |config| config.instrumenter = nil }
      end

      it { is_expected.to eq(configured_instrumenter) }
    end

    context 'when instrumenter_options have not been configured' do
      before { IronBank.configure { |config| config.instrumenter = nil } }

      it { is_expected.to eq(nil) }
    end
  end

  describe '#instrumenter_options' do
    subject(:instrumenter_options) { instance.instrumenter_options }

    context 'when instrumenter_options have been configured' do
      let(:instrumenter_options) { double }

      before do
        IronBank.configure do |config|
          config.instrumenter_options = instrumenter_options
        end
      end

      after do
        IronBank.configure do |config|
          config.instrumenter_options = nil
        end
      end

      it { is_expected.to eq(instrumenter_options) }
    end

    context 'when instrumenter_options have not been configured' do
      before do
        IronBank.configure { |config| config.instrumenter_options = nil }
      end

      it { is_expected.to eq({}) }
    end
  end
end
