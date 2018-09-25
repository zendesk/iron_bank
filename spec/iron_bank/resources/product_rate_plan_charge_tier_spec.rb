# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Resources::ProductRatePlanChargeTier do
  describe '::where' do
    let(:conditions) { anything }

    subject(:query) { described_class.where(conditions) }

    it 'delegates to all tier subclasses' do
      expect(IronBank::Resources::CatalogTiers::DiscountAmount).
        to receive(:where).with(conditions).and_return([:discount_amount])
      expect(IronBank::Resources::CatalogTiers::DiscountPercentage).
        to receive(:where).with(conditions).and_return([:discount_percentage])
      expect(IronBank::Resources::CatalogTiers::Price).
        to receive(:where).with(conditions).and_return([:price])

      expect(query.sort).to eq(%i[discount_amount discount_percentage price])
    end
  end

  describe '::find_each' do
    context 'with a block' do
      it 'executes the block for all tier subclasses' do
        expect(IronBank::Resources::CatalogTiers::DiscountAmount).
          to receive(:find_each).and_yield
        expect(IronBank::Resources::CatalogTiers::DiscountPercentage).
          to receive(:find_each).and_yield
        expect(IronBank::Resources::CatalogTiers::Price).
          to receive(:find_each).and_yield

        expect { |b| described_class.find_each(&b) }.to yield_control
      end
    end

    context 'no block given' do
      subject(:find_each) { described_class.find_each }
      it { is_expected.to be_an(Enumerable) }
    end
  end

  describe '#to_csv_row' do
    let(:remote_with_discount_percentage) do
      {
        'Id'                 => 'zuora-123',
        'DiscountPercentage' => 10.0
      }
    end

    let(:remote_with_discount_amount) do
      {
        'Id'             => 'zuora-234',
        'DiscountAmount' => 50
      }
    end

    let(:remote_with_price) do
      {
        'Id'    => 'zuora-345',
        'Price' => 99
      }
    end

    let(:fields) do
      %w[
        Id
        DiscountAmount
        DiscountPercentage
        Price
      ]
    end

    before { allow(described_class).to receive(:fields).and_return(fields) }

    subject { described_class.new(remote).to_csv_row }

    context 'DiscountPercentage tier' do
      let(:remote) { remote_with_discount_percentage }

      let(:row_with_all_fields) do
        ['zuora-123', nil, 10.0, nil]
      end

      it { is_expected.to eq(row_with_all_fields) }
    end

    context 'DiscountAmount tier' do
      let(:remote) { remote_with_discount_amount }

      let(:row_with_all_fields) do
        ['zuora-234', 50, nil, nil]
      end

      it { is_expected.to eq(row_with_all_fields) }
    end

    context 'Price tier' do
      let(:remote) { remote_with_price }

      let(:row_with_all_fields) do
        ['zuora-345', nil, nil, 99]
      end

      it { is_expected.to eq(row_with_all_fields) }
    end
  end
end
