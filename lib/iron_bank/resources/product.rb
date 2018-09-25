# frozen_string_literal: true

module IronBank
  module Resources
    # A Zuora product holds many product rate plans.
    #
    class Product < Resource
      with_schema
      with_local_records
      with_cache
      with_many :product_rate_plans, aka: :plans
    end
  end
end
