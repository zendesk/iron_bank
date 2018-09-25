# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/cacheable'

RSpec.describe IronBank::Resources::CatalogTiers::DiscountAmount do
  it_behaves_like 'a cacheable resource' do
    let(:id) { 'a-zuora-rate-plan-charge-tier-id' }
  end

  describe '::exclude_fields' do
    let(:fields) do
      %w[
        Active
        DiscountPercentage
        IncludedUnits
        OveragePrice
        Price
      ]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end
end
