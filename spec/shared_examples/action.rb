# frozen_string_literal: true

RSpec.shared_examples 'a Zuora action' do
  let(:client)     { instance_double(IronBank::Client) }
  let(:connection) { instance_double(Faraday::Connection) }
  let(:response)   { instance_double(Faraday::Response, body: body) }
  let(:body)       { [{}] }

  describe '::call' do
    before do
      allow(IronBank).to receive(:client).and_return(client)
      allow(client).to receive(:connection).and_return(connection)
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
