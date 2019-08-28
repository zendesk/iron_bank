# frozen_string_literal: true

RSpec.shared_examples "a cacheable resource" do
  context "with IronBank.cache nil" do
    it "has no cache configured" do
      expect(IronBank.configuration.cache).to be nil
    end

    describe "::find" do
      subject(:find_without_cache) { described_class.find(id) }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:find).with(id)
        find_without_cache
      end
    end

    describe "::where" do
      let(:conditions) { { id: id } }

      subject(:where_without_cache) { described_class.where(conditions) }

      it "makes a live query" do
        expect(IronBank::Resource).to receive(:where).with(conditions, limit: 0)
        where_without_cache
      end
    end
  end

  context "with IronBank.cache set" do
    let(:cache) { double("a cache store") }

    before do
      IronBank.configure do |config|
        config.cache = cache
      end
    end

    after { IronBank.configuration.cache = nil }

    describe "::find" do
      subject(:find_with_cache) { described_class.find(id) }

      it "fetches the cache using the id as the cache key" do
        expect(cache).to receive(:fetch).with(id, force: false)
        find_with_cache
      end
    end

    describe "::where" do
      let(:conditions) { { id: id } }

      subject(:where_with_cache) { described_class.where(conditions) }

      let(:cache_key) do
        conditions.merge(object_name: described_class.to_s)
      end

      it "fetches the cache using a key made out of conditions + class name" do
        expect(cache).to receive(:fetch).with(cache_key)
        where_with_cache
      end
    end

    describe "#cache" do
      let(:an_instance) { described_class.new }

      subject(:cache_instance_method) { an_instance.send :cache }

      it "delegates to the class method" do
        expect(described_class).to receive(:cache)
        cache_instance_method
      end
    end

    describe "#reload" do
      let(:remote)      { { id: "resource-id" } }
      let(:response)    { instance_double(IronBank::Resource, remote: remote) }
      let(:an_instance) { described_class.new(remote) }

      subject(:reload) { an_instance.reload }

      before do
        allow(cache).
          to receive(:fetch).
          with("resource-id", force: true).
          and_return(response)
      end

      it "forces a fetch for live data" do
        reload

        expect(cache).to have_received(:fetch)
      end

      it "removes all instance variables before fetching live data" do
        an_instance.instance_variable_set(:@foo, "bar")
        reload
        expect(an_instance.instance_variables).to eq [:@remote]
      end

      it "returns the instance itself" do
        expect(reload).to be_a(described_class)
      end
    end
  end
end
