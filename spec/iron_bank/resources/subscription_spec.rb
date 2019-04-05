# frozen_string_literal: true

require "spec_helper"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::Subscription do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-subscription-id" }
  end
end
