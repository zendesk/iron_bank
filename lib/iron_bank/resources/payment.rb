# frozen_string_literal: true

module IronBank
  module Resources
    # A payment belongs to an account and is applied against one or many
    # invoices and/or the account credit balance.
    #
    class Payment < Resource
      with_schema

      with_one :account
      with_one :payment_method

      with_many :invoice_payments
    end
  end
end
