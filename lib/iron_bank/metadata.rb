# frozen_string_literal: true

module IronBank
  # Metadata to provide accessors to Zuora resources.
  #
  module Metadata
    def excluded_fields
      return [] unless (fields = IronBank.configuration.excluded_fields)

      # Return the field for the given resource name
      # (where the module is extended from)
      fields.fetch(object_name, [])
    end

    # NOTE: For some resources, fields are queryable with some restrictions,
    #       e.g. the `Invoice#body` can only be added to the list of fields if
    #       there is only one invoice in the query response.
    def single_resource_query_fields
      []
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

    def reset
      %i[@fields @query_fields @schema].each do |var|
        remove_instance_variable(var) if instance_variable_defined?(var)
      end

      with_schema
    end

    def with_schema
      fields.each do |field|
        field_name = IronBank::Utils.underscore(field).to_sym
        define_method(:"#{field_name}") { remote[field_name] }
      end
    end
  end
end
