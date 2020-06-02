# frozen_string_literal: true

require "timecop"
require "shared_examples/faraday_connection"

RSpec.describe IronBank::Authentications::Cookie do
  let(:initial_session) do
    OpenStruct.new(
      body:    { success: true },
      headers: { "set-cookie" => "ZSession=123" }
    )
  end

  let(:refreshed_session) do
    OpenStruct.new(
      body:    { success: true },
      headers: { "set-cookie" => "ZSession=456" }
    )
  end

  let(:initial_authorization_header) do
    { "Cookie" => initial_session.headers["set-cookie"] }
  end

  let(:refreshed_authorization_header) do
    { "Cookie" => refreshed_session.headers["set-cookie"] }
  end

  let(:client_id)     { "username-for-zuora" }
  let(:client_secret) { "password-for-zuora" }
  let(:base_url)      { "https://domain.com" }

  let(:credentials) do
    {
      client_id:     client_id,
      client_secret: client_secret,
      base_url:      base_url
    }
  end

  let(:first_response) do
    instance_double(
      Faraday::Response,
      body:    initial_session.body,
      headers: initial_session.headers
    )
  end

  let(:second_response) do
    instance_double(
      Faraday::Response,
      body:    refreshed_session.body,
      headers: refreshed_session.headers
    )
  end

  let(:connection) { instance_double(Faraday::Connection) }

  subject { described_class.call(credentials) }

  before do
    allow(Faraday).to receive(:new).and_return(connection)

    allow(connection).
      to receive(:post).
      and_return(first_response, second_response)
  end

  describe "#header" do
    subject(:a_token) { described_class.new(**credentials) }

    context "cookie not expired" do
      before do
        Timecop.freeze(Time.local(2017))
      end

      after { Timecop.return }

      it "returns the authorization with cookie header" do
        expect(a_token.header).to eq(initial_authorization_header)
      end
    end

    context "token expired" do
      subject(:expired) do
        Timecop.travel(Time.local(2019))
        a_token.header
      end

      before do
        Timecop.freeze(Time.local(2017))
        a_token.header
      end

      after { Timecop.return }

      it "renews the authorization with new cookie header" do
        expect(expired).to eq(refreshed_authorization_header)
      end
    end
  end

  describe "#expired?" do
    subject(:zsession) { described_class.new(**credentials) }

    context "cookie not expired" do
      before do
        Timecop.freeze(Time.local(2017))
      end

      after { Timecop.return }

      it "returns false" do
        expect(zsession.expired?).to be_falsey
      end
    end

    context "cookie expired" do
      subject(:expired) do
        Timecop.travel(Time.local(2019))
        zsession
      end

      before do
        Timecop.freeze(Time.local(2017))
        zsession.header
      end

      after { Timecop.return }

      it "returns true" do
        expect(expired.expired?).to be_truthy
      end
    end
  end

  include_examples "Faraday::Connection configuration block"
end
