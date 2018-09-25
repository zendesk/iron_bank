# frozen_string_literal: true

module IronBank
  module Resources
    # A product rate plan charge can be a one-time, recurring or usage-based
    # charge. It belongs to a product rate plan and can have many tiers when
    # using a Volume or Tiered pricing model.
    #
    # NOTE: if multiple currencies are enabled for your Zuora tenant, then there
    # is *at least* one tier per active currency.
    #
    class ProductRatePlanCharge < Resource
      # `DiscountClass` seems to not be a queryable field, despite the result
      # from the describe call for product rate plan charge.
      def self.exclude_fields
        %w[DiscountClass]
      end
      with_schema
      with_local_records
      with_cache

      with_one :product_rate_plan, aka: :plan

      with_many :product_rate_plan_charge_tiers, aka: :tiers
    end
  end
end
