# frozen_string_literal: true

module IronBank
  module Resources
    module CatalogTiers
      # A tier that holds an amount (cost) and a currency for a given product
      # rate plan charge.
      #
      class Price < ProductRatePlanChargeTier
        def self.exclude_fields
          %w[
            Active
            DiscountAmount
            DiscountPercentage
            IncludedUnits
            OveragePrice
          ]
        end

        def self.object_name
          superclass.object_name
        end
      end
    end
  end
end
