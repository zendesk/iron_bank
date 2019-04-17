# frozen_string_literal: true

module IronBank
  module Resources
    # A tier holds an amount (cost) and a currency for a given product rate plan
    # charge.
    #
    class ProductRatePlanChargeTier < Resource
      # These fields are declared as `<selectable>true</selectable>` but only
      # for <context>export</export>, AKA ZOQL export. To let live queries go
      # through when the local records are not exported, we only allow querying
      # the non-discount tiers.
      def self.exclude_fields
        %w[
          Active
          IncludedUnits
          OveragePrice
          DiscountAmount
          DiscountPercentage
        ]
      end

      with_schema
      with_local_records
      with_cache

      with_one :product_rate_plan_charge, alias: :charge
    end
  end
end
