# frozen_string_literal: true

module IronBank
  module Resources
    # A rate plan charge belongs to a subscription rate plan.
    #
    class RatePlanCharge < Resource
      extend Gem::Deprecate

      def self.excluded_fields
        super + single_resource_query_fields
      end

      def self.single_resource_query_fields
        %w[RolloverBalance Price]
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

      # NOTE: #price was only available when (1) the pricing model for the
      #       charge is either "Flat Fee" or "Per Unit" AND (2) the charge was
      #       queried through ZOQL, i.e, using `IronBank::Charge#where` method.
      #
      #       Testing Zuora REST API (using the `IronBank::Charge#find` method)
      #       shows that Zuora does not return a `price` attribute in their
      #       response. This means we consider #price to be a remain from the
      #       SOAP ZOQL query operation. We are deprecating this method without
      #       replacement. Instead, users should be fetching the `#tiers` for
      #       the current charge and get the price information from there.
      def price
        nil
      end
      deprecate :price, :none, 2020, 1
    end
  end
end
