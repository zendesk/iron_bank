# frozen_string_literal: true

# IronBank main module
module IronBank
  # IronBank Faraday middleware module
  module FaradayMiddleware
    # This class raises an exception based on the HTTP status code and the
    # `success` flag (if present in the response) from Zuora.
    class RaiseError < Faraday::Response::Middleware
      private

      def on_complete(env)
        (error = IronBank::Error.from_response(env.response)) && raise(error)
      end
    end
  end
end
