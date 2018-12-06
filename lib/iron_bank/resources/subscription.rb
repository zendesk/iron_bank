# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora subscription, belongs to an account, holds rate plans and is
    # versioned through each amendment.
    #
    class Subscription < Resource
      with_schema
      with_cache

      with_one :account
      with_one :invoice_owner, resource_name: 'Account'

      with_one :original, resource_name: 'Subscription'
      with_one :previous,
               resource_name: 'Subscription',
               foreign_key:   'previous_subscription_id'

      with_many :rate_plans, aka: :plans
      with_many :usages

      # FIXME: a subscription can only have at most one amendment (no amendment
      # for the last version) but there are no `AmendmentId` on a subscription.
      with_many :amendments
    end
  end
end
