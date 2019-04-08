# frozen_string_literal: true

RSpec.shared_examples "a Zuora action called from the client" do
  let(:params) { anything }

  subject(:send_action) { client.public_send(action_name, params) }

  it "is defined as an instance method on the client" do
    expect(klass).to receive(:call).with(params)
    send_action
  end
end

RSpec.describe IronBank::Client do
  let(:client_id)     { "client-id-from-zuora" }
  let(:client_secret) { "client-secret-from-zuora" }
  let(:domain)        { "rest.zuora.com" }

  let(:config) do
    {
      client_id:     client_id,
      client_secret: client_secret,
      domain:        domain
    }
  end

  before do
    allow(IronBank::Authentication).to receive(:new).
      and_return(anything)
  end

  let(:client) { described_class.new(config) }

  describe "::new" do
    subject(:new_client) { described_class.new(config) }

    it { is_expected.to be_an_instance_of(IronBank::Client) }

    context "missing client_id in config" do
      let(:config) do
        { domain: domain, client_secret: client_secret }
      end

      specify do
        expect { new_client }.
          to raise_error(ArgumentError, "missing keyword: client_id")
      end
    end

    context "missing secret in config" do
      let(:config) do
        { domain: domain, client_id: client_id }
      end

      specify do
        expect { new_client }.
          to raise_error(ArgumentError, "missing keyword: client_secret")
      end
    end

    context "missing domain in config" do
      let(:config) do
        { client_id: client_id, client_secret: client_secret }
      end

      specify do
        expect { new_client }.
          to raise_error(ArgumentError, "missing keyword: domain")
      end
    end
  end

  describe "#inspect" do
    subject(:inspect) { client.inspect }
    it { is_expected.not_to match(/client_secret/) }
  end

  describe "#connection" do
    let(:auth) { client.send(:auth) }
    let(:token) { instance_double(IronBank::Authentications::Token) }

    subject(:connection) { client.connection }

    before do
      allow(auth).to receive(:header).and_return({})
      allow(auth).to receive(:expired?).and_return(anything)
      allow(auth).to receive(:renew_session).and_return(anything)
      allow(IronBank::Authentications::Token).to receive(:new).and_return(token)
    end

    it { is_expected.to be_an_instance_of(Faraday::Connection) }

    describe "#url_prefix" do
      subject(:base_url) { connection.url_prefix.to_s }
      it { is_expected.to eq("https://rest.zuora.com/") }
    end

    context "invalid domain" do
      let(:domain) { "www.google.com" }

      specify do
        expect { connection }.to raise_error(IronBank::Client::InvalidHostname)
      end
    end
  end

  describe "for each IronBank::Actions::*" do
    let(:methods) do
      IronBank::Actions.constants.map do |action|
        IronBank::Utils.underscore(action)
      end
    end

    it "defines the corresponding instance method" do
      expect(client).to respond_to(*methods)
    end

    IronBank::Actions.constants.each do |action|
      describe "##{IronBank::Utils.underscore(action)}" do
        let(:klass)       { IronBank::Actions.const_get(action) }
        let(:action_name) { IronBank::Utils.underscore(action) }
        it_behaves_like "a Zuora action called from the client"
      end
    end
  end
end
