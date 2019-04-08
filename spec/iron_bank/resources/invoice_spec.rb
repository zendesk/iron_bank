# frozen_string_literal: true

RSpec.describe IronBank::Resources::Invoice do
  describe "::exclude_fields" do
    let(:fields) do
      %w[
        AutoPay
        BillRunId
        BillToContactSnapshotId
        Body
        RegenerateInvoicePDF
        SoldToContactSnapshotId
      ]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end

  describe "#body" do
    let(:invoice)      { described_class.new(remote) }
    let(:invoice_body) { "base-64-encoded-invoice-pdf" }

    subject { invoice.body }

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
      let(:remote) { { "Id" => "zuora-invoice-id" } }

      let(:remote_with_body) do
        {
          id:   "zuora-invoice-id",
          body: invoice_body
        }
      end

      it "reloads the invoice to fetch the body" do
        expect(invoice).to receive(:reload).and_return(remote_with_body)
        expect(invoice.body).to eq(invoice_body)
      end
    end
  end
end
