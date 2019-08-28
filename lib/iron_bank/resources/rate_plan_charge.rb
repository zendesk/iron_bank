# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan charge belongs to a subscription rate plan.
    #
    class RatePlanCharge < Resource
      with_schema
      with_cache

      with_one :original, resource_name: "RatePlanCharge"
      with_one :product_rate_plan_charge, alias: :catalog_charge
      with_one :rate_plan, alias: :plan

      with_many :rate_plan_charge_tiers, alias: :tiers

      def rollover_balance
        # FIXME
      end
    end
  end
end
