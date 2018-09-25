# frozen_string_literal: true

RSpec.shared_examples 'a Zuora action' do
  let(:connection)    { instance_double(Faraday::Connection) }
  let(:response_body) { anything }

  let(:response) do
    instance_double(Faraday::Response, body: response_body)
  end

  let(:client) do
    instance_double(IronBank::Client, connection: connection)
  end

  describe '::call' do
    before do
      allow(IronBank).to receive(:client).and_return(client)
    end

    subject(:call) { described_class.call(args) }

    it 'sends a POST request to Zuora' do
      expect(connection).
        to receive(:post).
        with(endpoint, params).
        and_return(response)

      call
    end
  end
end
