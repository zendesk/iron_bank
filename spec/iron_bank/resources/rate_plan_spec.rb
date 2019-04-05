# frozen_string_literal: true

require "spec_helper"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::RatePlan do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-rate-plan-id" }
  end
end
