# frozen_string_literal: true

RSpec.describe IronBank::Action do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client)     { instance_double(IronBank::Client, connection: connection) }
  let(:response)   { instance_double(Faraday::Response, body: body) }
  let(:body)       { "" }

  before do
    allow(IronBank).to receive(:client).and_return(client)
    allow(connection).to receive(:post).and_return(response)
  end

  describe ".call" do
    context "without params" do
      subject(:call) { described_class.call(anything) }

      specify do
        expect { call }.to raise_error(NameError)
      end
    end

    context "with params on success" do
      subject(:call) { SampleAction.call(anything) }

      let(:body) do
        [
          {
            "Success" => true,
            "Id"      => "account-id-123"
          }
        ]
      end

      it { expect(call).to eq(IronBank::Object.new(body).deep_underscore) }
    end

    context "with params on failure" do
      subject(:call) { SampleAction.call(anything) }

      let(:body) do
        [
          {
            "Success" => false,
            "Errors"  => [
              {
                "Code"    => "MISSING_REQUIRED_VALUE",
                "Message" => "Missing required value: AccountId"
              }
            ]
          }
        ]
      end

      specify do
        expect { call }.to raise_error(IronBank::UnprocessableEntityError)
      end
    end
  end

  class SampleAction < IronBank::Action
    def params
      {}
    end
  end
end
