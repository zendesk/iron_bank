# frozen_string_literal: true

RSpec.describe IronBank::Object do
  describe "#deep_camelize" do
    subject { input.deep_camelize(type: type) }

    context "with nested IronBank::Objects" do
      let(:input)        { described_class.new(first_object: first_object) }
      let(:first_object) { described_class.new(first_field: "first_field") }

      context "when the :type option is :upper" do
        let(:type) { :upper }

        let(:expected_output) do
          {
            "FirstObject" => {
              "FirstField" => "first_field"
            }
          }
        end

        it { is_expected.to eq(expected_output) }
      end

      context "when the :type option is :lower" do
        let(:type) { :lower }

        let(:expected_output) do
          {
            "firstObject" => {
              "firstField" => "first_field"
            }
          }
        end

        it { is_expected.to eq(expected_output) }
      end
    end

    context "with a nested hash" do
      let(:input) do
        described_class.new(
          first_hash: {
            first_key:  "first_value",
            second_key: "second_value"
          }
        )
      end

      context "when the :type option is :upper" do
        let(:type) { :upper }

        let(:expected_output) do
          {
            "FirstHash" => {
              "FirstKey"  => "first_value",
              "SecondKey" => "second_value"
            }
          }
        end

        it { is_expected.to eq(expected_output) }
      end

      context "when the :type option is :lower" do
        let(:type) { :lower }

        let(:expected_output) do
          {
            "firstHash" => {
              "firstKey"  => "first_value",
              "secondKey" => "second_value"
            }
          }
        end

        it { is_expected.to eq(expected_output) }
      end
    end

    context "with a nested array" do
      let(:input) do
        described_class.new(
          first_array: [
            { first_key: "first_value" },
            { first_key: "first_value" }
          ]
        )
      end

      context "when the :type option is :upper" do
        let(:type) { :upper }

        let(:expected_output) do
          {
            "FirstArray" => [
              { "FirstKey" => "first_value" },
              { "FirstKey" => "first_value" }
            ]
          }
        end

        it { is_expected.to eq(expected_output) }
      end

      context "when the :type option is :lower" do
        let(:type) { :lower }

        let(:expected_output) do
          {
            "firstArray" => [
              { "firstKey" => "first_value" },
              { "firstKey" => "first_value" }
            ]
          }
        end

        it { is_expected.to eq(expected_output) }
      end
    end

    context "with an array of String" do
      let(:type) { :upper }

      let(:input) do
        described_class.new(first_array: %w[foo bar])
      end

      let(:expected_output) do
        { "FirstArray" => %w[foo bar] }
      end

      it { is_expected.to eq(expected_output) }
    end

    context "with a snowflake field" do
      let(:type) { :upper }

      let(:input) do
        described_class.new(fieldsToNull: %w[foo bar])
      end

      let(:expected_output) do
        { "fieldsToNull" => %w[foo bar] }
      end

      it { is_expected.to eq(expected_output) }
    end
  end

  describe "#deep_underscore" do
    let(:input) { described_class.new(zuora_response) }

    subject { input.deep_underscore }

    context "with a nested hash" do
      let(:zuora_response) do
        {
          "FirstHash" => {
            "FirstKey"  => "first_value",
            "SecondKey" => "second_value"
          }
        }
      end

      let(:expected_output) do
        {
          first_hash: {
            first_key:  "first_value",
            second_key: "second_value"
          }
        }
      end

      it { is_expected.to eq(expected_output) }
    end

    context "with a nested array" do
      let(:zuora_response) do
        {
          "FirstArray" => [
            { "FirstKey" => "first_value" },
            { "FirstKey" => "second_value" }
          ]
        }
      end

      let(:expected_output) do
        {
          first_array: [
            { first_key: "first_value" },
            { first_key: "second_value" }
          ]
        }
      end

      it { is_expected.to eq(expected_output) }
    end
  end
end
