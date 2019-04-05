# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank::QueryBuilder do
  let(:object) { "Product" }
  let(:fields) { [] }
  describe ".zoql" do
    subject(:zuora_query_string) do
      described_class.zoql(object, fields, conditions)
    end

    context "multiple query conditions" do
      let(:conditions) do
        { name: "zuora_user", account_id: "1" }
      end

      let(:multiple_conditions_zoql) do
        /Name='zuora_user' AND AccountId='1'/
      end

      it { is_expected.to match(multiple_conditions_zoql) }
    end

    context "boolean query conditions" do
      let(:conditions) do
        { is_last_segment: true }
      end

      let(:boolean_conditions_zoql) do
        /IsLastSegment=true/
      end

      it { is_expected.to match(boolean_conditions_zoql) }
    end

    context "single range query condition" do
      let(:conditions) do
        { account_ids: %w[1 2] }
      end

      let(:single_range_condition_zoql) do
        /where AccountIds='1' OR AccountIds='2'/
      end

      it { is_expected.to match(single_range_condition_zoql) }
    end

    context "multiple query conditions with range query condition" do
      let(:conditions) do
        { account_ids: %w[1 2], name: "zuora_user" }
      end

      it "matches the error message" do
        expect { subject }.
          to raise_error("Filter ranges must be used in isolation.")
      end
    end
  end
end
