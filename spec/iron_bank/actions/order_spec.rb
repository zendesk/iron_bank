# frozen_string_literal: true

require "shared_examples/action"

RSpec.describe IronBank::Actions::Order do
  it_behaves_like "a Zuora action" do
    let(:args) do
      {
        orderDate:             "2020-01-01",
        existingAccountNumber: "A00000001",
        subscriptions:         []
      }
    end

    let(:endpoint) { "v1/orders" }

    let(:params) do
      {
        orderDate:             "2020-01-01",
        existingAccountNumber: "A00000001",
        subscriptions:         []
      }
    end

    let(:body) do
      {
        "success"             => true,
        "orderNumber"         => "O-00179454",
        "accountNumber"       => "ZUORA00067933",
        "status"              => "Completed",
        "subscriptionNumbers" => ["ZD-S00070192"]
      }
    end
  end
end
