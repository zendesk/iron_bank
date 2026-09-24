# frozen_string_literal: true

module IronBank
  # A query builder helps buidling a syntaxically correct query using ZOQL.
  #
  class QueryBuilder
    private_class_method :new

    def self.zoql(object, fields, conditions = {})
      new(object, fields, conditions).zoql
    end

    def zoql
      query = "select #{query_fields} from #{object}"
      conditions.empty? ? query : "#{query} where #{query_conditions}"
    end

    private

    attr_reader :object, :fields, :conditions

    def initialize(object, fields, conditions)
      @object     = object
      @fields     = fields
      @conditions = conditions
    end

    def query_fields
      fields.join(",")
    end

    def query_conditions
      ensure_range_single_condition

      case conditions
      when Hash
        hash_query_conditions
      end
    end

    # ZOQL filter literals (Query API) escape \ and ' with a backslash. Export ZOQL
    # uses doubled quotes; this builder feeds IronBank::Query / queryString only.
    # https://docs.zuora.com/en/zuora-platform/data/legacy-query-methods/zoql/filter-statements
    def escape_value(value)
      value.to_s
        .gsub("\\") { "\\\\" }
        .gsub("'") { "\\'" }
    end

    def range_query_builder(field, value)
      value.each.with_object([]) do |option, range_query|
        range_query << "#{field}='#{escape_value(option)}'"
      end.join(" OR ")
    end

    def hash_query_conditions
      conditions.each.with_object([]) do |(field, value), filters|
        field = IronBank::Utils.camelize(field)
        filters << current_filter(field, value)
      end.join(" AND ")
    end

    def current_filter(field, value)
      if value.is_a?(Array)
        range_query_builder(field, value)
      elsif [true, false].include? value
        "#{field}=#{value}"
      else
        "#{field}='#{escape_value(value)}'"
      end
    end

    def ensure_range_single_condition
      return if conditions.count <= 1
      return unless conditions.values.any?(Array)

      raise "Filter ranges must be used in isolation."
    end
  end
end
