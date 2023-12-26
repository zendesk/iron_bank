# frozen_string_literal: true

module IronBank
  module Describe
    # NOTE: Beware there could be a performance hit as the search repeatedly
    # executes queries to perform the search for invalid fields in the query
    # included in the query statement.

    # rubocop:disable Style/ClassAndModuleChildren
    class ExcludedFields::DeduceFromQuery
      INVALID_OBJECT_ID = "InvalidObjectId"

      private_class_method :new

      def self.call(object)
        new(object).call
      end

      def call
        query_fields = object.query_fields.clone

        divide_and_execute(query_fields)
        # Set initial state for object.query_fields
        object.query_fields.concat query_fields

        invalid_fields
      end

      private

      attr_reader :object, :valid_fields, :invalid_fields

      def initialize(object)
        @object = object
        @valid_fields = []
        @invalid_fields = []
      end

      def divide_and_execute(query_fields)
        # Clear state before queries
        object.query_fields.clear
        # We repeat dividing until only one field has left
        invalid_fields.push(query_fields.pop) if query_fields.one?
        return if query_fields.empty?

        left, right = divide_fields(query_fields)

        execute_or_divide_again(left)
        execute_or_divide_again(right)
      end

      def divide_fields(query_fields)
        mid = query_fields.size / 2
        [query_fields[0..mid - 1], query_fields[mid..]]
      end

      def execute_or_divide_again(fields)
        if execute_query(fields)
          valid_fields.concat(fields)
        else
          divide_and_execute(fields)
        end
      end

      def execute_query(fields)
        object.query_fields.concat(valid_fields + fields)
        object.where({ id: INVALID_OBJECT_ID })
        true
      rescue IronBank::InternalServerError
        false
      end
    end
    # rubocop:enable Style/ClassAndModuleChildren
  end
end
