# frozen_string_literal: true

require "shared_examples/action"

RSpec.describe IronBank::Actions::Query do
  context "only passing a ZOQL string" do
    it_behaves_like "a Zuora action" do
      let(:args)     { "select FieldName from ObjectName" }
      let(:endpoint) { "v1/action/query" }
      let(:params)   { { queryString: args } }
    end
  end

  context "passing ZOQL and a limit" do
    it_behaves_like "a Zuora action" do
      let(:zoql)         { "select FieldName from ObjectName" }
      let(:limit)        { 1 }
      let(:endpoint)     { "v1/action/query" }
      let(:params)       { { queryString: zoql, conf: { batchSize: limit } } }
      let(:execute_call) { described_class.call(zoql, limit: limit) }
    end
  end
end
