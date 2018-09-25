# frozen_string_literal: true

module IronBank
  # Custom error class for rescuing from all Zuora API errors
  class Error < StandardError
    # Returns the appropriate IronBank::Error subclass based on status and
    # response message
    def self.from_response(response)
      status = response[:status].to_i

      klass = begin
        case status
        when 400      then IronBank::BadRequest
        when 404      then IronBank::NotFound
        when 429      then IronBank::TooManyRequests
        when 500      then IronBank::InternalServerError
        when 400..499 then IronBank::ClientError
        when 500..599 then IronBank::ServerError
        end
      end

      return unless klass

      klass.new(response)
    end
  end

  # Raised on errors in the 400-499 range
  class ClientError < Error; end

  # Raised when Zuora returns a 400 HTTP status code
  class BadRequest < ClientError; end

  # Raised when Zuora returns a 404 HTTP status code
  class NotFound < ClientError; end

  # Raised when Zuora returns a 429 HTTP status code
  class TooManyRequests < ClientError; end

  # Raised on errors in the 500-599 range
  class ServerError < Error; end

  # Raised when Zuora returns a 500 HTTP status code
  class InternalServerError < ServerError; end
end
