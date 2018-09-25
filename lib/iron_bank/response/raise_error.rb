# frozen_string_literal: true

module IronBank
  # Faraday response middleware
  module Response
    # This class raises an exception based on the HTTP status code and the
    # `success` flag (if present in the response) from Zuora.
    class RaiseError < Faraday::Response::Middleware
      private

      def on_complete(response)
        (error = IronBank::Error.from_response(response)) && raise(error)
      end
    end
  end
end
