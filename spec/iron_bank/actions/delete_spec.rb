# frozen_string_literal: true

require "shared_examples/action"

RSpec.describe IronBank::Actions::Delete do
  it_behaves_like "a Zuora action" do
    let(:args)     { { type: :account, ids: %w[id-1 id-2] } }
    let(:endpoint) { "v1/action/delete" }
    let(:params)   { { type: "Account", ids: %w[id-1 id-2] } }

    let(:body) do
      [
        { "Success" => true, "Id" => "id-1" },
        { "Success" => true, "Id" => "id-2" }
      ]
    end
  end
end
