# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields::DeduceFromQuery do
  let(:working_fields) { %w[ValidField1 ValidField2] }
  let(:failed_fields) { %w[InvalidField1 InvalidField2] }
  let(:query_fields) { failed_fields + working_fields }
  let(:object)     { IronBank::Resources.const_get(object_name) }
  let(:invalid_id) { described_class::INVALID_OBJECT_ID }

  subject(:call) { described_class.call(object) }

  before do
    allow(object).to receive(:query_fields).and_return(query_fields)

    allow(object).to receive(:where).with({ id: invalid_id }) do
      if query_fields.include?("InvalidField1") || query_fields.include?("InvalidField2")
        raise IronBank::InternalServerError
      end

      true
    end
  end

  describe "Deduce failed fields from query" do
    let(:object_name) { "Product" }

    it "extracts failed fields by binary search" do
      expect(call).to contain_exactly(*failed_fields)
    end
  end
end
