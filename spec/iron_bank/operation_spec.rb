# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Operation do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client)     { instance_double(IronBank::Client, connection: connection) }

  before do
    allow(IronBank).to receive(:client).and_return(client)
  end

  describe '::call' do
    subject(:call) { described_class.call(anything) }

    specify do
      expect { call }.to raise_error(NameError)
    end
  end
end
