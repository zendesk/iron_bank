# frozen_string_literal: true

RSpec.describe IronBank::Schema do
  describe "::directory" do
    subject { described_class.directory }
    it { is_expected.to eq("./config/schema") }
  end

  describe "::export" do
    let(:connection) { instance_double(Faraday::Connection) }
    let(:client) { instance_double(IronBank::Client, connection: connection) }
    let(:object) { instance_double(IronBank::Describe::Object) }

    let(:tenant) do
      instance_double(IronBank::Describe::Tenant, objects: [object])
    end

    subject(:export) { described_class.export }

    before do
      allow(IronBank).to receive(:client).and_return(client)

      allow(IronBank::Describe::Tenant).
        to receive(:from_connection).
        and_return(tenant)
    end

    it "exports each object in the tenant" do
      expect(object).to receive(:export)
      expect(described_class).to receive(:reset)
      expect(described_class).to receive(:import)
      export
    end

    context "Invalid XML received from Zuora" do
      before do
        allow(object).
          to receive(:export).and_raise(IronBank::Describe::Object::InvalidXML)
      end

      it "skips the object" do
        expect { export }.not_to raise_error
      end
    end
  end

  describe "::reset" do
    before do
      IronBank::Schema.instance_variable_set :@import, anything
    end

    subject(:reset) { described_class.reset }

    it "nil the @import instance variable" do
      expect { reset }.
        to change { IronBank::Schema.instance_variable_get :@import }.
        from(anything).
        to(nil)
    end
  end

  describe "::import" do
    subject { described_class.import }

    context "schema has not been exported yet" do
      before do
        IronBank.configure { |config| config.schema_directory = "the_void" }
      end

      after do
        IronBank.configure do |config|
          config.schema_directory = "./config/schema"
        end
      end

      it { is_expected.to eq({}) }
    end

    context "schema has been exported" do
      before do
        IronBank.configure do |config|
          config.schema_directory = "spec/fixtures/objects"
        end
      end

      after do
        IronBank.configure do |config|
          config.schema_directory = "./config/schema"
        end
      end

      it { is_expected.to include("Account") }
    end
  end

  describe "::for" do
    before do
      IronBank.configure do |config|
        config.schema_directory = "spec/fixtures/objects"
      end
    end

    after do
      IronBank.configure do |config|
        config.schema_directory = "./config/schema"
      end
    end

    subject { described_class.for("Account") }
    it { is_expected.to be_a(IronBank::Describe::Object) }
  end
end
