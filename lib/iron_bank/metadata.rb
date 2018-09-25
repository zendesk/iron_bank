# frozen_string_literal: true

module IronBank
  # Metadata to provide accessors to Zuora resources.
  #
  module Metadata
    # Can be overriden to exclude specific fields for a given resource, see
    # `Account` class for an example
    def exclude_fields
      []
    end

    def fields
      return [] unless schema

      @fields ||= schema.fields.map(&:name) - exclude_fields
    end

    def query_fields
      return [] unless schema

      @query_fields ||= schema.query_fields - exclude_fields
    end

    def schema
      @schema ||= IronBank::Schema.for(object_name)
    end

    def with_schema
      fields.each do |field|
        method_name = IronBank::Utils.underscore(field)
        define_method(:"#{method_name}") { remote[field] }
      end
    end
  end
end
