# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/operation'

RSpec.describe IronBank::Operations::BillingPreview do
  it_behaves_like 'a Zuora operation' do
    let(:args)     { anything }
    let(:endpoint) { 'v1/operations/billing-preview' }
    let(:params)   { { requests: args } }
  end
end
