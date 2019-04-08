# frozen_string_literal: true

require "spec_helper"

RSpec.describe IronBank::Configuration do
  let(:default_schema) { "./config/schema" }
  let(:default_export) { "./config/export" }
  let(:configuration)  { described_class.new }

  describe "#schema_directory" do
    subject { configuration.schema_directory }
    it { is_expected.to eq(default_schema) }
  end

  describe "#schema_directory=" do
    let(:schema_directory) { anything }
    subject(:set_schema)   { configuration.schema_directory = schema_directory }

    it "changes the instance variable" do
      expect { set_schema }.
        to change(configuration, :schema_directory).
        from(default_schema).
        to(schema_directory)
    end

    it "resets the imported schema" do
      expect(IronBank::Schema).to receive(:reset)
      set_schema
    end

    it "calls #with_schema on each resource, except modules" do
      IronBank::Resources.constants.each do |resource|
        klass = IronBank::Resources.const_get(resource)
        next unless klass.is_a?(Class)

        expect(klass).to receive(:with_schema)
      end

      set_schema
    end
  end

  describe "#export_directory" do
    subject { configuration.export_directory }
    it { is_expected.to eq(default_export) }
  end

  describe "#export_directory=" do
    let(:export_directory) { anything }

    subject(:set_export) { configuration.export_directory = export_directory }

    it "changes the instance variable" do
      expect { set_export }.
        to change(configuration, :export_directory).
        from(default_export).
        to(export_directory)
    end

    it "resets the local store for each resource defined in LocalRecords" do
      %w[
        Product
        ProductRatePlan
        ProductRatePlanCharge
        ProductRatePlanChargeTier
      ].each do |resource|
        klass = IronBank::Resources.const_get(resource)
        expect(klass).to receive(:reset_store)
      end

      set_export
    end
  end
end
