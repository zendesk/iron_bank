# frozen_string_literal: true

module IronBank
  # Custom error class for rescuing from all Zuora API errors
  class Error < StandardError
    # Returns the appropriate IronBank::Error subclass based on status and
    # response message
    def self.from_response(response)
      klass = begin
        case response.status
        when 200      then from_body(response)
        when 400      then IronBank::BadRequestError
        when 401      then IronBank::UnauthorizedError
        when 404      then IronBank::NotFoundError
        when 422      then IronBank::UnprocessableEntityError
        when 429      then IronBank::TooManyRequestsError
        when 500      then IronBank::InternalServerError
        when 400..499 then IronBank::ClientError
        when 500..599 then IronBank::ServerError
        else               IronBank::Error
        end
      end

      klass&.new(response)
    end

    def self.from_body(response)
      return unless (match = CODE_MATCHER.match(response.body.to_s))

      CODE_CLASSES[match.captures.first]
    end

    attr_reader :response

    def initialize(response = nil)
      @response = response

      message = response.is_a?(Faraday::Response) ? message_from_body : response

      super(message)
    end

    def message_from_body
      response && "Body: #{response.body}"
    end
  end

  # Raised on errors in the 400-499 range
  class ClientError < Error; end

  # Raised when Zuora returns a 400 HTTP status code
  class BadRequestError < ClientError; end

  # Raised when Zuora returns a 401 HTTP status code
  class UnauthorizedError < ClientError; end

  # Raised when Zuora returns a 404 HTTP status code
  class NotFoundError < ClientError; end

  # Zuora doesn't return a 409, but indicates it via the response
  class ConflictError < ClientError; end

  # Raised when Zuora return 422 and unsuccessful action responses
  class UnprocessableEntityError < ClientError; end

  # Raised when Zuora returns a 429 HTTP status code
  class TooManyRequestsError < ClientError; end

  # Raised on errors in the 500-599 range
  class ServerError < Error; end

  # Raised when Zuora returns a 500 HTTP status code
  class InternalServerError < ServerError; end

  # Zuora doesn't return a 502, but indicates it via the response
  class BadGatewayError < ServerError; end

  # Zuora indicates a temporary error via the response
  class TemporaryError < ServerError; end

  # Zuora indicates lock competition errors via the response
  class LockCompetitionError < TemporaryError; end

  CODE_CLASSES = {
    "API_DISABLED"           => ServerError,
    "CANNOT_DELETE"          => UnprocessableEntityError,
    "DUPLICATE_VALUE"        => ConflictError,
    "INVALID_FIELD"          => BadRequestError,
    "INVALID_ID"             => BadRequestError,
    "INVALID_TYPE"           => BadRequestError,
    "INVALID_VALUE"          => BadRequestError,
    "LOCK_COMPETITION"       => LockCompetitionError,
    "MALFORMED_QUERY"        => ClientError,
    "MISSING_REQUIRED_VALUE" => ClientError,
    "REQUEST_EXCEEDED_LIMIT" => TooManyRequestsError,
    "REQUEST_EXCEEDED_RATE"  => TooManyRequestsError,
    "TEMPORARY_ERROR"        => TemporaryError,
    "TRANSACTION_FAILED"     => InternalServerError,
    "TRANSACTION_TERMINATED" => InternalServerError,
    "TRANSACTION_TIMEOUT"    => BadGatewayError,
    "UNKNOWN_ERROR"          => InternalServerError
  }.freeze

  CODE_MATCHER = /(#{CODE_CLASSES.keys.join('|')})/.freeze
end
