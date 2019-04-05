# frozen_string_literal: true

RSpec.shared_examples "a Zuora operation" do
  let(:connection)    { instance_double(Faraday::Connection) }
  let(:response_body) { anything }

  let(:response) do
    instance_double(Faraday::Response, body: response_body)
  end

  let(:client) do
    instance_double(IronBank::Client, connection: connection)
  end

  let(:object) do
    instance_double(IronBank::Object)
  end

  let(:camelized_hash) do
    instance_double(Hash)
  end

  describe "::call" do
    before do
      allow(IronBank).to receive(:client).and_return(client)
      allow(IronBank::Object).to receive(:new).with(args).and_return(object)
      allow(object).to receive(:deep_camelize).with(type: :lower).
        and_return(camelized_hash)
    end

    subject(:call) { described_class.call(args) }

    it "sends a POST request to Zuora" do
      expect(connection).
        to receive(:post).
        with(endpoint, camelized_hash).
        and_return(response)

      call
    end
  end
end
