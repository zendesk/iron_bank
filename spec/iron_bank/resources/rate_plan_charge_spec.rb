# frozen_string_literal: true

require "shared_examples/cacheable"

RSpec.describe IronBank::Resources::RatePlanCharge do
  it_behaves_like "a cacheable resource" do
    let(:id) { "a-zuora-rate-plan-charge-id" }
  end

  describe "::excluded_fields" do
    subject { described_class.excluded_fields }
    it { is_expected.to eq(["RolloverBalance"]) }
  end

  describe "#rollover_balance" do
    let(:rate_plan_charge) { described_class.new(remote) }
    let(:rollover_balance) { "anything" }

    subject { rate_plan_charge.rollover_balance }

    context "present in the remote" do
      let(:remote) do
        { id: "zuora-rate-plan-charge-id", rollover_balance: rollover_balance }
      end

      it { is_expected.to eq(rollover_balance) }
    end

    context "absent from the remote" do
      let(:remote) { { id: "zuora-rate-plan-charge-id" } }

      let(:remote_with_rollover_balance) do
        { id: "zuora-rate-plan-charge-id", rollover_balance: rollover_balance }
      end

      it "reloads the rate plan charge to fetch the rollover balance" do
        expect(rate_plan_charge).
          to receive(:reload).
          and_return(described_class.new(remote_with_rollover_balance))

        expect(subject).to eq(rollover_balance)
      end
    end
  end
end
