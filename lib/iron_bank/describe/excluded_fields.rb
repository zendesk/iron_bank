# frozen_string_literal: true

module IronBank
  module Describe
    # Returns an array of non-queryable fields for the given object in the
    # current Zuora tenant, despites Zuora clearly marking these fields as
    # `<selectable>true</true>` in their Describe API... /rant
    #
    class ExcludedFields
      extend Forwardable

      FAULT_FIELD_MESSAGES = Regexp.union(
        # Generic fault field
        /invalid field for query: \w+\.(\w+)/,
        # Invoice Bill Run is not selectable in ZOQL
        /Cannot use the (BillRunId) field in the select clause/,
        # Invoice Body, implemented as a separate call
        /Can only query one invoice (body) at a time/,
        # Catalog tier should only query the price field
        /use Price or (DiscountAmount) or (DiscountPercentage)/,
        # Catalog plan currencies, implemented as a separate call
        /When querying for (active currencies)/,
        # Catalog charge rollover balance
        /You can only query (RolloverBalance) in particular/,
        # (Subscription) charge should only query the price field
        %r{
          (OveragePrice),
          \ Price,
          \ (IncludedUnits),
          \ (DiscountAmount)
          \ or\ (DiscountPercentage)
        }x
      ).freeze

      private_class_method :new

      def self.call(object_name:)
        new(object_name).call
      end

      def call
        remove_last_failure_fields until valid_query?

        excluded_fields
      end

      private

      attr_reader :object_name, :excluded_fields, :last_failed_fields

      def_delegators "IronBank.logger", :info

      def initialize(object_name)
        @object_name        = object_name
        @excluded_fields    = []
        @last_failed_fields = nil
      end

      def object
        IronBank::Resources.const_get(object_name)
      end

      def remove_last_failure_fields
        query_fields = object.query_fields

        failed_fields = query_fields.select do |field|
          last_failed_fields.any? { |failed| field.casecmp?(failed) }
        end

        @excluded_fields += failed_fields

        # Remove the field for the next query
        query_fields.delete_if { |field| failed_fields.include?(field) }
      end

      def valid_query?
        # Querying using the ID (indexed field) should return an empty
        # collectio fast when it's successful
        object.where(id: "XYZ")

        info "Successful query for #{object_name}"

        true
      rescue IronBank::InternalServerError => e
        @last_failed_fields = extract_fields_from_exception(e)

        false
      end

      def extract_fields_from_exception(exception)
        message = exception.message

        unless FAULT_FIELD_MESSAGES.match(message)
          raise "Could not parse error message: #{message}"
        end

        failed_fields = Regexp.last_match.
                        captures.
                        compact.
                        map { |capture| capture.delete(" ") }

        info "Invalid fields '#{failed_fields}' for #{object_name} query"

        failed_fields
      end
    end
  end
end
