# frozen_string_literal: true

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

    context "when a scalar value contains a single quote" do
      let(:conditions) do
        { name: "O'Brien" }
      end

      it "escapes the quote with a backslash per Zuora filter statements" do
        expect(zuora_query_string).to include("Name='O\\'Brien'")
      end
    end

    context "when a scalar value contains a backslash" do
      let(:conditions) do
        { name: "acme\\corp" }
      end

      it "escapes backslashes per Zuora filter statements" do
        expect(zuora_query_string).to include("Name='acme\\\\corp'")
      end
    end

    context "when a scalar value attempts to inject additional ZOQL" do
      let(:conditions) do
        { account_number: "A0000001' OR AccountNumber='A0000002" }
      end

      it "keeps the payload inside one string literal" do
        expect(zuora_query_string).to eq(
          "select  from Product where " \
          "AccountNumber='A0000001\\' OR AccountNumber=\\'A0000002'"
        )
      end

      it "does not emit an additional OR condition outside the literal" do
        expect(zuora_query_string).not_to match(
          /AccountNumber='A0000001'\s+OR\s+AccountNumber=/
        )
      end
    end

    context "when a scalar value contains a backslash before a quote" do
      let(:conditions) do
        { account_number: "x\\' OR AccountNumber='A2" }
      end

      it "escapes backslashes and quotes so the value stays one literal" do
        expect(zuora_query_string).to eq(
          "select  from Product where " \
          "AccountNumber='x\\\\\\' OR AccountNumber=\\'A2'"
        )
      end

      it "does not emit an additional OR condition outside the literal" do
        expect(zuora_query_string).not_to match(
          /AccountNumber='x\\'\s+OR\s+AccountNumber=/
        )
      end
    end

    context "when an array value contains a single quote" do
      let(:conditions) do
        { name: ["O'Brien", "Smith"] }
      end

      it "escapes each option inside its own string literal" do
        expect(zuora_query_string).to include("Name='O\\'Brien' OR Name='Smith'")
      end
    end

    context "when an array value attempts to inject additional ZOQL" do
      let(:conditions) do
        { account_number: ["A0000001' OR AccountNumber='A0000002"] }
      end

      it "keeps the payload inside one string literal per option" do
        expect(zuora_query_string).to eq(
          "select  from Product where " \
          "AccountNumber='A0000001\\' OR AccountNumber=\\'A0000002'"
        )
      end
    end
  end
end
