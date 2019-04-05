# frozen_string_literal: true

module IronBank
  module Resources
    # Export ZOQL queries.
    #
    class Export < Resource
      with_schema

      DEFAULT_CREATE_OPTIONS = {
        format: 'csv',
        zip:    false
      }.freeze

      ENDPOINT = '/v1/object/export'

      def self.create(query, options = {})
        payload = IronBank::Object.new(
          DEFAULT_CREATE_OPTIONS.merge(query: query).merge(options)
        ).deep_camelize

        response = IronBank.client.connection.post(ENDPOINT, payload)

        new(IronBank::Object.new(response.body).deep_underscore)
      end

      def download
        return unless status&.casecmp?('Completed')

        IronBank.client.connection.get("/v1/files/#{file_id}")
      end
    end
  end
end
