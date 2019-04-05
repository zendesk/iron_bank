# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank::Endpoint do
  describe "::base_url" do
    subject(:base_url) { described_class.base_url(hostname) }

    context "nil hostname" do
      let(:hostname) { nil }
      it { is_expected.to be_nil }
    end

    context "numeric hostname" do
      let(:hostname) { 1234 }
      it { is_expected.to be_nil }
    end

    context "boolean hostname" do
      let(:hostname) { true }
      it { is_expected.to be_nil }
    end

    context "invalid hostname" do
      let(:hostname) { "clearly this is not a FQDN" }
      it { is_expected.to be_nil }
    end

    context "production hostname" do
      let(:hostname) { "rest.zuora.com" }
      it { is_expected.to eq("https://rest.zuora.com/") }
    end

    context "services hostname" do
      context "one-digit services hostname" do
        let(:hostname) { "services9.zuora.com" }
        it { is_expected.to eq("https://services9.zuora.com/") }
      end

      context "multiple digits services hostname" do
        let(:hostname) { "services666.zuora.com" }
        it { is_expected.to eq("https://services666.zuora.com/") }
      end

      context "uppercase services hostname" do
        let(:hostname) { "SERVICES123.ZUORA.COM" }
        it { is_expected.to eq("https://services123.zuora.com/") }
      end

      context "multiple digits services hostname with port" do
        let(:hostname) { "services666.zuora.com:12345" }
        it { is_expected.to eq("https://services666.zuora.com:12345/") }
      end
    end

    context "apisandbox hostname" do
      let(:hostname) { "rest.apisandbox.zuora.com" }
      it { is_expected.to eq("https://rest.apisandbox.zuora.com/") }
    end
  end
end
