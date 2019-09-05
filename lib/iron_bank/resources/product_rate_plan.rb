# frozen_string_literal: true

module IronBank
  module Resources
    # A product rate plan belongs to a product and holds many product rate plan
    # charges. It represents what a customer is subscribing to.
    #
    class ProductRatePlan < Resource
      # NOTE: Zuora doesn't let us query for more than one product rate plan
      #       `ActiveCurrencies` at a time
      def self.excluded_fields
        super + %w[ActiveCurrencies]
      end

      with_schema
      with_local_records
      with_cache

      with_one  :product
      with_many :product_rate_plan_charges, alias: :charges

      def active_currencies
        query_string = IronBank::QueryBuilder.zoql(
          self.class.object_name,
          ["ActiveCurrencies"],
          id: id
        )

        IronBank.client.query(query_string)
      end
    end
  end
end
