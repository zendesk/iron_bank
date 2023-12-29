# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields::ExtractFromMessage do
  subject(:call) { described_class.call(message) }

  describe "when a message could be processed" do
    context "and includes generic fault field" do
      let(:message) { "invalid field for query: product.invalidfield" }

      it "returns extracted failed fields" do
        expect(call).to include("invalidfield")
      end
    end

    context "and includes Invoice Bill Run" do
      let(:message) { "Cannot use the BillRunId field in the select clause" }

      it "returns extracted failed fields" do
        expect(call).to include("BillRunId")
      end
    end

    context "and includes Invoice Body" do
      let(:message) { "Can only query one invoice body at a time" }

      it "returns extracted failed fields" do
        expect(call).to include("body")
      end
    end

    context "and catalog tier should only query the price field" do
      let(:message) { "use Price or DiscountAmount or DiscountPercentage" }

      it "returns extracted failed fields" do
        expect(call).to include("DiscountAmount", "DiscountPercentage")
      end
    end

    context "and there are catalog plan currencies" do
      let(:message) { "When querying for active currencies" }

      it "returns extracted failed fields" do
        expect(call).to include("activecurrencies")
      end
    end

    context "and included rollover balance" do
      let(:message) { "You can only query RolloverBalance in particular" }

      it "returns extracted failed fields" do
        expect(call).to include("RolloverBalance")
      end
    end

    context "and subscription should only query the price field" do
      let(:message) { "OveragePrice, Price, IncludedUnits, DiscountAmount or DiscountPercentage" }

      it "returns extracted failed fields" do
        expect(call).to_not include("Price")
      end
    end
  end

  describe "when a message could not be processed" do
    let(:message) { "some invalid message" }

    it "returns from a call" do
      expect(call).to be_nil
    end
  end
end
