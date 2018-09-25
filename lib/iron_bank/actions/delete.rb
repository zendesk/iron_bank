# frozen_string_literal: true

module IronBank
  module Actions
    # Delete one or more objects of the same type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTdelete
    #
    class Delete < Action
      private

      def params
        {
          ids:  args.fetch(:ids),
          type: args.fetch(:type)
        }
      end
    end
  end
end
