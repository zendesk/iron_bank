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

      def self.where(conditions)
        # If we are coming from a subclass, defer to Queryable#all
        return super unless name.end_with?("ProductRatePlanChargeTier")

        CatalogTiers.constants.map do |tier_klass|
          CatalogTiers.const_get(tier_klass).where(conditions)
        end.flatten
      end

      def self.find_each
        return enum_for(:find_each) unless block_given?
        return super unless name.end_with?("ProductRatePlanChargeTier")

        CatalogTiers.constants.each do |tier_klass|
          # Pass the block to each subclasses
          CatalogTiers.const_get(tier_klass).find_each(&Proc.new)
        end
      end

      # We want to store all fields to the CSV, not just the ones that can be
      # queried through Zuora, for all the different tiers (discount-percentage,
      # discount-fixed amount and regular pricing).
      def to_csv_row
        ProductRatePlanChargeTier.fields.each.with_object([]) do |field, row|
          row << remote[IronBank::Utils.underscore(field).to_sym]
        end
      end

      def self.load_records
        CSV.foreach(file_path, csv_options).with_object({}) do |row, store|
          remote = row.to_h.reject { |_, value| value.nil? }

          record = if remote[:discount_amount]
                     CatalogTiers::DiscountAmount.new(remote)
                   elsif remote[:discount_percentage]
                     CatalogTiers::DiscountPercentage.new(remote)
                   else
                     CatalogTiers::Price.new(remote)
                   end

          store[row[:id]] = record
        end
      end
    end
  end
end
