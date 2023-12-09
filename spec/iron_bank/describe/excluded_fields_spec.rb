# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields do
  let(:object)     { IronBank::Resources.const_get(object_name) }
  let(:invalid_id) { described_class::INVALID_OBJECT_ID }

  subject(:call) { described_class.call(object_name: object_name) }

  describe "when the object does not have any unqueryable fields" do
    let(:object_name) { "Product" }

    before do
      allow(object).to receive(:where).with({ id: invalid_id }) # Successful query
    end

    it "returns an empty array" do
      expect(call).to eq([])
    end

    context "with invalid fields" do
      let!(:fields_count) { query_fields.size }

      before do
        allow(object).to receive(:query_fields).and_return(query_fields)

        num_query = 0

        # Querying `Object#where(id: invalid_id)`:
        #   - The first 2 queries are initial and failed
        #   - Plus 2 * invalid fields count and its failed
        #   - All following calls are successful
        allow(object).to receive(:where).with({ id: invalid_id }) do
          num_query += 1

          # NOTE: This ordering is dictated by the order of `query_fields`
          case num_query
          when 0..invalid_fields_count * 2 then raise IronBank::InternalServerError
          else anything
          end
        end
      end

      context "when 1 invalid field" do
        let(:query_fields) { %w[InvalidField1 Fields2 Field3] }
        let(:invalid_fields_count) { 1 }

        it "makes initial 2 queries and 2 * working query fields count queries" do
          call

          expect(object).to have_received(:where).exactly(2 + (invalid_fields_count * 2)).times
        end

        it "returns the failed field" do
          expect(call).to contain_exactly("InvalidField1")
        end

        it "returns a sorted array of unqueryable fields" do
          expect(call.sort).to eq(call)
        end
      end

      context "when 2 invalid fields" do
        let(:query_fields) { %w[InvalidField1 InvalidField2 Field3] }
        let(:invalid_fields_count) { 2 }

        it "makes initial 2 queries and 2 * working query fields count queries" do
          call

          expect(object).to have_received(:where).exactly(2 + (invalid_fields_count * 2)).times
        end

        it "returns the failed fields" do
          expect(call).to contain_exactly("InvalidField1", "InvalidField2")
        end
      end
    end
  end
end
