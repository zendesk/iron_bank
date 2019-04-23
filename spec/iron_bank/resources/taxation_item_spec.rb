# frozen_string_literal: true

RSpec.describe IronBank::Resources::TaxationItem do
  describe "::exclude_fields" do
    let(:fields) do
      %w[Balance]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end
end
