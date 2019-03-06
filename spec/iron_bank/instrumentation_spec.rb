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

  describe '#datadog_instrumenter' do
    subject(:datadog_instrumenter) { instance.datadog_instrumenter(:find) {} }

    let(:dd_client) { instance_double(Datadog::Tracer) }

    context 'when datadog is configured' do
      let(:expected_options) do
        {
          service:  'billing-ironbank-client',
          resource: 'find'
        }
      end

      before do
        allow(Datadog).to receive(:tracer).and_return(dd_client)
      end

      specify do
        expect(dd_client).to receive(:trace).
          with('billing-ironbank', expected_options)

        datadog_instrumenter
      end
    end

    context 'when datadog is not configured' do
      before do
        allow(Datadog).to receive(:respond_to?).and_return(nil)
      end

      it 'wont trace/instrument' do
        expect(dd_client).not_to receive(:trace)

        datadog_instrumenter
      end
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
