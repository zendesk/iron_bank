# frozen_string_literal: true

require "spec_helper"
require "shared_examples/action"

RSpec.describe IronBank::Actions::QueryMore do
  it_behaves_like "a Zuora action" do
    let(:args)     { anything }
    let(:endpoint) { "v1/action/queryMore" }
    let(:params)   { { 'queryLocator': args } }
  end
end
