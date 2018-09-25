# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Resources::InvoiceItem do
  describe '::exclude_fields' do
    let(:fields) do
      %w[
        AppliedToChargeNumber
        Balance
      ]
    end

    subject { described_class.exclude_fields }
    it { is_expected.to eq(fields) }
  end
end
