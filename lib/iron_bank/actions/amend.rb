# frozen_string_literal: true

module IronBank
  module Actions
    # Use the amend call to change a subscription
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTamend
    #
    class Amend < Action
      def call
        puts "HELLO FROM LOCAL IRON BANK"
        # NOTE: The amend response wraps all results in an object, which is
        #       inconsistent with the rest of the `/v1/action` responses.
        super[:results]
      end

      private

      def params
        { requests: requests }
      end

      def requests
        IronBank::Object.new(args.fetch(:requests)).deep_camelize(type: :upper)
      end
    end
  end
end
