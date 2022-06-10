# frozen_string_literal: true

module IronBank
  module Actions
    # Query More call to Zuora REST API
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTqueryMore
    #
    class QueryMore < Action
      private

      def params
        { queryLocator: args }
      end

      # NOTE: Zuora API endpoint is case-sensitive.
      def endpoint
        "v1/action/queryMore"
      end
    end
  end
end
