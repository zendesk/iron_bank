# frozen_string_literal: true

module IronBank
  module Resources
    # An amendment updates a subscription version and has a type: new product,
    # update product, remove product, renewal, terms and conditions amendment.
    #
    class Amendment < Resource
      with_schema
      with_one :subscription
    end
  end
end
