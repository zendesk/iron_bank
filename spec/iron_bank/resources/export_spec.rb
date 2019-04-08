# frozen_string_literal: true

RSpec.describe IronBank::Resources::Export do
  describe "::create" do
    subject(:create_export) { described_class.create(query, options) }

    let(:query)      { "select * from product" }
    let(:connection) { instance_double(Faraday::Connection) }
    let(:endpoint)   { "/v1/object/export" }

    let(:client) { instance_double(IronBank::Client, connection: connection) }

    let(:post_response) do
      instance_double(Faraday::Response, body: response_body)
    end

    let(:response_body) { { "Success" => true, "Id" => "zuora-export-id" } }

    before do
      allow(IronBank).to receive(:client).and_return(client)

      allow(connection).
        to receive(:post).
        with(endpoint, payload).
        and_return(post_response)
    end

    describe "with default options" do
      let(:options) { {} }
      let(:payload) { { "Format" => "csv", "Zip" => false, "Query" => query } }

      specify do
        create_export

        expect(connection).to have_received(:post)
      end

      it { is_expected.to be_an(IronBank::Export) }

      it "has an ID" do
        expect(create_export.id).to eq("zuora-export-id")
      end
    end

    describe "overriding default options" do
      let(:options) { { zip: true, format: "html" } }
      let(:payload) { { "Format" => "html", "Zip" => true, "Query" => query } }

      specify do
        create_export

        expect(connection).to have_received(:post)
      end

      it { is_expected.to be_an(IronBank::Export) }

      it "has an ID" do
        expect(create_export.id).to eq("zuora-export-id")
      end
    end
  end

  describe "#content" do
    subject(:content) { instance.content }

    let(:instance) do
      described_class.new(status: status, file_id: "zuora-file-id")
    end

    context "when status is nil (or anything but completed)" do
      let(:status) { nil }

      it { is_expected.to be_nil }
    end

    context "when export status is 'Completed'" do
      let(:status) { "Completed" }
      let(:client) { instance_double(IronBank::Client, connection: connection) }
      let(:connection) { instance_double(Faraday::Connection) }
      let(:response) { instance_double(Faraday::Response, body: "foo") }

      before do
        allow(IronBank).to receive(:client).and_return(client)

        allow(connection).
          to receive(:get).
          with("/v1/files/zuora-file-id").
          and_return(response)
      end

      it { is_expected.to eq("foo") }

      specify do
        content

        expect(connection).to have_received(:get)
      end

      it "is memoized" do
        2.times { instance.content }

        expect(connection).to have_received(:get).once
      end
    end
  end
end
