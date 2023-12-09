# frozen_string_literal: true

module IronBank
  module Describe
    # Returns an array of non-queryable fields for the given object in the
    # current Zuora tenant, despites Zuora clearly marking these fields as
    # `<selectable>true</true>` in their Describe API... /rant
    #
    # rubocop:disable Metrics/ClassLength
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

        (excluded_fields - single_resource_query_fields).sort
      end

      private

      INVALID_OBJECT_ID = "InvalidObjectId"

      attr_reader :object_name, :last_failed_fields

      def_delegators "IronBank.logger", :info
      def_delegators :object, :single_resource_query_fields

      def initialize(object_name)
        @object_name        = object_name
        @last_failed_fields = nil
      end

      def object
        IronBank::Resources.const_get(object_name)
      end

      def excluded_fields
        @excluded_fields ||= object.excluded_fields.dup
      end

      def remove_last_failure_fields
        query_fields = object.query_fields

        failed_fields = query_fields.select do |field|
          last_failed_fields.any? { |failed| field.casecmp?(failed) }
        end

        excluded_fields.push(*failed_fields)

        # Remove the field for the next query
        query_fields.delete_if { |field| failed_fields.include?(field) }
      end

      def valid_query?
        # Querying using the ID (which is an indexed field) should return an
        # empty collection very quickly when successful
        object.where({ id: INVALID_OBJECT_ID })

        info "Successful query for #{object_name}"

        true
      rescue IronBank::BadRequestError => e
        @last_failed_fields = extract_fields_from_exception(e)

        false
      rescue IronBank::InternalServerError
        @last_failed_fields = exctract_from_dividing

        false
      end

      def exctract_from_dividing
        @working_fields = []
        @failed_fields = []
        query_fields = object.query_fields.clone

        divide_and_execute(query_fields)
        # Set initial state for object.query_fields
        object.query_fields.concat query_fields

        info "Invalid fields '#{@failed_fields}' for #{object_name} query"

        @failed_fields
      end

      # rubocop:disable Metrics/MethodLength
      # rubocop:disable Metrics/AbcSize
      def divide_and_execute(query_fields)
        # Clear state before queries
        object.query_fields.clear
        # We repeat dividing until only one field has left
        @failed_fields.push(query_fields.pop) if query_fields.one?
        return if query_fields.empty?

        mid = query_fields.size / 2
        left = query_fields[0..mid - 1]
        right = query_fields[mid..]

        if execute_query(left)
          @working_fields.concat(left)
        else
          divide_and_execute(left)
        end

        if execute_query(right)
          @working_fields.concat(right)
        else
          divide_and_execute(right)
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize

      def execute_query(fields)
        object.query_fields.concat(@working_fields + fields)

        object.where({ id: INVALID_OBJECT_ID })

        true
      rescue IronBank::InternalServerError
        false
      end

      def extract_fields_from_exception(exception)
        message = exception.message

        raise "Could not parse error message: #{message}" unless FAULT_FIELD_MESSAGES.match(message)

        failed_fields = Regexp.last_match.
                        captures.
                        compact.
                        map { |capture| capture.delete(" ") }

        info "Invalid fields '#{failed_fields}' for #{object_name} query"

        failed_fields
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
