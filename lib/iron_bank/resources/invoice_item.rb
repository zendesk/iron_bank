# frozen_string_literal: true

module IronBank
  module Resources
    # An invoice item holds a charge that is billed to a customer.
    #
    class InvoiceItem < Resource
      with_schema

      with_one :invoice
      with_one :subscription

      # NOTE: the `product_id` field is not always populated by Zuora in the GET
      # request (`#find` method), I don't exactly know why.
      with_one :product
      with_one :charge
    end
  end
end
