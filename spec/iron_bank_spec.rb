# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank do
  it "has a version number" do
    expect(IronBank::VERSION).not_to be nil
  end

  it "has an API version number" do
    expect(IronBank::API_VERSION).not_to be nil
  end

  describe "::configure" do
    before { allow(IronBank::Authentication).to receive(:new) }

    it "has default values" do
      expect(IronBank.configuration.schema_directory).to eq("./config/schema")
      expect(IronBank.configuration.export_directory).to eq("./config/export")
    end

    it "sets the client if credentials are passed" do
      IronBank.configure do |config|
        config.domain        = "rest.apisandbox.zuora.com"
        config.client_id     = "something-from-zuora"
        config.client_secret = "something-secret-from-zuora"
        config.auth_type     = "token"
      end

      expect(IronBank.client).to be_an_instance_of(IronBank::Client)
    end
  end
end
