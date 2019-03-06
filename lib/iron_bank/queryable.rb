# frozen_string_literal: true

module IronBank
  # Query-like features, such as `find` and `where` methods for a resource.
  #
  module Queryable
    include IronBank::Instrumentation

    # We use the REST endpoint for the `find` method
    def find(id)
      raise IronBank::NotFound unless id

      datadog_instrumenter(:find) do
        response = IronBank.client.connection.get(
          "v1/object/#{object_name}/#{id}"
        )
        new(IronBank::Object.new(response.body).deep_underscore)
      end
    end

    # This methods leverages the fact that Zuora only returns 2,000 records at a
    # time, hance providing a default batch size
    def find_each
      return enum_for(:find_each) unless block_given?

      client       = IronBank.client
      query_string = IronBank::QueryBuilder.zoql(object_name, query_fields)
      query_result = client.query(query_string) # up to 2k records from Zuora

      loop do
        query_result[:records].each { |data| yield new(data) }
        break if query_result[:done]

        query_result = client.query_more(query_result[:queryLocator])
      end
    end

    def all
      where({})
    end

    def where(conditions)
      query_string = IronBank::QueryBuilder.zoql(
        object_name,
        query_fields,
        conditions
      )

      # FIXME: need to use logger instance instead
      # puts "query: #{query_string}"

      records = IronBank::Query.call(query_string)[:records]
      return [] unless records

      records.each.with_object([]) do |data, result|
        result << new(data)
      end
    end
  end
end
