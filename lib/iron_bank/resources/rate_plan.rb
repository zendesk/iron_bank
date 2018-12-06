# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan belongs to a subscription and is a copy of the associated
    # product rate plan from the catalog at the time of the subscription.
    #
    class RatePlan < Resource
      with_schema
      with_cache

      with_one :amendment
      with_one :product_rate_plan, aka: :catalog_plan
      with_one :subscription

      with_many :rate_plan_charges,
                aka:        :charges,
                conditions: { is_last_segment: true }
    end
  end
end
