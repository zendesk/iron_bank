# frozen_string_literal: true

module IronBank
  module Resources
    # A tier holds an amount (cost) and a currency for a given product rate plan
    # charge.
    #
    class ProductRatePlanChargeTier < Resource
      with_schema
      with_local_records
      with_cache

      with_one :product_rate_plan_charge, alias: :charge
    end
  end
end
