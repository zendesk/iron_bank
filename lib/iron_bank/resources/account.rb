# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora account is used for billing purposes: it holds many subscriptions,
    # has many contacts (but only one bill to and one sold to contact), can have
    # a default payment method, hence auto-pay can be activated for this account
    # or not, is billed invoices and can pay them using an electronic payment
    # method (usually a credit card, but PayPal is also accepted by Zuora).
    #
    class Account < Resource
      # Tenants without credit memo activated cannot query these fields BUT they
      # are still described as `selectable` through the metadata.
      #
      # Similarly, accounts with `TaxExemptStatus` set to `No` cannot query
      # the `TaxExemptEntityUseCode` related fields.
      def self.exclude_fields
        %w[
          TaxExemptEntityUseCode
          TotalDebitMemoBalance
          UnappliedCreditMemoAmount
        ]
      end
      with_schema

      # Contacts
      with_one :bill_to, resource_name: "Contact"
      with_one :sold_to, resource_name: "Contact"
      with_many :contacts

      # Subscriptions
      with_many :subscriptions
      with_many :active_subscriptions,
                resource_name: "Subscription",
                conditions:    { status: "Active" }

      # Invoices
      with_many :invoices

      # Payment Methods
      with_one :default_payment_method, resource_name: "PaymentMethod"
      with_many :payment_methods

      # Payments
      with_many :payments

      # Usages
      with_many :usages

      # Parent
      with_one :parent, resource_name: "Account"

      def ultimate_parent
        root if parent
      end

      def root
        parent ? parent.root : self
      end
    end
  end
end
