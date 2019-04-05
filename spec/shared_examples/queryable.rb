# frozen_string_literal: true

RSpec.shared_examples "a queryable resource" do
  describe "::find" do
    let(:id) { "zuora-object-id" }

    let(:connection) { instance_double(Faraday::Connection, get: response) }

    let(:response) { instance_double(Faraday::Response, body: anything) }

    let(:client) { instance_double(IronBank::Client, connection: connection) }

    before do
      allow(IronBank).to receive(:client).and_return(client)
    end

    subject(:find) { described_class.find(id) }

    it "returns an instance of the resource we are looking for" do
      expect(find).to be_an_instance_of(described_class)
    end

    context "id not present" do
      let(:id) { nil }

      it "raises IronBank::NotFound error" do
        expect { subject }.to raise_error(IronBank::NotFoundError)
      end
    end
  end

  describe "::find_each" do
    let(:client) { instance_double(IronBank::Client) }

    before do
      allow(IronBank).to receive(:client).and_return(client)
    end

    context "with a block" do
      before do
        allow(client).to receive(:query).and_return(result)
      end

      context "initial query done (< 2k records returnded)" do
        let(:result) do
          {
            done:    true,
            records: [
              { Id: "zuora-object-id-123" },
              { Id: "zuora-object-id-234" }
            ]
          }
        end

        it "queries IronBank and yield each record" do
          expect { |b| described_class.find_each(&b) }.to yield_control
        end
      end

      context "initial query not done (> 2k records)" do
        let(:result) do
          {
            done:         false,
            queryLocator: "query-locator-zuora-id",
            records:      [
              { Id: "zuora-object-id-123" },
              { Id: "zuora-object-id-234" }
            ]
          }
        end

        let(:more_results) do
          {
            done:    true,
            records: [
              { Id: "zuora-object-id-345" },
              { Id: "zuora-object-id-456" }
            ]
          }
        end

        it "continue querying IronBank until done" do
          expect(client).
            to receive(:query_more).
            with("query-locator-zuora-id").
            and_return(more_results)

          expect { |b| described_class.find_each(&b) }.to yield_control
        end
      end
    end

    context "no block given" do
      subject(:find_each) { described_class.find_each }
      it { is_expected.to be_an(Enumerable) }
    end
  end

  describe ":all" do
    subject(:all) { described_class.all }

    it "delegates to where without conditions" do
      expect(described_class).to receive(:where).with({})
      all
    end
  end

  describe "::where" do
    let(:conditions)   { { name: "My Resource Name" } }
    let(:query_result) { { records: records } }

    before do
      allow(IronBank::Query).to receive(:call).and_return(query_result)
    end

    subject(:where) { described_class.where(conditions) }

    context "no records found" do
      let(:records) { [] }
      it { is_expected.to eq([]) }
    end

    context "any record found" do
      let(:records)    { [{ Id: "zuora-object-id" }] }
      subject(:record) { where.first }
      it { is_expected.to be_an_instance_of(described_class) }
    end
  end
end
