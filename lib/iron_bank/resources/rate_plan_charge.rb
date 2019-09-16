# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan charge belongs to a subscription rate plan.
    #
    class RatePlanCharge < Resource
      def self.excluded_fields
        super + separate_query_fields
      end

      def self.separate_query_fields
        %w[RolloverBalance]
      end

      with_schema
      with_cache

      with_one :original, resource_name: "RatePlanCharge"
      with_one :product_rate_plan_charge, alias: :catalog_charge
      with_one :rate_plan, alias: :plan

      with_many :rate_plan_charge_tiers, alias: :tiers

      def rollover_balance
        remote[:rollover_balance] || reload.remote[:rollover_balance]
      end
    end
  end
end
