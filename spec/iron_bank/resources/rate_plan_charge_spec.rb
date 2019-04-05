# frozen_string_literal: true

require "spec_helper"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::RatePlanCharge do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-rate-plan-charge-id" }
  end

  describe "::exclude_fields" do
    let(:fields) do
      %w[
        DiscountAmount
        DiscountClass
        DiscountPercentage
        IncludedUnits
        OveragePrice
        Price
        RevenueRecognitionRuleName
        RolloverBalance
      ]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end
end
