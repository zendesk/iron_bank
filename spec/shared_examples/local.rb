# frozen_string_literal: true

RSpec.shared_examples "a resource with local records" do
  let(:client) { instance_double(IronBank::Client) }

  context "local records exist" do
    before do
      IronBank.configure do |config|
        config.export_directory = "spec/fixtures/export"
      end
    end

    after do
      IronBank.configure do |config|
        config.export_directory = "./config/export"
      end
    end

    describe "::find" do
      subject(:find) { described_class.find(id) }

      it "loads the CSV file and return the record without making a request" do
        expect(IronBank::Resource).not_to receive(:find)
        find
      end

      it { is_expected.to be_a(described_class) }

      specify do
        expect(find.id).to eq(id)
      end
    end

    describe "::find_each" do
      context "with a block" do
        it "uses the store and yield each record" do
          expect { |b| described_class.find_each(&b) }.to yield_control
        end
      end

      context "no block given" do
        subject(:find_each) { described_class.find_each }
        it { is_expected.to be_an(Enumerable) }
      end
    end

    describe "::all" do
      subject(:all) { described_class.all }

      it "loads the CSV file and return the record without making a request" do
        expect(IronBank::Resource).not_to receive(:all)
        all
      end

      it { is_expected.to be_an(Array) }

      specify do
        expect(all.first.id).to eq(id)
      end
    end

    describe "::where" do
      let(:conditions) { { id: id } }

      subject(:where) { described_class.where(conditions) }

      it "loads the CSV file and return the record without making a request" do
        expect(IronBank::Resource).not_to receive(:where)
        where
      end

      it { is_expected.to be_an(Array) }

      specify do
        expect(where.first.id).to eq(id)
      end
    end
  end

  context "local records do not exist" do
    # NOTE: here we DO need to override the directory to a dummy one since
    # the gem could have already exported records in the default directory.
    before do
      IronBank.configure do |config|
        config.export_directory = "the_void"
      end
    end

    after do
      IronBank.configure do |config|
        config.export_directory = "./config/export"
      end
    end

    describe "::find" do
      subject(:find) { described_class.find(id) }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:find).with(id)
        find
      end
    end

    describe "::find_each" do
      context "with a block" do
        subject(:find_each) { described_class.find_each {} }

        it "yields and make a live query" do
          expect(IronBank::Resource).to receive(:find_each)
          find_each
        end
      end

      context "no block given" do
        subject(:find_each) { described_class.find_each }
        it { is_expected.to be_an(Enumerable) }
      end
    end

    describe "::all" do
      subject(:all) { described_class.all }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:all)
        all
      end
    end

    describe "::first" do
      subject(:first) { described_class.first }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:first)
        first
      end
    end

    describe "::where" do
      let(:conditions) { { id: id } }

      subject(:where) { described_class.where(conditions) }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:where).with(conditions, limit: 0)
        where
      end
    end
  end
end
