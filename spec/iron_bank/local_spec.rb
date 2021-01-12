# frozen_string_literal: true

RSpec.describe IronBank::Local do
  describe "::where" do
    subject do
      Struct.new(:id, :name, :type) do
        extend IronBank::Local
      end
    end

    let(:resource1) { subject.new("id1", "n1", "Foo") }
    let(:resource2) { subject.new("id2", "n1", "Foo") }
    let(:resource3) { subject.new("id3", "n1", "Bar") }

    before do
      allow(subject).to receive(:store).and_return(
        {
          "id1" => resource1,
          "id2" => resource2,
          "id3" => resource3
        }
      )
    end

    context "when condition is single value" do
      it "returns matches against value" do
        expect(subject.where({ id: "id1" })).to contain_exactly(resource1)
        expect(subject.where({ type: "Foo" })).to contain_exactly(resource1, resource2)
      end
    end

    context "when condition is an array of values" do
      it "returns matches against any element of the array" do
        expect(subject.where({ id: %w[id1 id3] })).to contain_exactly(resource1, resource3)
        expect(subject.where({ type: %w[Foo Bar] })).to contain_exactly(resource1, resource2, resource3)
      end
    end
  end
end
