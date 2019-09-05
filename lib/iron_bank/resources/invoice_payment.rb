# frozen_string_literal: true

module IronBank
  module Resources
    # Many-to-many relationship between invoices and payments.
    #
    class InvoicePayment < Resource
      with_schema

      with_one :invoice
      with_one :payment
    end
  end
end
