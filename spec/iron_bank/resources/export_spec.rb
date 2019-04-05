# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Resources::Export do
  describe '::create' do
    subject(:create_export) { described_class.create(query, options) }

    let(:query)      { 'select * from product' }
    let(:connection) { instance_double(Faraday::Connection) }
    let(:endpoint)   { '/v1/object/export' }

    let(:client) { instance_double(IronBank::Client, connection: connection) }

    let(:post_response) do
      instance_double(Faraday::Response, body: response_body)
    end

    let(:response_body) { { 'Success' => true, 'Id' => 'zuora-export-id' } }

    before do
      allow(IronBank).to receive(:client).and_return(client)

      allow(connection).
        to receive(:post).
        with(endpoint, payload).
        and_return(post_response)
    end

    describe 'with default options' do
      let(:options) { {} }
      let(:payload) { { 'Format' => 'csv', 'Zip' => false, 'Query' => query } }

      specify do
        create_export

        expect(connection).to have_received(:post)
      end

      it { is_expected.to be_an(IronBank::Export) }

      it 'has an ID' do
        expect(create_export.id).to eq('zuora-export-id')
      end
    end

    describe 'overriding default options' do
      let(:options) { { zip: true, format: 'html' } }
      let(:payload) { { 'Format' => 'html', 'Zip' => true, 'Query' => query } }

      specify do
        create_export

        expect(connection).to have_received(:post)
      end

      it { is_expected.to be_an(IronBank::Export) }

      it 'has an ID' do
        expect(create_export.id).to eq('zuora-export-id')
      end
    end
  end
end
