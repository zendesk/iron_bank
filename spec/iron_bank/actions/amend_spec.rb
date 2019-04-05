# frozen_string_literal: true

require "spec_helper"
require "shared_examples/action"

RSpec.describe IronBank::Actions::Amend do
  it_behaves_like "a Zuora action" do
    let(:args) do
      {
        requests: [
          { amendments: [], preview_options: {} },
          { amendments: [], preview_options: {} }
        ]
      }
    end

    let(:endpoint) { "v1/action/amend" }

    let(:params) do
      {
        requests: [
          { "Amendments" => [], "PreviewOptions" => {} },
          { "Amendments" => [], "PreviewOptions" => {} }
        ]
      }
    end

    let(:body) { { "results" => anything } }
  end
end
