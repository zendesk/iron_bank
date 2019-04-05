# frozen_string_literal: true

require "spec_helper"
require "shared_examples/action"

RSpec.describe IronBank::Actions::Generate do
  it_behaves_like "a Zuora action" do
    let(:args) do
      {
        type:    :invoice,
        objects: [
          {
            account_id:   "zuora-account-123",
            invoice_date: "2017-10-20",
            target_date:  "2017-10-20"
          },
          {
            account_id:   "zuora-account-234",
            invoice_date: "2017-10-21",
            target_date:  "2017-10-21"
          }
        ]
      }
    end

    let(:endpoint) { "v1/action/generate" }

    let(:params) do
      {
        type:    "Invoice",
        objects: [
          {
            "AccountId"   => "zuora-account-123",
            "InvoiceDate" => "2017-10-20",
            "TargetDate"  => "2017-10-20"
          },
          {
            "AccountId"   => "zuora-account-234",
            "InvoiceDate" => "2017-10-21",
            "TargetDate"  => "2017-10-21"
          }
        ]
      }
    end
  end
end
