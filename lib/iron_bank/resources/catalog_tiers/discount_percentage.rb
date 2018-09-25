# frozen_string_literal: true

module IronBank
  module Resources
    module CatalogTiers
      # A tier that holds an discount percentage for a given product rate plan
      # charge.
      #
      class DiscountPercentage < ProductRatePlanChargeTier
        def self.exclude_fields
          %w[
            Active
            DiscountAmount
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
