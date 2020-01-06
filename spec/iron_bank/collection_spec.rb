# frozen_string_literal: true

RSpec.describe IronBank::Collection do
  let(:klass) { IronBank::Resource }
  let(:records) { [] }
  let(:conditions) { { account_id: "123" } }
  let(:subject) { described_class.new(klass, conditions, records) }

  describe "#reload" do
    let(:new_records) { [{ id: "xyz", name: "Foo Loo" }] }
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

  describe "delegates object methods to records" do
    it { expect delegate_method(:[]).to(:records) }

    it { expect delegate_method(:each).to(:records) }

    it { expect delegate_method(:empty?).to(:records) }

    it { expect delegate_method(:length).to(:records) }

    it { expect delegate_method(:map).to(:records) }

    it { expect delegate_method(:size).to(:records) }
  end
end
