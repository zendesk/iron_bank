# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields do
  let(:object)     { IronBank::Resources.const_get(object_name) }
  let(:invalid_id) { described_class::INVALID_OBJECT_ID }

  subject(:call) { described_class.call(object_name: object_name) }

  describe "when the object does not have any unqueryable fields" do
    let(:object_name) { "Product" }

    before do
      allow(object).to receive(:where).with(id: invalid_id) # Successful query
    end

    it "returns an empty array" do
      expect(call).to eq([])
    end
  end

  describe "when the object does have unqueryable fields" do
    let(:object_name)    { "Invoice" }
    let(:error_message1) { "invalid field for query: invoice.invalidfield1" }
    let(:error_message2) { "invalid field for query: invoice.invalidfield2" }
    let(:query_fields)   { %w[InvalidField2 InvalidField1 ValidField] }
    let(:sorted_fields)  { call.sort }

    before do
      allow(object).to receive(:query_fields).and_return(query_fields)

      num_query = 0

      # Querying `Object#where(id: invalid_id)`:
      #   - The first time ("InvalidField2") raises an exception
      #   - The second time ("InvalidField1") raises an exception
      #   - All following calls are successful
      allow(object).to receive(:where).with(id: invalid_id) do
        num_query += 1

        # NOTE: This ordering is dictated by the order of `query_fields`
        case num_query
        when 1 then raise IronBank::InternalServerError, error_message2
        when 2 then raise IronBank::InternalServerError, error_message1
        else        anything
        end
      end
    end

    it "makes three queries" do
      call

      expect(object).to have_received(:where).exactly(3).times
    end

    it "returns the unqueryable fields" do
      expect(call).to contain_exactly("InvalidField1", "InvalidField2")
    end

    it "returns a sorted array of unqueryable fields" do
      expect(call.sort).to eq(call)
    end
  end

  describe "when the query results in a `InternalServerError` error" do
    let(:object_name) { "Account" }

    before do
      allow(object).
        to receive(:where).
        with(id: invalid_id).
        and_raise(IronBank::InternalServerError)
    end

    it "raises a `RuntimeError` error" do
      expect { call }.to raise_error(RuntimeError, /Could not parse error/)
    end
  end
end
