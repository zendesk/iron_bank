# frozen_string_literal: true

module IronBank
  module Resources
    module CatalogTiers
      # A tier that holds an discount ammount for a given product rate plan
      # charge.
      #
      class DiscountAmount < ProductRatePlanChargeTier
        def self.exclude_fields
          %w[
            Active
            DiscountPercentage
            IncludedUnits
            OveragePrice
            Price
          ]
        end

        def self.object_name
          superclass.object_name
        end
      end
    end
  end
end
