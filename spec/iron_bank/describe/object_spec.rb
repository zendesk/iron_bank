# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::Describe::Object do
  describe '::from_xml' do
    let(:file_path) { File.expand_path(file_name, 'spec/fixtures/objects') }
    let(:doc)       { File.open(file_path) { |file| Nokogiri::XML(file) } }
    let(:object)    { described_class.from_xml(doc) }

    context 'Account' do
      let(:file_name) { 'account.xml' }

      describe '#name' do
        subject { object.name }
        it { is_expected.to eq('Account') }
      end

      describe '#label' do
        subject { object.label }
        it { is_expected.to eq('Account') }
      end

      describe '#fields' do
        let(:field_names) do
          %w[
            AccountNumber
            AdditionalEmailAddresses
            AllowInvoiceEdit
            Name
          ]
        end

        subject { object.fields.map(&:name) }
        it { is_expected.to eq(field_names) }
      end

      describe '#query_fields' do
        let(:fields) { %w[AccountNumber Name] }
        subject { object.query_fields }
        it { is_expected.to eq(fields) }
      end

      describe '#related' do
        let(:related_objects) do
          %w[
            BillToContact
            DefaultPaymentMethod
            ParentAccount
            SoldToContact
          ]
        end

        subject { object.related.map(&:name) }
        it { is_expected.to eq(related_objects) }
      end

      describe '#inspect' do
        subject { object.inspect }
        it { is_expected.to match(/IronBank::Describe::Object:\w+ Account/) }
      end

      describe '#export' do
        # NOTE: We are using a File double to verify this test case, so we need
        # to load the fixture **before** spying on File.
        let!(:account_object) { object }

        let(:export_path) do
          File.expand_path(
            'Account.xml',
            IronBank.configuration.schema_directory
          )
        end

        let(:exported) { instance_double(File) }

        before do
          allow(File).
            to receive(:open).
            with(export_path, 'w').
            and_yield(exported)
        end

        subject(:export) { account_object.export }

        it 'exports the XML document' do
          expect(exported).to receive(:<<).with(doc.to_xml)
          export
        end
      end
    end
  end

  describe '::from_connection' do
    let(:connection) { instance_double(Faraday::Connection) }
    let(:name)       { 'Account' }
    let(:endpoint)   { "v1/describe/#{name}" }

    let(:body) do
      instance_double(Faraday::Response, body: '<some>XML</some>')
    end

    subject(:object) { described_class.from_connection(connection, name) }

    context 'HTTP 200 OK' do
      it 'retrieves the describe XML file from IronBank' do
        expect(connection).to receive(:get).with(endpoint).and_return(body)
        object
      end
    end

    context 'HTTP 401 Unauthorized' do
      let(:unauthorized_body) do
        {
          'success' => false,
          'reasons' => [
            {
              'code'    => 90_000_011,
              'message' => 'this resource is protected, please sign in first'
            }
          ]
        }
      end

      let(:unauthorized_from_zuora) do
        instance_double(Faraday::Response, body: unauthorized_body)
      end

      it 'retries the GET request' do
        expect(connection).
          to receive(:get).
          with(endpoint).
          and_return(unauthorized_from_zuora, body)

        object
      end
    end
  end
end
