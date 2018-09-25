# frozen_string_literal: true

module IronBank
  module Authentications
    # Get a bearer token to enable authenticated calls to Zuora through OAuth.
    #
    class Token
      include IronBank::OpenTracing

      # Generic token error.
      #
      class Error < StandardError; end

      # Thrown when the access_token is not valid.
      #
      class InvalidAccessToken < Error; end

      TEN_MINUTES = 600
      ONE_HOUR    = 3600

      def initialize(client_id:, client_secret:, base_url:)
        @client_id     = client_id
        @client_secret = client_secret
        @base_url      = base_url
        fetch_token
      end

      def expired?
        # Ten minutes as a margin of error in order to renew token in time
        expires_at < Time.now + TEN_MINUTES
      end

      def header
        { 'Authorization' => "Bearer #{use}" }
      end

      private

      attr_reader :client_id, :client_secret, :base_url, :access_token,
                  :expires_at

      def use
        refetch_token if expired?
        access_token
      end

      def fetch_token
        response      = authenticate || {}
        @access_token = response.fetch('access_token', nil)
        @expires_at   = Time.now + response.fetch('expires_in', ONE_HOUR).to_i
        validate_access_token
      end
      alias refetch_token fetch_token

      def authenticate
        connection.post('/oauth/token', authentication_params).body
      end

      def connection
        @connection ||= Faraday.new(url: base_url) do |conn|
          conn.use      :ddtrace, open_tracing_options if open_tracing_enabled?
          conn.request  :url_encoded
          conn.response :logger, IronBank.logger
          conn.response :json
          conn.adapter  Faraday.default_adapter
        end
      end

      def authentication_params
        {
          client_id:     client_id,
          client_secret: client_secret,
          grant_type:    'client_credentials'
        }
      end

      def validate_access_token
        raise InvalidAccessToken, access_token unless access_token
      end
    end
  end
end
