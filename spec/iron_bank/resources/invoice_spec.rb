# frozen_string_literal: true

RSpec.describe IronBank::Resources::Invoice do
  before { IronBank::Schema.reset }

  describe "#body" do
    let(:invoice)      { described_class.new(remote) }
    let(:invoice_body) { "base-64-encoded-invoice-pdf" }

    subject(:pdf) { invoice.body }

    context "present in the remote" do
      let(:remote) do
        {
          id:   "zuora-invoice-id",
          body: invoice_body
        }
      end

      it { is_expected.to eq(invoice_body) }
    end

    context "absent from the remote" do
      let(:remote) { { id: "zuora-invoice-id" } }

      let(:remote_with_body) do
        {
          id:   "zuora-invoice-id",
          body: invoice_body
        }
      end

      it "reloads the invoice to fetch the body" do
        expect(invoice).
          to receive(:reload).
          and_return(described_class.new(remote_with_body))

        expect(pdf).to eq(invoice_body)
      end
    end
  end
end
