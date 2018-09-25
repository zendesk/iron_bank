# frozen_string_literal: true

RSpec.describe IronBank::Describe::Related do
  let(:file_path) { File.expand_path(file_name, 'spec/fixtures/related') }
  let(:doc)       { File.open(file_path) { |file| Nokogiri::XML(file) } }
  let(:related)   { described_class.from_xml(doc.at('object')) }

  context 'default payment method (for account)' do
    let(:file_name) { 'default_payment_method.xml' }

    describe '#type' do
      subject { related.type }
      it { is_expected.to eq('PaymentMethod') }
    end

    describe '#name' do
      subject { related.name }
      it { is_expected.to eq('DefaultPaymentMethod') }
    end

    describe '#label' do
      subject { related.label }
      it { is_expected.to eq('Default Payment Method') }
    end

    describe '#inspect' do
      let(:inspect) { /IronBank::Describe::Related:\w+ DefaultPaymentMethod/ }
      subject { related.inspect }
      it { is_expected.to match(inspect) }
    end
  end
end
