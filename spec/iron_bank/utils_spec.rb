# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank::Utils do
  describe "::underscore" do
    subject { described_class.underscore(input) }

    context "camel cased word" do
      let(:input) { "ThisIsSomethingFromJava" }
      it { is_expected.to eq("this_is_something_from_java") }
    end

    context "custom field" do
      let(:input) { "MyCustomField__c" }
      it { is_expected.to eq("my_custom_field__c") }
    end

    context "NetSuite field" do
      let(:input) { "TransferredToAccounting__NS" }
      it { is_expected.to eq("transferred_to_accounting__ns") }
    end

    context "acronym custom field" do
      let(:input) { "VPNAccountId__c" }
      it { is_expected.to eq("vpn_account_id__c") }
    end
  end

  describe "::camelize" do
    subject { described_class.camelize(input, type: type) }

    context "when the :type option is :upper" do
      let(:type) { :upper }

      context "underscored input" do
        let(:input) { "product_rate_plan_charge_tier" }
        it { is_expected.to eq("ProductRatePlanChargeTier") }
      end

      context "custom field" do
        let(:input) { "my_custom_field__c" }
        it { is_expected.to eq("MyCustomField__c") }
      end

      context "NetSuite field" do
        let(:input) { "a_netsuite_field__ns" }
        it { is_expected.to eq("ANetsuiteField__NS") }
      end

      context "acronym custom field" do
        let(:input) { "vpn_account_id__c" }
        it { is_expected.to eq("VpnAccountId__c") }
      end

      context "leading underscore" do
        let(:input) { "_a_field" }
        it { is_expected.to eq("AField") }
      end
    end

    context "when the :type option is :lower" do
      let(:type) { :lower }

      context "underscored input" do
        let(:input) { "product_rate_plan_charge_tier" }
        it { is_expected.to eq("productRatePlanChargeTier") }
      end

      context "custom field" do
        let(:input) { "my_custom_field__c" }
        it { is_expected.to eq("myCustomField__c") }
      end

      context "NetSuite field" do
        let(:input) { "a_netsuite_field__ns" }
        it { is_expected.to eq("aNetsuiteField__NS") }
      end

      context "acronym custom field" do
        let(:input) { "vpn_account_id__c" }
        it { is_expected.to eq("vpnAccountId__c") }
      end

      context "leading underscore" do
        let(:input) { "_a_field" }
        it { is_expected.to eq("aField") }
      end
    end
  end

  describe "::kebab" do
    subject { described_class.kebab(input) }

    context "camel cased word" do
      let(:input) { "ThisIsSomethingFromJava" }
      it { is_expected.to eq("this-is-something-from-java") }
    end

    context "custom field" do
      let(:input) { "MyCustomField__c" }
      it { is_expected.to eq("my-custom-field--c") }
    end

    context "NetSuite field" do
      let(:input) { "TransferredToAccounting__NS" }
      it { is_expected.to eq("transferred-to-accounting--ns") }
    end

    context "acronym custom field" do
      let(:input) { "VPNAccountId--c" }
      it { is_expected.to eq("vpn-account-id--c") }
    end
  end
end
