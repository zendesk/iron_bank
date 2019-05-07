# frozen_string_literal: true

RSpec.describe IronBank::PaymentRun do
  describe ".create" do
    subject(:create) { described_class.create(params) }

    let(:params) do
      {
        account_id:  "zuora-account-id-1234",
        target_date: "2019-05-07"
      }
    end

    let(:payload) do
      {
        "accountId"  => params[:account_id],
        "targetDate" => params[:target_date]
      }
    end

    let(:conn)     { instance_double(Faraday::Connection) }
    let(:client)   { instance_double(IronBank::Client, connection: conn) }
    let(:response) { instance_double(Faraday::Response, body: body) }
    let(:body)     { { "success" => success, "fooBar" => "baz" } }

    before do
      allow(IronBank).to receive(:client).and_return(client)

      allow(conn).
        to receive(:post).
        with("/v1/payment-runs", payload).
        and_return(response)
    end

    context "failure to submit a payment run" do
      let(:success) { false }

      specify do
        expect { create }.to raise_error(IronBank::UnprocessableEntityError)
      end
    end

    context "successfully submitted a payment run" do
      let(:success) { true }

      it { is_expected.to eq(success: true, foo_bar: "baz") }
    end
  end
end
