# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora invoice is generated through a bill run, belongs to an account and
    # holds many invoice items.
    #
    class Invoice < Resource
      # These fields are declared as `<selectable>true</selectable>` but Zuora
      # returns a QueryError when trying to query an invoice with them. Also,
      # the `Body` field can only be retrieved for a single invoice at a time.
      def self.exclude_fields
        %w[
          AutoPay
          BillRunId
          BillToContactSnapshotId
          Body
          RegenerateInvoicePDF
          SoldToContactSnapshotId
        ]
      end
      with_schema

      with_one :account

      with_many :invoice_adjustments, alias: :adjustments
      with_many :invoice_items, alias: :items
      with_many :invoice_payments

      # We can only retrieve one invoice body at a time, hence Body is excluded
      # from the query fields, but is populated using the `find` class method
      def body
        remote['Body'] || reload['Body']
      end
    end
  end
end
