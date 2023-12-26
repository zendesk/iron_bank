# frozen_string_literal: true

module IronBank
  module Describe
    # Returns an array of non-queryable fields for the given object in the
    # current Zuora tenant, despites Zuora clearly marking these fields as
    # `<selectable>true</true>` in their Describe API... /rant
    class ExcludedFields
      extend Forwardable

      INVALID_OBJECT_ID = "InvalidObjectId"

      private_class_method :new

      def self.call(object_name:)
        new(object_name).call
      end

      def call
        remove_invalid_fields until valid_query?
        (excluded_fields - single_resource_query_fields).sort
      end

      private

      attr_reader :object_name,
        :invalid_fields

      def_delegators "IronBank.logger", :info
      def_delegators :object, :single_resource_query_fields

      def initialize(object_name)
        @object_name    = object_name
        @invalid_fields = []
      end

      def object
        IronBank::Resources.const_get(object_name)
      end

      def excluded_fields
        @excluded_fields ||= object.excluded_fields.dup
      end

      def remove_invalid_fields
        query_fields  = object.query_fields
        failed_fields = query_fields.select do |field|
          invalid_fields.any? { |failed| field.casecmp?(failed) }
        end
        excluded_fields.push(*failed_fields)
        query_fields.delete_if { |field| failed_fields.include?(field) }
      end

      def valid_query?
        # Querying using the ID (which is an indexed field) should return an
        # empty collection very quickly when successful
        object.where({ id: INVALID_OBJECT_ID })
        info "Successful query for #{object_name}"
        true
      rescue IronBank::BadRequestError, InternalServerError => e
        @invalid_fields = ExtractFromMessage.call(e.message) ||
          DeduceFromQuery.call(object)
        info "Invalid fields '#{@invalid_fields}' for #{object_name} query"
        false
      end
    end
  end
end
