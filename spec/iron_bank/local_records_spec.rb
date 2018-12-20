# frozen_string_literal: true

require 'spec_helper'

RSpec.describe IronBank::LocalRecords do
  describe '::directory' do
    subject { described_class.directory }
    it { is_expected.to eq('./config/export') }
  end

  describe '::export' do
    subject(:export) { described_class.export }

    context 'local export directory does not exist' do
      before do
        allow(Dir).to receive(:exist?).and_return(false)
      end

      it 'creates the local export directory if it does not exist' do
        stub_const('IronBank::LocalRecords::RESOURCES', [])
        expect(FileUtils).to receive(:mkdir_p)
        export
      end
    end

    context 'local export directory already exists' do
      before do
        allow(Dir).to receive(:exist?).and_return(true)
      end

      it 'creates the local export directory if it does not exist' do
        stub_const('IronBank::LocalRecords::RESOURCES', [])
        expect(FileUtils).not_to receive(:mkdir_p)
        export
      end
    end

    describe 'for each resource to export' do
      let(:directory) { './config/export' }

      it 'creates a CSV file' do
        IronBank::LocalRecords::RESOURCES.each do |resource|
          file_path = File.expand_path("#{resource}.csv", directory)
          expect(CSV).to receive(:open).with(file_path, 'w')
        end

        export
      end
    end

    context 'for one resource' do
      let(:csv_file) { instance_double(File) }
      let(:klass)    { double('resource class', fields: fields) }
      let(:fields)   { %w[id field custom_field] }
      let(:a_record) { instance_double(IronBank::Resource, to_csv_row: row) }
      let(:row)      { %w[some-id field-value custom-field-value] }

      before do
        stub_const('IronBank::LocalRecords::RESOURCES', %w[MyResource])
        allow(FileUtils).to receive(:mkdir_p)
        allow(CSV).to receive(:open).and_yield(csv_file)
        allow(IronBank::Resources).to receive(:const_get).and_return(klass)
        allow(klass).to receive(:find_each).and_yield(a_record)
      end

      it 'exports the records for the resource in CSV format with headers' do
        expect(csv_file).to receive(:<<).with(fields)
        expect(csv_file).to receive(:<<).with(row)
        export
      end
    end
  end
end
