# frozen_string_literal: true

module IronBank
  module Actions
    # Create one or more objects of a specific type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTcreate
    #
    class Create < Action
      private

      def params
        {
          objects: requests,
          type:    args.fetch(:type)
        }
      end
    end
  end
end
