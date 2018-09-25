# frozen_string_literal: true

module IronBank
  module Authentications
    # Get a cookie to enable authenticated calls to Zuora through Session.
    #
    class Cookie
      include IronBank::OpenTracing

      TEN_MINUTES = 600
      ONE_HOUR    = 3600

      def initialize(client_id:, client_secret:, base_url:)
        @client_id     = client_id
        @client_secret = client_secret
        @base_url      = base_url
        fetch_cookie
      end

      def expired?
        # Ten minutes as a margin of error in order to renew token in time
        expires_at < Time.now + TEN_MINUTES
      end

      def header
        { 'Cookie' => use }
      end

      private

      attr_reader :client_id, :client_secret, :base_url, :cookie, :zsession,
                  :expires_at

      def use
        refetch_cookie if expired?
        zsession
      end

      def fetch_cookie
        response    = authenticate
        @cookie     = response.headers['set-cookie']
        @zsession   = fetch_zsession
        @expires_at = Time.now + ONE_HOUR
      end
      alias refetch_cookie fetch_cookie

      def fetch_zsession
        /ZSession=([^\;]+)/.match(cookie)[0]
      end

      def authenticate
        connection.post('v1/connections', {})
      end

      def connection
        @connection ||= Faraday.new(faraday_config) do |conn|
          conn.use      :ddtrace, open_tracing_options if open_tracing_enabled?
          conn.request  :url_encoded
          conn.response :logger, IronBank.logger
          conn.response :json
          conn.adapter  Faraday.default_adapter
        end
      end

      def faraday_config
        {
          url:     base_url,
          headers: authentication_headers
        }
      end

      def authentication_headers
        {
          apiaccesskeyid:     client_id,
          apisecretaccesskey: client_secret
        }
      end
    end
  end
end
