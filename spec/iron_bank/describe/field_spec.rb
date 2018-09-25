# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Describe::Field do
  let(:file_path) { File.expand_path(file_name, 'spec/fixtures/fields') }
  let(:doc)       { File.open(file_path) { |file| Nokogiri::XML(file) } }
  let(:field)     { described_class.from_xml(doc) }

  context 'standard field (AccountNumber)' do
    let(:file_name) { 'account_number.xml' }

    describe '#max_length' do
      subject { field.max_length }
      it { is_expected.to eq(0) }
    end

    describe '#name' do
      subject { field.name }
      it { is_expected.to eq('AccountNumber') }
    end

    describe '#contexts' do
      subject { field.contexts }
      it { is_expected.to eq(%w[soap export]) }
    end

    describe '#inspect' do
      let(:inspect) { /IronBank::Describe::Field:0x\w+ AccountNumber \(text\)/ }
      subject { field.inspect }
      it { is_expected.to match(inspect) }
    end
  end

  context 'standard field with options (Currency)' do
    let(:file_name) { 'currency.xml' }

    describe '#name' do
      subject { field.name }
      it { is_expected.to eq('Currency') }
    end

    describe '#required?' do
      subject { field.required? }
      it { is_expected.to eq(true) }
    end

    describe '#options' do
      subject { field.options }
      it { is_expected.to eq(%w[EUR GBP USD]) }
    end
  end

  context 'custom field' do
    let(:file_name) { 'my_custom_field.xml' }

    describe '#custom?' do
      subject { field.custom? }
      it { is_expected.to eq(true) }
    end

    describe '#max_length' do
      subject { field.max_length }
      it { is_expected.to eq(255) }
    end
  end
end
