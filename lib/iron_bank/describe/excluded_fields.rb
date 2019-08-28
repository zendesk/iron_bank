# frozen_string_literal: true

module IronBank
  module Describe
    # Returns an array of non-queryable fields for the given object in the
    # current Zuora tenant, despites Zuora clearly marking these fields as
    # `<selectable>true</true>` in their Describe API... /rant
    #
    class ExcludedFields
      GENERIC_FAULT_FIELD = /invalid field for query: \w+\.(\w+)/.freeze

      INVOICE_BILL_RUN_ID_FAULT = /Cannot use the BillRunId field in the select clause/.freeze

      INVOICE_BODY_FAULT = /Can only query one invoice body at a time/.freeze

      CATALOG_TIER_PRICE_FAULT = /You can only use Price or DiscountAmount or DiscountPercentage/.freeze

      CATALOG_CHARGE_ACTIVE_CURRENCIES_FAULT = /When querying for active currencies/.freeze

      CHARGE_ROLLOVER_BALANCE_FAULT = /You can only query RolloverBalance in particular/.freeze

      CHARGE_OTHER_THAN_PRICE_FAULT = /OveragePrice, Price, IncludedUnits, DiscountAmount or DiscountPercentage/.freeze

      private_class_method :new

      def self.call(object_name:)
        new(object_name).call
      end

      def call
        remove_last_failure_field until valid_query?

        excluded_fields
      end

      private

      attr_reader :object_name, :excluded_fields, :last_failed_field

      def initialize(object_name)
        @object_name       = object_name
        @excluded_fields   = []
        @last_failed_field = nil
      end

      def object
        IronBank::Resources.const_get(object_name)
      end

      def remove_last_failure_field
        # Zuora's response is lower cased, where the query fields are case
        # sensitive (well, at least the custom fields)...
        failed_field = object.query_fields.detect do |field|
          field.casecmp?(last_failed_field)
        end

        @excluded_fields << failed_field

        # Remove the field for the next query
        object.query_fields.delete(failed_field)
      end

      def valid_query?
        object.first
        IronBank.logger.info "Successful query for #{object_name}"

        true
      rescue IronBank::InternalServerError => e
        case (message = e.message)
        when GENERIC_FAULT_FIELD
          @last_failed_field = Regexp.last_match(1) # last match
        when INVOICE_BILL_RUN_ID_FAULT
          @last_failed_field = "BillRunId"
        when INVOICE_BODY_FAULT
          @last_failed_field = "Body"
        when CATALOG_TIER_PRICE_FAULT
          # FIXME: Refactor method to accept an array or a single value instead
          #        of calling it twice like here
          @last_failed_field = "DiscountAmount"
          remove_last_failure_field
          @last_failed_field = "DiscountPercentage"
        when CATALOG_CHARGE_ACTIVE_CURRENCIES_FAULT
          @last_failed_field = "ActiveCurrencies"
        when CHARGE_ROLLOVER_BALANCE_FAULT
          @last_failed_field = "RolloverBalance"
        when CHARGE_OTHER_THAN_PRICE_FAULT
          # FIXME: Same note as above
          @last_failed_field = "OveragePrice"
          remove_last_failure_field
          @last_failed_field = "IncludedUnits"
          remove_last_failure_field
          @last_failed_field = "DiscountAmount"
          remove_last_failure_field
          @last_failed_field = "DiscountPercentage"
        else
          raise "Could not parse error message: #{message}"
        end

        IronBank.logger.info "Invalid field '#{@last_failed_field}' for "\
          "#{object_name} query"

        false
      end
    end
  end
end
