# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/action'

RSpec.describe IronBank::Actions::Amend do
  it_behaves_like 'a Zuora action' do
    let(:args)     { anything }
    let(:endpoint) { 'v1/action/amend' }
    let(:params)   { { requests: args } }
  end
end
