# frozen_string_literal: true

module IronBank
  module Describe
    # Makes a binary search by query fields to get failed fields
    class ExcludedFields::DeduceFromQuery
      INVALID_OBJECT_ID = "InvalidObjectId"

      private_class_method :new

      def self.call(object)
        new(object).call
      end

      def call
        exctract_from_dividing
      end

      private

      attr_reader :object

      def initialize(object)
        @object = object
      end

      def exctract_from_dividing
        @working_fields = []
        @failed_fields = []
        query_fields = object.query_fields.clone

        divide_and_execute(query_fields)
        # Set initial state for object.query_fields
        object.query_fields.concat query_fields

        @failed_fields
      end

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

      def execute_query(fields)
        object.query_fields.concat(@working_fields + fields)

        object.where({ id: INVALID_OBJECT_ID })

        true
      rescue IronBank::InternalServerError
        false
      end
    end
  end
end
