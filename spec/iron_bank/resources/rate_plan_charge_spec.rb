# frozen_string_literal: true

require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::RatePlanCharge do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-rate-plan-charge-id" }
  end
end
