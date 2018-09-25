# frozen_string_literal: true

module IronBank
  module Actions
    # Use the amend call to change a subscription
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTamend
    #
    class Amend < Action
      private

      def params
        { requests: args }
      end
    end
  end
end
