# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields::DeduceFromQuery do
  let(:valid_fields) { %w[ValidField1 ValidField2] }
  let(:invalid_fields) { %w[InvalidField1 InvalidField2] }
  let(:query_fields) { (valid_fields + invalid_fields).shuffle }
  let(:object_name) { "Product" }
  let(:object) { IronBank::Resources.const_get(object_name) }
  let(:invalid_object_id) { described_class::INVALID_OBJECT_ID }

  subject(:call) { described_class.call(object) }

  before do
    allow(object).
      to receive(:query_fields).
      and_return(query_fields)
    allow(object).
      to receive(:where).
      with({ id: invalid_object_id }) do
        raise IronBank::InternalServerError unless (query_fields & invalid_fields).none?
      end
  end

  context "when query has valid fields" do
    let(:invalid_fields) { [] }

    it "does not extract fields " do
      expect(call).to eq([])
    end
  end

  context "when query has invalid fields" do
    let(:valid_fields) { [] }

    it "extracts all query fields " do
      expect(call).to contain_exactly(*query_fields)
    end
  end

  context "when query is a mix of shuffled valid and invalid fields" do
    it "extracts the invalid fields" do
      expect(call).to contain_exactly(*invalid_fields)
    end
  end
end
