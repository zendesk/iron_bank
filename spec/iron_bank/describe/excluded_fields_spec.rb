# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields do
  let(:object)     { IronBank::Resources.const_get(object_name) }
  let(:invalid_id) { described_class::INVALID_OBJECT_ID }

  subject(:call) { described_class.call(object_name: object_name) }

  describe "when the object does not have any unqueryable fields" do
    let(:object_name) { "Product" }

    before do
      allow(object).
        to receive(:where).
        with({ id: invalid_id })
    end

    it { is_expected.to be_empty }
  end

  describe "when object has the unqueryable fields" do
    let(:object_name) { "Account" }
    let(:query_fields) { %w[InvalidField1 Fields2 Field3] }

    before do
      allow(object).
        to receive(:query_fields).
        and_return(query_fields)

      num_query = 0
      allow(object).
        to receive(:where).
        with({ id: invalid_id }) do
          num_query += 1
          # the ff is necessary since DeduceFromQuery will result in execution
          # of additional queries to the object as it tries to identify by
          # elimination the unqueryable field(s) in the query.
          case num_query
          when 1 then raise error_class, error_message
          else anything
          end
        end
    end

    context "when query fails with an error" do
      let(:error_class) do
        [
          IronBank::BadRequestError,
          IronBank::InternalServerError
        ].sample
      end

      let(:error_message) { "error message" }

      before do
        allow(described_class::ExtractFromMessage).
          to receive(:call).
          and_return(extract_from_message)
        allow(described_class::DeduceFromQuery).
          to receive(:call).
          and_return(deduction_from_query)
      end

      context "when invalid fields can be extracted from message" do
        let(:extract_from_message) { %w[InvalidField1] }
        let(:deduction_from_query) { double }

        before { subject }

        it { is_expected.not_to be_empty }
        it { is_expected.to eq(extract_from_message) }

        it "will attempt to extract from error message" do
          expect(described_class::ExtractFromMessage).
            to have_received(:call).
            with(error_message)
        end

        it "will not attempt to deduce the invalid from query" do
          expect(described_class::DeduceFromQuery).
            not_to have_received(:call)
        end
      end

      context "when invalid fields cannot be extracted from message" do
        let(:extract_from_message) { nil }
        let(:deduction_from_query) { %w[InvalidField1] }

        before { subject }

        it { is_expected.not_to be_empty }
        it { is_expected.to eq(deduction_from_query) }

        it "will attempt to extract from error message" do
          expect(described_class::ExtractFromMessage).
            to have_received(:call).
            with(error_message)
        end

        it "will attempt to deduce the invalid from query" do
          expect(described_class::DeduceFromQuery).
            to have_received(:call).
            with(object)
        end
      end
    end
  end
end
