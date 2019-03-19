# frozen_string_literal: true

# IronBank main module
module IronBank
  # IronBank Faraday middleware module
  module FaradayMiddleware
    if Faraday::Middleware.respond_to?(:register_middleware)
      Faraday::Response.register_middleware(
        raise_error: -> { RaiseError },
        renew_auth:  -> { RenewAuth }
      )
    end
  end
end
