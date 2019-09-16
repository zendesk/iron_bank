# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora invoice is generated through a bill run, belongs to an account and
    # holds many invoice items.
    #
    class Invoice < Resource
      # See the comment for the instance method `#body`
      def self.excluded_fields
        super + single_resource_query_fields
      end

      def self.single_resource_query_fields
        %w[Body]
      end

      with_schema

      with_one :account

      with_many :invoice_adjustments, alias: :adjustments
      with_many :invoice_items, alias: :items
      with_many :invoice_payments
      with_many :taxation_items

      # We can only retrieve one invoice body at a time, hence Body is excluded
      # from the query fields, but is populated using the `find` class method
      def body
        remote[:body] || reload.remote[:body]
      end
    end
  end
end
