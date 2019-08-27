# frozen_string_literal: true
module IronBank
  module Describe
    # Returns an array of non-queryable fields for the given object in the
    # current Zuora tenant, despites Zuora clearly marking these fields as
    # `<selectable>true</true>` in their Describe API... /rant
    #
    class ExcludedFields
      FAULT_FIELD = /invalid field for query: \w+\.(\w+)/.freeze

      private_class_method :new

      def self.call(object_name:)
        new(object_name).call
      end

      def call
        until valid_query?
          remove_last_failure_field
        end

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
      rescue IronBank::InternalServerError => error
        @last_failed_field = FAULT_FIELD.match(error.message)[1]

        IronBank.logger.info "Invalid field '#{@last_failed_field}' for "\
          "#{object_name} query"

        false
      end
    end
  end
end
