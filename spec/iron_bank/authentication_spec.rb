# frozen_string_literal: true

RSpec.describe IronBank::Authentication do
  let(:client_id)     { "client-id-from-zuora" }
  let(:client_secret) { "client-secret-from-zuora" }
  let(:domain)        { "rest.zuora.com" }
  let(:config) do
    {
      client_id:     client_id,
      client_secret: client_secret,
      base_url:      "https://rest.zuora.com",
      auth_type:     "token"
    }
  end

  describe "::new" do
    let(:subject) { described_class.new(config) }

    it { expect delegate_method(:header).to(:session) }
    it { expect delegate_method(:expired?).to(:session) }
  end

  describe "::new with auth_type token" do
    let(:subject) { described_class.new(config) }
    let(:adapter_klass) { subject.send(:adapter) }
    let(:connection) { instance_double(Faraday::Connection) }
    let(:response) do
      instance_double(Faraday::Response, body: { "access_token" => "123" })
    end

    before do
      allow(Faraday).to receive(:new).and_return(connection)
      allow(connection).to receive(:post).and_return(response)
    end

    it { expect(adapter_klass).to eq IronBank::Authentications::Token }
  end

  describe "::new with auth_type cookie" do
    let(:new_config) do
      config.merge(auth_type: "cookie")
    end
    let(:subject) { described_class.new(new_config) }
    let(:adapter_klass) { subject.send(:adapter) }
    let(:connection) { instance_double(Faraday::Connection) }
    let(:response) do
      instance_double(
        Faraday::Response,
        body:    { "success" => true },
        headers: { "set-cookie" => "ZSession=123" }
      )
    end

    before do
      allow(Faraday).to receive(:new).and_return(connection)
      allow(connection).to receive(:post).and_return(response)
    end

    it { expect(adapter_klass).to eq IronBank::Authentications::Cookie }
  end
end
