# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::OpenTracing do
  class Sample
    include IronBank::OpenTracing
  end

  let(:subject) { Sample.new }

  describe '#open_tracing_options' do
    let(:options) do
      {
        distributed_tracing: true,
        split_by_domain:     false,
        service_name:        'ironbank'
      }
    end

    let(:open_tracing_options) { subject.open_tracing_options }

    it { expect(open_tracing_options).to eq(options) }
  end

  describe '#open_tracing_enabled' do
    let(:open_tracing_enabled) { subject.open_tracing_enabled? }

    it { expect(open_tracing_enabled).to eq(false) }
  end
end
