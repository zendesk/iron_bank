# frozen_string_literal: true

module IronBank
  # Metadata to provide accessors to Zuora resources.
  #
  module Metadata
    def excluded_fields
      return [] unless (excluded = IronBank.configuration.excluded_fields)

      # Return the field for the given resource name
      # (where the module is extended from)
      excluded.fetch(object_name, [])
    end

    def fields
      return [] unless schema

      @fields ||= schema.fields.map(&:name) - excluded_fields
    end

    def query_fields
      return [] unless schema

      @query_fields ||= schema.query_fields - excluded_fields
    end

    def schema
      @schema ||= IronBank::Schema.for(object_name)
    end

    def with_schema
      fields.each do |field|
        field_name = IronBank::Utils.underscore(field).to_sym
        define_method(:"#{field_name}") { remote[field_name] }
      end
    end
  end
end
