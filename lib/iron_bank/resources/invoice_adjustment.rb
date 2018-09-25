# frozen_string_literal: true

module IronBank
  module Resources
    # An invoice adjustment modifies the total invoice balance.
    #
    class InvoiceAdjustment < Resource
      with_schema
      with_one :account
      with_one :invoice
    end
  end
end
