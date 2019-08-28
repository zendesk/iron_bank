# frozen_string_literal: true

require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::RatePlanChargeTier do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-rate-plan-charge-tier-id" }
  end
end
