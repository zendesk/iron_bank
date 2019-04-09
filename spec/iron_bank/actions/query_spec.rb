# frozen_string_literal: true

require "shared_examples/action"

RSpec.describe IronBank::Actions::Query do
  it_behaves_like "a Zuora action" do
    let(:args)     { anything }
    let(:endpoint) { "v1/action/query" }
    let(:params)   { { 'queryString': args } }
  end
end
