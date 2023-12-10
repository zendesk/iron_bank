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
  end

  describe "when object has the unqueryable fields" do
    let(:object_name) { "Account" }
    let(:query_fields) { %w[InvalidField1 Fields2 Field3] }

    before do
      allow(object).to receive(:query_fields).and_return(query_fields)

      num_query = 0
      allow(object).to receive(:where).with({ id: invalid_id }) do
        num_query += 1

        case num_query
        when 1 then raise error_class, error_message
        else anything
        end
      end
    end

    context "query fails with IronBank::BadRequestError" do
      let(:error_class) { IronBank::BadRequestError }
      let(:error_message) { "BadRequestError message" }

      before do
        allow(described_class::ExtractFromMessage).to receive(:call)
      end

      it "handles an error with ExtractFromMessage" do
        call
        expect(described_class::ExtractFromMessage).to have_received(:call).with(error_message)
      end
    end

    context "query fails with InternalServerError" do
      let(:error_class) { IronBank::InternalServerError }
      let(:error_message) { "InternalServerError message" }

      before do
        allow(described_class::ExtractFromMessage).to receive(:call)
        allow(described_class::DeduceFromQuery).to receive(:call).and_return([])
      end

      it "handles an error with DeduceFromQuery" do
        call
        expect(described_class::ExtractFromMessage).to have_received(:call).with(error_message)
        expect(described_class::DeduceFromQuery).to have_received(:call).with(object)
      end
    end
  end
end
