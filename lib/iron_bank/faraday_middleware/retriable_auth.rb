# frozen_string_literal: true

# IronBank main module
module IronBank
  # IronBank Faraday middleware module
  module FaradayMiddleware
    # This middleware reauthorize the request on unauthorized request
    class RetriableAuth < Faraday::Middleware
      def initialize(app, auth)
        @auth = auth
        super(app)
      end

      def call(env)
        @env = env
        renew_auth_header if env.status == 401

        @app.call(env)
      end

      private

      attr_reader :auth, :env

      def renew_auth_header
        auth.renew_session

        # NOTE: Merging the refreshed auth headers into the original request
        #       (which will be retried via the `:retry` middleware.)
        env.request_headers = env.request_headers.merge(auth.header)
      end
    end
  end
end
