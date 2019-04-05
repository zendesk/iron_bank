# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank::Describe::Tenant do
  let(:file_path) { File.expand_path("tenant.xml", "spec/fixtures") }

  let(:objects) do
    %w[
      Account
      Amendment
      Contact
      Invoice
      PaymentMethod
      Subscription
    ]
  end

  describe "::from_xml" do
    let(:doc)    { File.open(file_path) { |file| Nokogiri::XML(file) } }
    let(:tenant) { described_class.from_xml(doc) }

    describe "#objects" do
      subject { tenant.objects }
      it { is_expected.to eq(objects) }
    end

    describe "#inspect" do
      subject { tenant.inspect }
      it { is_expected.to match(/IronBank::Describe::Tenant:\w+/) }
    end
  end

  describe "::from_connection" do
    let(:connection) { instance_double(Faraday::Connection) }
    let(:endpoint)   { "v1/describe" }
    let(:tenant)     { described_class.from_connection(connection) }

    let(:body) do
      instance_double(Faraday::Response, body: File.read(file_path))
    end

    before do
      allow(connection).to receive(:get).with(endpoint).and_return(body)
    end

    context "HTTP 200 OK" do
      it "retrieves the describe XML file from IronBank" do
        tenant
        expect(connection).to have_received(:get)
      end
    end

    context "HTTP 401 Unauthorized" do
      let(:unauthorized_body) do
        {
          "success" => false,
          "reasons" => [
            {
              "code"    => 90_000_011,
              "message" => "this resource is protected, please sign in first"
            }
          ]
        }
      end

      let(:unauthorized_from_zuora) do
        instance_double(Faraday::Response, body: unauthorized_body)
      end

      it "retries the GET request" do
        expect(connection).
          to receive(:get).
          with(endpoint).
          and_return(unauthorized_from_zuora, body)

        tenant
      end
    end

    describe "#objects" do
      it "calls #from_connection on each object" do
        objects.each do |object_name|
          expect(IronBank::Describe::Object).
            to receive(:from_connection).
            with(connection, object_name)
        end

        tenant.objects
      end
    end
  end
end
