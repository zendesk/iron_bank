# frozen_string_literal: true

module IronBank
  module Actions
    # Use the subscribe call to bundle information required to create at least
    # one new subscription
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTsubscribe
    #
    class Subscribe < Action
      def call
        body = IronBank.client.connection.post(endpoint, params).body

        if body.is_a?(Array)
          body.map { |result| IronBank::Object.new(result).deep_underscore }
        else
          IronBank::Object.new(body).deep_underscore
        end
      end

      private

      def params
        { subscribes: subscribe_requests }
      end

      def subscribe_requests
        requests = [args].flatten
        requests.map { |request| IronBank::Object.new(request).deep_camelize }
      end
    end
  end
end
