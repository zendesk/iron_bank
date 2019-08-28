# frozen_string_literal: true

require "shared_examples/local"
require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::ProductRatePlan do
  let(:id) { "a-zuora-product-rate-plan-id" }
  it_behaves_like "a resource with local records"
  it_behaves_like "a cacheable resource"

  describe "#active_currencies" do
    let(:client) { instance_double(IronBank::Client) }
    let(:plan)   { described_class.new(id: "a-plan-id") }

    let(:query_string) do
      "select ActiveCurrencies from ProductRatePlan where Id='a-plan-id'"
    end

    before do
      allow(IronBank).to receive(:client).and_return(client)
    end

    subject(:active_currencies) { plan.active_currencies }

    it "makes an additional query" do
      expect(client).to receive(:query).with(query_string)
      active_currencies
    end
  end
end
