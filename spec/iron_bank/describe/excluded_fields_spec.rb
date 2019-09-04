# frozen_string_literal: true

RSpec.describe IronBank::Describe::ExcludedFields do
  subject(:call) { described_class.call(object_name: object_name) }

  describe "object without excluded fields" do
    let(:object_name) { "Product" }

    before do
      allow(Object.const_get("IronBank::Resources::#{object_name}")).
        to receive(:first) # Successful query
    end

    it { is_expected.to eq([]) }
  end

  describe "object with excluded fields" do
    let(:object_name)   { "Invoice" }
    let(:error_message) { "invalid field for query: invoice.foobar" }
    let(:query_fields)  { %w[FooBar ValidField] }

    let(:object) do
      Object.const_get("IronBank::Resources::#{object_name}")
    end

    before do
      num_query = 0

      # Querying `Object#first`:
      #   - for the first time raises an exception
      #   - following calls are successful
      allow(object).to receive(:first) do
        num_query += 1
        raise IronBank::InternalServerError, error_message if num_query == 1
      end

      allow(object).to receive(:query_fields).and_return(query_fields)
    end

    it { is_expected.to eq(["FooBar"]) }
  end

  describe "cannot parse error message" do
    let(:object_name) { "Account" }

    before do
      allow(Object.const_get("IronBank::Resources::#{object_name}")).
        to receive(:first).
        and_raise(IronBank::InternalServerError)
    end

    specify do
      expect { call }.to raise_error(RuntimeError, /Could not parse error/)
    end
  end
end
