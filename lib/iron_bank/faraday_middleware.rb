# frozen_string_literal: true

# IronBank main module
module IronBank
  # IronBank Faraday middleware module
  module FaradayMiddleware
    if Faraday::Middleware.respond_to? :register_middleware
      Faraday::Middleware.register_middleware \
        raise_error: -> { RaiseError }

      Faraday::Request.register_middleware \
        retriable_auth: -> { RetriableAuth }
    end
  end
end
