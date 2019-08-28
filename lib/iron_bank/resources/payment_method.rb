# frozen_string_literal: true

module IronBank
  module Resources
    # An electronic payment method, belongs to an account, can be set as the
    # default payment method on an account to enable auto-pay through payment
    # runs.
    #
    class PaymentMethod < Resource
      with_schema

      with_one :account
    end
  end
end
