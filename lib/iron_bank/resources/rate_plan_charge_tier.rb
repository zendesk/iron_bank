# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan charge tier hold the price per unit the customer will be
    # billed for, in his/her currency.
    #
    class RatePlanChargeTier < Resource
      with_schema
      with_cache

      with_one :rate_plan_charge, alias: :charge
    end
  end
end
