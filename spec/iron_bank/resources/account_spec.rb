# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Resources::Account do
  let(:fields) do
    [
      instance_double(IronBank::Describe::Field, name: 'Id'),
      instance_double(IronBank::Describe::Field, name: 'ParentId')
    ]
  end

  let(:schema) { instance_double(IronBank::Describe::Object, fields: fields) }

  before do
    allow(IronBank::Schema).to receive(:for).with('Account').and_return(schema)
    described_class.with_schema
  end

  after do
    # NOTE: Not resetting the instance variable here seems to leak the
    #       `instance_double(IronBank::Describe::Object)` to the other examples.
    described_class.instance_variable_set :@schema, nil
  end

  describe '::exclude_fields' do
    let(:excluded_fields) do
      %w[
        TaxExemptEntityUseCode
        TotalDebitMemoBalance
        UnappliedCreditMemoAmount
      ]
    end

    subject { described_class.exclude_fields }
    it      { is_expected.to eq(excluded_fields) }
  end

  describe 'instance methods' do
    let(:instance) do
      described_class.new(
        id:        'zuora_account_id_123',
        parent_id: parent_account_id
      )
    end

    let(:parent_account) do
      described_class.new(
        id:        parent_account_id,
        parent_id: root_parent_account_id
      )
    end

    let(:root_parent_account) do
      described_class.new(id: root_parent_account_id)
    end

    let(:accounts) do
      {
        parent_account_id      => parent_account,
        root_parent_account_id => root_parent_account
      }
    end

    before do
      allow(described_class).
        to receive(:find) { |account_id| accounts[account_id] }
    end

    describe '#ultimate_parent' do
      subject { instance.ultimate_parent }

      context 'when account has zero parents' do
        let(:parent_account_id) { nil }

        it { is_expected.to be_nil }
      end

      context 'when account has one parent' do
        let(:parent_account_id)      { 'parent_account_id_234' }
        let(:root_parent_account_id) { nil }

        it { is_expected.to eq(parent_account) }
      end

      context 'when account has more than one parent' do
        let(:parent_account_id)      { 'parent_account_id_234' }
        let(:root_parent_account_id) { 'root_parent_account_id_345' }

        it { is_expected.to eq(root_parent_account) }
      end
    end

    describe '#root' do
      subject { instance.root }

      context 'when account has zero parents' do
        let(:parent_account_id) { nil }

        it { is_expected.to eq(instance) }
      end

      context 'when account has one or more parents' do
        let(:parent_account_id)      { 'parent_account_id_234' }
        let(:root_parent_account_id) { 'root_parent_account_id_345' }

        it { is_expected.to eq(root_parent_account) }
      end
    end
  end
end
