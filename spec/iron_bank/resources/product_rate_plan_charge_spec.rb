# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/local'
require 'shared_examples/cacheable'

RSpec.describe IronBank::Resources::ProductRatePlanCharge do
  let(:id) { 'a-zuora-product-rate-plan-charge-id' }
  it_behaves_like 'a resource with local records'
  it_behaves_like 'a cacheable resource'

  describe '::exclude_fields' do
    let(:fields) { %w[DiscountClass] }
    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end
end
