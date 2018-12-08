# frozen_string_literal: true

module IronBank
  module Actions
    # Use the subscribe call to bundle information required to create at least
    # one new subscription
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTsubscribe
    #
    class Subscribe < Action
      private

      def params
        { subscribes: subscribes }
      end

      def subscribes
        IronBank::Object.new(args.fetch(:subscribes)).deep_camelize
      end
    end
  end
end
