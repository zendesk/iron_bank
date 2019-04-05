# frozen_string_literal: true

require "spec_helper"
require "shared_examples/action"

RSpec.describe IronBank::Actions::Execute do
  it_behaves_like "a Zuora action" do
    let(:args) do
      {
        ids:         %w[zuora-id-123 zuora-id-234 zuora-id-345],
        synchronous: false,
        type:        :invoice_split
      }
    end

    let(:endpoint) { "v1/action/execute" }

    let(:params) do
      {
        ids:         %w[zuora-id-123 zuora-id-234 zuora-id-345],
        synchronous: false,
        type:        "InvoiceSplit"
      }
    end
  end
end
