# frozen_string_literal: true

module IronBank
  module Resources
    # A taxation item represents the tax amount associated with a single invoice
    # item.
    #
    class TaxationItem < Resource
      with_schema

      with_one :invoice
      with_one :invoice_item
    end
  end
end
