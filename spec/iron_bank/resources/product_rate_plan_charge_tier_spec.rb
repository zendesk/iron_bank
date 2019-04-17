# frozen_string_literal: true

require "shared_examples/local"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::ProductRatePlanChargeTier do
  describe "::exclude_fields" do
    let(:fields) do
      %w[
        Active
        IncludedUnits
        OveragePrice
        DiscountAmount
        DiscountPercentage
      ]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end

  let(:id) { "a-zuora-product-rate-plan-charge-tier-id" }

  it_behaves_like "a resource with local records"
  it_behaves_like "a cacheable resource"
end
