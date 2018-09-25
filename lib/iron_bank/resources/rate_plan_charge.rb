# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan charge belongs to a subscription rate plan.
    #
    class RatePlanCharge < Resource
      def self.exclude_fields
        %w[
          DiscountAmount
          DiscountClass
          DiscountPercentage
          IncludedUnits
          OveragePrice
          Price
          RevenueRecognitionRuleName
          RolloverBalance
        ]
      end
      with_schema
      with_cache

      with_one :original, resource_name: 'RatePlanCharge'
      with_one :product_rate_plan_charge, aka: :catalog_charge
      with_one :rate_plan, aka: :plan

      with_many :rate_plan_charge_tiers, aka: :tiers
    end
  end
end
