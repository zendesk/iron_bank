# frozen_string_literal: true

module IronBank
  # Create payment run
  # https://www.zuora.com/developer/api-reference/#operation/POST_PaymentRun
  #
  class PaymentRun
    ENDPOINT = "/v1/payment-runs"

    def self.create(params)
      payload = IronBank::Object.new(params).deep_camelize(type: :lower)
      body    = IronBank.client.connection.post(ENDPOINT, payload).body
      success = body.fetch('success', false)

      raise ::IronBank::UnprocessableEntityError, body unless success

      IronBank::Object.new(body).deep_underscore
    end
  end
end
