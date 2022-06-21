# frozen_string_literal: true

RSpec.describe IronBank::Collection do
  let(:klass) do
    Class.new(IronBank::Resource) do
      def related_records
        remote[:related_records]
      end
    end
  end
  let(:records) { build_resources }
  let(:conditions) { { account_id: "123" } }
  let(:subject) { described_class.new(klass, conditions, records) }

  def build_resources(*resource_attributes)
    resource_attributes.map { |attributes| klass.new(attributes) }
  end

  describe "#reload" do
    let(:new_records) { build_resources({ id: "xyz", name: "Foo Loo" }) }
    let(:reload) { subject.reload }

    it "makes a live where query" do
      expect(klass).to receive(:where).with(conditions)
      reload
    end

    it "updates the records for the resource" do
      allow(klass).to receive(:where).with(conditions).and_return(new_records)
      expect { reload }.
        to change(subject, :to_a).
        from(records).
        to(new_records)
    end
  end

  describe "#to_a" do
    it { expect(subject.to_a).to eq(records) }
  end

  describe "implicit conversions" do
    let(:records) do
      build_resources(
        { id: "1", related_records: described_class.new(klass, conditions, build_resources(*fruits)) },
        { id: "2", related_records: described_class.new(klass, conditions, build_resources(*vegetables)) },
        { id: "3", related_records: described_class.new(klass, conditions, build_resources(*nonedibles)) }
      )
    end

    let(:fruits) { [{ id: "1", name: "Apples" }, { id: "2", name: "Bananas" }] }
    let(:vegetables) { [{ id: "3", name: "Carrots" }, { id: "7", name: "Onions" }] }
    let(:nonedibles) { [{ id: "5", name: "Rocks" }, { id: "6", name: "Bark" }] }

    it "supports implicit conversion to an array" do
      first, second, third = subject

      expect(first).to eq records[0]
      expect(second).to eq records[1]
      expect(third).to eq records[2]
    end

    it "works with methods that rely on implicit array conversion under the hood such as #flat_map" do
      expected_records = build_resources(*[fruits, vegetables, nonedibles].flatten)
      expect(records.flat_map(&:related_records)).to eq expected_records
    end
  end

  describe "#flat_map" do
    let(:records) do
      build_resources(
        { id: "1", related_records: described_class.new(klass, conditions, build_resources(*fruits)) },
        { id: "2", related_records: described_class.new(klass, conditions, build_resources(*vegetables)) },
        { id: "3", related_records: described_class.new(klass, conditions, build_resources(*nonedibles)) }
      )
    end

    let(:fruits) { [{ id: "1", name: "Apples" }, { id: "2", name: "Bananas" }] }
    let(:vegetables) { [{ id: "3", name: "Carrots" }, { id: "7", name: "Onions" }] }
    let(:nonedibles) { [{ id: "5", name: "Rocks" }, { id: "6", name: "Bark" }] }

    it "works correctly" do
      expected_records = build_resources(*[fruits, vegetables, nonedibles].flatten)
      expect(records.flat_map(&:related_records)).to eq expected_records
    end
  end

  describe "delegates object methods to records" do
    it { expect delegate_method(:[]).to(:records) }

    it { expect delegate_method(:each).to(:records) }

    it { expect delegate_method(:empty?).to(:records) }

    it { expect delegate_method(:length).to(:records) }

    it { expect delegate_method(:map).to(:records) }

    it { expect delegate_method(:size).to(:records) }
  end
end
