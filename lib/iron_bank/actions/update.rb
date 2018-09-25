# frozen_string_literal: true

module IronBank
  module Actions
    # Update the information in one or more objects of the same type
    # https://www.zuora.com/developer/api-reference/#operation/Action_POSTupdate
    #
    class Update < Action
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
